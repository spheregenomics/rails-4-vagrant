Rails 4 on Ruby 2.0.0 for Vagrant
=======================================

This Vagrant setup makes it fast & easy for you to get started making your Rails 4 application.


Usage
-----

    $ git clone git@github.com:santos-bt/rails-4-vagrant.git
    $ cd rails-4-vagrant
    $ vagrant up
    $ vagrant ssh
    $ cd /vagrant/rails-4-app
    $ rails s

You can now view your application in [http://localhost:8300/](http://localhost:8300/).  
The source code for your application is in the `rails-4-app` folder; you can edit it there.  


Requires
--------

* [Virtual Box][1]
* [Vagrant][2]


Notes
-----

This setup is based on the [Rails 4, Nginx & Unicorn Installation Script for Ubuntu][3] only it
doesn't install Nginx and Unicorn. What it actually does is:

* Install Ruby 2.0.0
* Install Rails 4
* Install Node.js (for the Javascript runtime)
* Install PostgreSQL
* Convert the default database template to UTF8
* Create development and test database users
* Install the application's gems
* Initialize databases

The pre-generated app in the `rails-4-app` folder is the result of running `rails new rails-4-app`
and then modifying the Gemfile and database.yml to use the PostgreSQL database.

If you wish to rename the application you can simply delete the `/vagrant/rails-4-app` folder, 
generate a new Rails application from scratch and then modify the database details.

If you have an existing application, before using the `vagrant up` command, replace the 
`/vagrant/rails-4-app` folder with you application's folder and adjust the variables in the 
`.env` file accordingly.


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