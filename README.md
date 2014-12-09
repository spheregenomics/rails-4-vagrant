Rails 4 on Ruby 2.1.2 for Vagrant
=======================================

This Vagrant setup makes it fast & easy for you to get started making your Rails 4 application.


Usage
-----

```
    $ git clone git@github.com:spheregenomics/rails-4-vagrant.git <app_name>
    $ cd <app_name>
    $ vagrant up
    $ vagrant ssh
    $ cd /vagrant/rails-4-app
    $ rails s
```

You can now view your application in [http://localhost:8080/](http://localhost:8080/).  
The source code for your application is in the <app_name> folder; you can edit it there.  

#### Installing a New Application with Rails Apps Composer

```
$ cd /vagrant
$ rm -rf rails-4-app
$ sudo -u postgres psql -d postgres
postgres=# create user vagrant with password 'vagrant';
postgres=# alter user vagrant with superuser;
$ dropdb rails_4_db
$ rails new <app_name> -m https://raw.github.com/RailsApps/rails-composer/master/composer.rb
```
   
