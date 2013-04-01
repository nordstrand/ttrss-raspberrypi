class rss::appliancify {
    	$ttrss_hostname = "rss"

        notify {"tt-rss appliance verified":} <-
	
	exec { "rm -rf /home/pi/python_games":
		path   => "/usr/bin:/usr/sbin:/bin",
  		onlyif => "test -e /home/pi/python_games"
	}

	exec { "apt-update":
    		command => "/usr/bin/apt-get update"
	}
	
	Exec["apt-update"] -> Package <| |>

	host { $ttrss_hostname:
        	ensure => present,
        	ip     => $ipaddress,
        	before => Exec['hostname.sh'],
    	}

    	file { '/etc/mailname':
        	ensure  => present,
        	owner   => 'root',
        	group   => 'root',
        	mode    => 644,
        	content => "${ttrss_hostname}\n",
    	}

    	file { '/etc/hostname':
        	ensure  => present,
        	owner   => 'root',
        	group   => 'root',
        	mode    => 644,
        	content => "${ttrss_hostname}\n",
        	notify  => Exec['hostname.sh'],
	}
    
    	exec { 'hostname.sh':
        	command     => '/etc/init.d/hostname.sh start',
        	refreshonly => true,
    	}
}
