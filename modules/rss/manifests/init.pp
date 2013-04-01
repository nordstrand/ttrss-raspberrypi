class rss {
	$db_name     = "ttrss"
	$db_user     = "ttrss"
	$db_password = "ttrss"
	$ttrss_dir = "/var/www/ttrss"
	
	exec { "apt-update":
    		command => "/usr/bin/apt-get update",
		refreshonly => true,
	}
	Exec["apt-update"] ~> Package <| |>

	class { 'postgresql::server':
  		config_hash => {
    			'ip_mask_deny_postgres_user' => '0.0.0.0/32',
    			'ip_mask_allow_all_users'    => '0.0.0.0/0',
    			'listen_addresses'           => '*',
    			'postgres_password'          => 'TPSrep0rt!',
  		},
	}
	
	postgresql::db { $db_name:
  		user     => $db_user,
  		password => $db_password,
		notify => Exec["install ddl"], 
	}
        
	exec { "install ddl":
		command => "psql --username=$db_user --host=localhost  --dbname=$db_name --file=$ttrss_dir/schema/ttrss_schema_pgsql.sql",
		require => [Postgresql::Db[$db_name],Exec["mv ttrss"]],
		refreshonly => true,
		path  => "/usr/bin:/usr/sbin:/bin",
                environment =>  "PGPASSWORD=$db_password",
	}
	 
	package { "lighttpd" : 
		ensure => "installed",
		notify => Exec["enable-mod-fastcgi"],
	}

	case defined(Package["apache2"]) {
                true: {
                        service { "apache2": enable => false, ensure => stopped }
                }
        } -> Service["lighttpd"]
	
	service { "lighttpd":
  		ensure  => running,
  		enable  => true,
		require => Package["lighttpd"],
	}	

	exec { "enable-mod-fastcgi":
    		command => "lighttpd-enable-mod fastcgi-php",
    		path   => "/usr/bin:/usr/sbin:/bin",
		refreshonly => true,
		notify => Service["lighttpd"],
  		require => Package["lighttpd"]
  	}	

	$php = [ "php5-cgi", "php5-cli", "php5-pgsql" ]
	package { $php: ensure => "installed" }

   	package { "avahi-daemon" :  ensure => "installed", } 
	-> 
	service { "avahi-daemon" :
		ensure  => running,
                enable  => true,
	}

        package { "wget" : ensure => "installed" }

	exec {
		"download ttrss":
		command     => "wget --output-document=/tmp/ttrs.tar.gz https://github.com/gothfox/Tiny-Tiny-RSS/archive/1.7.5.tar.gz",
                unless => "test -e $ttrss_dir",
  		path   => "/usr/bin:/usr/sbin:/bin", 
		require => Package["wget"],
	}

        exec {
          "unzip ttrss":
           command => "tar -xzf ttrs.tar.gz -C /var/www/ && rm ttrs.tar.gz",
           refreshonly => true,
	   subscribe => Exec["download ttrss"],
	   cwd => "/tmp",  
           user => root,
	   path  => "/usr/bin:/usr/sbin:/bin";
           "mv ttrss":
           require => Exec["unzip ttrss"],
           command => "mv Tiny-Tiny-RSS-* ttrss",
	   creates => $ttrss_dir,
           cwd => "/var/www",
           user => root,
           path  => "/usr/bin:/usr/sbin:/bin";
           
           "chmod ttrss":
           require => Exec["mv ttrss"],
           command => "chmod -R 777 cache/images cache/export cache/js feed-icons lock",
           refreshonly => true,
           subscribe => Exec["mv ttrss"],
	   cwd => $ttrss_dir,
           user => root,
           path  => "/usr/bin:/usr/sbin:/bin";
        }

        file {
 		"$ttrss_dir/config.php" : source => "puppet:///modules/rss/config.php",
		require => Exec["mv ttrss"],		
	}

        cron { "update feeds":
  		command => "cd $ttrss_dir && /usr/bin/php $ttrss_dir/update.php --feeds >/dev/null 2>&1",
  		user    => www-data,
  		minute  => 30,
                ensure  => present,
 		require => [Exec["mv ttrss"],Package["lighttpd"]],  
	}
    
   	file { '/var/www/index.html':
        	ensure  => present,
		content => "<html><body onload=\"document.location.href='/ttrss'\"><h1>Redirecting..</h1></body></html>",
		require => Package["lighttpd"], 
	}
}
