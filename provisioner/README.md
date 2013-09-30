Rails 4, Nginx & Unicorn Installation Script for Ubuntu
=======================================================

This provisioning script will install a Rails 4 application, running on Ruby 2.0.0, 
served by Unicorns behind Nginx on your Ubuntu server.


Usage
-----

    $ git clone git@github.com:santos-bt/rails-4-provisioner.git
    $ cd rails-4-provisioner
    $ cp example.env .env
    $ vim .env # change variables to your app's settings
    $ ./provision.sh


Requires
--------

* user with sudo privileges (but not the root user itself)
* some Ruby preinstalled
* ERB


Notes
-----

The script tries reading values from environment variables. If a .env file exists it is 
sourced at the beginning of the script.

Default values are defined for all variables except `GIT_REPO`. If `GIT_REPO` is not defined 
it is assumed the application's source is already in `APP_INSTALL_DIR`.

Also, if you define de `GIT_REPO` variable don't forget to pre-install deployment keys or use
ssh agent forwarding. Your installation might also pause before checking out the source code
due to `StrictHostKeyChecking` ([see workaround][1]).


What Exactly is Going on my Server
----------------------------------

Ok, so here's the list of software installed by this script:

* Ruby 2.0.0-p247
* Rails 4
* Node.js (for the javascript runtime)
* PostgreSQL
* Nginx
* Unicorn
* Monit
* Git

And some more details:

* __PostgreSQL:__ besides the standard installation from the package repository, the application's
database user is created for you and the default database template is converted to UTF-8.

* __Nginx:__ installed server-wide, writes log files to `APP_INSTALL_DIR/log`.

* __Unicorn:__ installed server-wide, writes log files to  `APP_INSTALL_DIR/log`. Also connects
with Nginx via Unix socket in `APP_INSTALL_DIR/tmp`.

* __Monit:__ keeps Nginx and Unicorn alive. Monit itself is kept alive by Upstart. After provisioning
you'll be able to start/stop/restart nginx/unicorn with:
    
    `$ sudo monit start/stop/restart nginx/unicorn`
    

Vagrant
-------

Coming soon.


Compatibility
-------------

Tested on Ubuntu 12.04 LTS and 13.04, 32bit.


License
-------

MIT License.


Contributing
------------

Go ahead and submit a Pull Request. Thank you!


Related Reading ?
-----------------
* [Setting up Unicorn with Nginx][2]
* [Store config in the environment (12factor)][3]


[1]: http://debuggable.com/posts/disable-strict-host-checking-for-git-clone:49896ff3-0ac0-4263-9703-1eae4834cda3 "SSH StrictHostKeyChecking Workaround"
[2]: http://sirupsen.com/setting-up-unicorn-with-nginx/ "Setting up Unicorn with Nginx"
[3]: http://12factor.net/config "Store config in the environment - The 12 Factor App"