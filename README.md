Rails 4 on Unicorns & Nginx for Vagrant
=======================================

This setup gets you a Rails 4 production stack running in a development environment.
Great if you run Unicorn + Nginx in production and are looking to [keep your dev and
production environments similar][4].

Also works great if you just want to get started making your Rails 4 application.


Usage
-----

    $ git clone git@github.com:santos-bt/rails-4-vagrant.git
    $ cd rails-4-vagrant
    $ vagrant up

You can now view your application in [http://localhost:8300/](http://localhost:8300/).  
The source code for your application is in the `rails-4-app` folder; you can edit it there.  
To restart the application run `sudo monit restart unicorn` inside the Virtual Machine.


Requires
--------

* [Virtual Box][1]
* [Vagrant][2]


Notes
-----

This setup uses the [Rails 4, Nginx & Unicorn Installation Script for Ubuntu][3].
Check the script's GitHub page for more information about the stack and configuration options.

The pre-generated app in the `rails-4-app` folder is the result of running `rails new rails-4-app`
and then modifying the Gemfile and database.yml to use the PostgreSQL database.

If you wish to rename the application you can simply delete the `/vagrant/rails-4-app` folder, 
generate a new Rails application from scratch and then modify the database details.


Compatibility
-------------

Tested on Vagrant 1.3.3 and Virtual Box 4.2.12.


License
-------

MIT License.


Contributing
------------

Go ahead and submit a Pull Request. Thank you!


Related Reading
---------------
* [Keep development, staging, and production as similar as possible (12factor)][4]


[1]: https://www.virtualbox.org/
[2]: http://www.vagrantup.com/
[3]: https://github.com/santos-bt/rails-4-provisioner
[4]: http://12factor.net/dev-prod-parity "Keep development, staging, and production as similar as possible - The 12 Factor App"