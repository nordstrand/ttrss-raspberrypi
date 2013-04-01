ttrss-raspberrypi
=================

The low-cost energy efficient [http://www.raspberrypi.org/]Raspberry Pi is a ideal platform for hosting a personal Google Reader clone / [http://tt-rss.org/](Tiny Tiny RSS) instance.

To get everything working requires quite a few manual steps: installation, database setup, cronjob etc.

This projects automates all this with the help of Puppet setting up tt-rss to use the Postgres RDBMS and the ligthweight [http://www.lighttpd.net/](lighttpd) web server.

== Usage
1. $ apt-get -y update && apt-get -y install puppet git
2. $ git clone https://github.com/nordstrand/ttrss-raspberrypi
3. $ cd ttrss-raspberry-pi/
4. $ puppet apply --modulepath modules/:extmodules/ --verbose  manifests/site.pp
5. Grab a cup of coffee (puppet run will consume about ~20 minutes depending on network and SD-card performance)
6. Visit [http://raspberrypi.local/ttrs](http://raspberrypi.local/ttrs)

(Install has been verified on Raspbian, but will probably work on other distribution and non-rasberry platforms too).
