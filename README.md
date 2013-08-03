ttrss-raspberrypi
=================

The low-cost energy efficient [Raspberry Pi](http://www.raspberrypi.org/) is a ideal platform for hosting a personal Google Reader clone/[Tiny Tiny RSS](http://tt-rss.org/) instance.

To get everything working requires quite a few manual steps: installation, database setup, cronjob etc.

This projects automates all this with the help of Puppet setting up tt-rss to use the [PostgreSQL](http://www.postgresql.org/) RDBMS and the ligth weight [lighttpd](http://www.lighttpd.net/) web server.

Feeds will updated periodically and daily backups taken.

## Usage
1. $ apt-get -y update && apt-get -y install puppet git
2. $ GIT_SSL_NO_VERIFY=true git clone https://github.com/nordstrand/ttrss-raspberrypi
3. $ cd ttrss-raspberry-pi/
4. $ puppet apply --modulepath modules/:extmodules/ --verbose  manifests/site.pp
5. Grab a cup of coffee (puppet run will consume about ~20 minutes depending on network and SD-card performance)
6. Visit [http://raspberrypi.local/ttrs](http://raspberrypi.local/ttrss)

(Install has been verified on [Raspbian](http://www.raspbian.org/), but will probably work on other distributions and on non-rasberry platforms too).
