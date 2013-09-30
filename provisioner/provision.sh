#!/usr/bin/env bash
#
# Provisions an Ubuntu server with Rails 4, on Ruby 2.0.0, running on Nginx + Unicorns.
#
# Requires:
#  - sudo privileges
#  - some Ruby pre installed & ERB 
#
# Note: if you define de GIT_REPO variable you'll need to pre-install deployment keys or use
# ssh agent forwarding. Your installation might also pause before checking out the source code
# due to StrictHostKeyChecking.
#
# Also, don't forget to create and use an admin user in the server before running the script.
# Don't run this as the root user itself.


# make script halt on failed commands
set -e

# protect against execution as root
if [ "$(id -u)" == "0" ]; then
   echo "Please run this script as a regular user with sudo privileges." 1>&2
   exit 1
fi


# =============================================================================
#   Variables
# =============================================================================

# read variables from .env file if present
if [[ -e ./.env ]]; then
  . ./.env
  echo "(.env file detected and sourced)"
fi

# log file receiving all command output
PROVISION_TMP_DIR=${PROVISION_TMP_DIR:-"/tmp/rails-4-provisioner"}
LOG_FILE=$PROVISION_TMP_DIR/provision-$(date +%Y%m%d%H%M%S).log

# set Rails environment
export RAILS_ENV=${RAILS_ENV:-"production"}

# name of the Rails application to be installed
export APP_NAME=${APP_NAME:-"rails-4-app"}

# application's database details
export APP_DB_NAME=${APP_DB_NAME:-"rails_4_db"}
export APP_DB_USER=${APP_DB_USER:-"rails_4_user"}
export APP_DB_PASS=${APP_DB_PASS:-"d0_n07_U53_Th15"} # you should provide your own password
export APP_INSTALL_DIR=${APP_INSTALL_DIR:-"/srv/webapps/$APP_NAME"}

echo "Provisioning for application: ${APP_INSTALL_DIR}, environment: ${RAILS_ENV}"


# =============================================================================
#   Bootstrap
# =============================================================================

# create the output log file
mkdir -p $PROVISION_TMP_DIR
touch $LOG_FILE
echo "Logging command output to $LOG_FILE"

# update packages and install some dependencies and tools
echo "Updating packages..."
{
  sudo apt-get update
  sudo apt-get -y install build-essential zlib1g-dev curl libcurl4-openssl-dev git-core software-properties-common
} >> $LOG_FILE 2>&1


# =============================================================================
#   Database (PostgreSQL)
# =============================================================================

# install PostgreSQL
echo "Installing PostgreSQL..."
sudo apt-get -y install postgresql postgresql-contrib libpq-dev >> $LOG_FILE 2>&1

# change the default template encoding to utf8 or else Rails will complain
echo "Converting default database template encoding to utf8..."
sudo -u postgres psql < pg_utf8_template.sql >> $LOG_FILE 2>&1

# create application's database user
echo "Creating application's database user..."
erb pg_create_app_user.sql.erb > $PROVISION_TMP_DIR/pg_create_app_user.sql.repl
sudo -u postgres psql < $PROVISION_TMP_DIR/pg_create_app_user.sql.repl >> $LOG_FILE 2>&1


# =============================================================================
#   Javascript Runtime (Node.js)
# =============================================================================

# install node.js as a javascript runtime for rails
echo "Installing Node.js as the javascript runtime..."
{
  sudo apt-get -y install python-software-properties python
  sudo add-apt-repository -y ppa:chris-lea/node.js
  sudo apt-get update
  sudo apt-get -y install nodejs
} >> $LOG_FILE 2>&1


# =============================================================================
#   Install Ruby 2
# =============================================================================

