#!/usr/bin/env bash
#
# Provisions an Ubuntu server with Rails 4, on Ruby 2.0.0, for a development environment.
#
# Requires:
#  - sudo privileges
#  - some Ruby pre installed & ERB 


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
export RAILS_ENV="development"

# name of the Rails application to be installed
export APP_NAME=${APP_NAME:-"rails-4-app"}

# application's database details
export APP_DB_NAME=${APP_DB_NAME:-"rails_4_db"}
export APP_DB_USER=${APP_DB_USER:-"rails_4_user"}
export APP_DB_PASS=${APP_DB_PASS:-"cH4nG3_p455w0rD"} # you should provide your own passwords

export APP_TEST_DB_NAME=${APP_TEST_DB_NAME:-"rails_4_db_test"}
export APP_TEST_DB_USER=${APP_TEST_DB_USER:-"rails_4_user_test"}
export APP_TEST_DB_PASS=${APP_TEST_DB_PASS:-"cH4nG3_p455w0rD_test"}

# folder where the application will be installed
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
sudo -u postgres psql < templates/sql/pg_utf8_template.sql >> $LOG_FILE 2>&1

# create application's database user
echo "Creating application's database users..."
erb templates/sql/pg_create_app_users.sql.erb > $PROVISION_TMP_DIR/pg_create_app_users.sql.repl
sudo -u postgres psql < $PROVISION_TMP_DIR/pg_create_app_users.sql.repl >> $LOG_FILE 2>&1


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
#   Install Rails App
# =============================================================================

cd $APP_INSTALL_DIR

# install application's gems
echo "Installing application's gems..."
bundle install >> $LOG_FILE 2>&1

# create databases
echo "Initializing application's database..."
{
  bundle exec rake db:create
  bundle exec rake db:schema:load
} >> $LOG_FILE 2>&1

echo "Provisioning completed successfully!"
exit 0