if [[ -z $(ruby -v | grep 2.0.0) ]]; then
  # get Ruby source
  echo "Fetching ruby 2.0.0..."
  {
    wget http://cache.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p247.tar.gz
    tar xzf ruby-2.0.0-p247.tar.gz
  } >> $LOG_FILE 2>&1

  # build it
  cd ruby-2.0.0-p247
  echo "Building ruby 2.0.0..."
  {
    ./configure
    make
    sudo make install
    sudo gem update --system --no-document
  } >> $LOG_FILE 2>&1

  # install Rails 4
  echo "Installing Rails 4..."
  sudo gem install rails --version 4.0.0 --no-document >> $LOG_FILE 2>&1

  # cleanup
  cd ..
  rm -rf ruby-2.0.0-p247*
fi


# =============================================================================
#   Web Server (Nginx + Unicorn)
# =============================================================================

# create deployment user and group
echo "Setting up deployment user and group..."
{  
  sudo useradd -s /sbin/nologin -r deploy
  sudo groupadd -f deploy
  sudo usermod -a -G deploy deploy

  # add ourselves to the deploy group to facilitate maintenance
  sudo usermod -a -G deploy $(whoami)
} >> $LOG_FILE 2>&1


# install and setup Nginx
echo "Installing Nginx..."

erb confs/nginx.conf.erb > $PROVISION_TMP_DIR/nginx.conf.repl

{
  sudo apt-get -y install nginx

  # add config for Nginx
  sudo cp $PROVISION_TMP_DIR/nginx.conf.repl /etc/nginx/nginx.conf

  # stop and remove Nginx service
  sudo /etc/init.d/nginx stop
  sudo update-rc.d -f nginx remove
} >> $LOG_FILE 2>&1


# install Unicorn
echo "Installing Unicorn..."

erb confs/unicorn.rb.erb > $PROVISION_TMP_DIR/unicorn.rb.repl

{
  sudo gem install unicorn --no-document

  # add Unicorn config
  sudo mkdir -p -m 775 /etc/unicorn/
  sudo cp $PROVISION_TMP_DIR/unicorn.rb.repl /etc/unicorn/unicorn.rb
  sudo chown -R deploy:deploy /etc/unicorn/
} >> $LOG_FILE 2>&1


# install Monit which will manage processes
echo "Installing Monit..."

erb confs/app.monitrc.erb > $PROVISION_TMP_DIR/app.monitrc.repl

{
  sudo apt-get -y install monit

  sudo cp $PROVISION_TMP_DIR/app.monitrc.repl /etc/monit/conf.d/app.monitrc
  sudo chmod 700 /etc/monit/conf.d/app.monitrc

  # manage Monit with Upstart
  sudo /etc/init.d/monit stop
  sudo update-rc.d -f monit remove
  sudo cp confs/monit.upstart.conf /etc/init/monit.conf
} >> $LOG_FILE 2>&1


# =============================================================================
#   Install Rails App
# =============================================================================

# create the application install directory
sudo mkdir -p $APP_INSTALL_DIR
sudo chown -R $(whoami) $APP_INSTALL_DIR
cd $APP_INSTALL_DIR

# install rails application
if [[ ! -z $GIT_REPO ]]; then
  echo "Cloning application's repository..."
  git clone $GIT_REPO . >> $LOG_FILE 2>&1
fi

# install application's gems
echo "Installing application's gems..."
bundle install >> $LOG_FILE 2>&1

# create database
echo "Initializing application's database..."
{
  bundle exec rake db:create
  bundle exec rake db:schema:load
} >> $LOG_FILE 2>&1


# =============================================================================
#   Fire Up the Machinery
# =============================================================================

# create tmp directory for pid files
mkdir -p tmp

# let's just make git ignore the filemode changes that will occur next
git config core.filemode false

# ensure access to the application installation directory
sudo chown -R deploy:deploy $APP_INSTALL_DIR
sudo chmod -R 775 $APP_INSTALL_DIR

# go!
echo "Starting server..."
sudo start monit >> $LOG_FILE 2>&1

echo "Provisioning completed successfully!"
exit 0

