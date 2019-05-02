Requirements
------------

### Install RVM, it is compatible for bash shell only
NOTE: As RVM installation takes more than 800 MB space and may lead to space crunch in default user (/home/username/) directory, it is highly recommended to install it in some other directory within /scratch.
```sh
$ gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
 
$ \curl -sSL https://get.rvm.io | bash -s stable --path <custom_path_for_installation>
```
###  Install Ruby 2.1.4
```sh
$ rvm install 2.1.4
$ rvm use 2.1.4 --default
```
###  Install PostgreSQL
```sh
$ sudo apt-get install postgresql postgresql-contrib
```
### PostgreSQL configuration
Create *spp_user* and grant access to it,
```sh
$ sudo -i
$ su - postgres
$ psql
psql (9.3.17)
Type "help" for help.
postgres=# CREATE ROLE spp_user superuser;
postgres=# ALTER ROLE spp_user WITH LOGIN;
postgres=# GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO spp_user;
postgres=# GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO spp_user;
postgres=# GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO spp_user;
postgres=# GRANT ALL ON ALL TABLES IN SCHEMA public TO spp_user;
postgres=# \q
```
For password less login to database, Open the below file,

```sh
$ sudo vim /etc/postgresql/9.3/main/pg_hba.conf
```
  ( or )
```sh
$ sudo vim /etc/postgresql/<version>/main/pg_hba.conf
```
Add the following line (in green) just before below line in the pg_hba.conf file
```diff
# "local" is for Unix domain socket connections only
+ local   all             spp_user                                trust
  local   all             all                                     peer
```
Restart postgres,
```sh
$ sudo service postgresql restart
```

###   Install imagemagick
```sh
$ sudo apt-get install imagemagick
```
###   Install wkhtmltopdf 
```sh
$ sudo add-apt-repository ppa:ecometrica/servers
$ sudo apt-get install wkhtmltopdf
$ sudo ln /usr/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf
```
### Install Java 8
This is required for Elastic Search installation
```sh
$ sudo add-apt-repository ppa:webupd8team/java
$ sudo apt-get update
$ sudo apt-get install oracle-java8-installer
```
###   Install elasticsearch version 5.2.0 or above
- https://www.elastic.co/downloads/elasticsearch
- Download the Debian Package  file
- Go to the download directory and run,
```sh 
$ sudo dpkg -i elasticsearch-<version>.deb
```

Install Steps
-------------

###   Clone repo
```sh
$ git clone https://github.com/PrathamBooks/spp
```
###  Install bundler
```sh
$ sudo apt-get install bundler
$ gem install bundler
```
###   Rest of the comands to be executed in project directory
###  Install gems
```sh
$ bundle install
```
###   Create db
 ###   For developers
```sh
 $ bundle exec rake db:create
 $ bundle exec rake db:migrate
 $ bundle exec rake db:seed
 $ bundle exec rake db:seed:development:users
```
 ###   For non-developers
  - Restore from psql backup?
###  Index search engine
```sh
$ bundle exec rake searchkick:reindex:all
```
###   rake jobs
```sh
$ bundle exec rake jobs:work
```
###  Start server
```sh
$ rails s
```
or
```sh
$ puma
```

Point your browser to http://localhost:3000

### Known issues?
##### While installing gems via 'bundle install'
- Gem pg installation error while bundling, `Can't find the 'libpq-fe.h header`
Solution: 
```sh
$ sudo apt-get install libpq-dev
```
- `Can't install RMagick 2.13.4. Can't find MagickWand.h,`
Solution: 
```sh
$ sudo apt-get install libmagickwand-dev
```
- `*You must install libcouchbase >= 2.4.0`
```sh
$ wget http://packages.couchbase.com/releases/couchbase-release/couchbase-release-1.0-3-amd64.deb
$ sudo dpkg -i couchbase-release-1.0-3-amd64.deb
$ sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6EF1EAC479CF7903 
$ sudo apt-get update
$ sudo apt-get install libcouchbase-dev libcouchbase2-bin build-essential
```
#####  rspec failure
- Due to wrong version of wkhtmltopdf

```sh
RuntimeError:
       Error: Failed to execute:
       ["/usr/local/bin/wkhtmltopdf", "-q", "--no-pdf-compression", "--image-quality", "100", "--image-dpi", "3000", "--margin-top", "3", "--margin-bottom", "3", "--margin-left", "10", "--margin-right", "3", "--orientation", "Landscape", "--page-size", "A4", "--print-media-type", "file:///tmp/wicked_pdf20181009-22441-16shf0f.html", "/tmp/wicked_pdf_generated_file20181009-22441-4g3fx9.pdf"]
       Error: PDF could not be generated!
        Command Error: The switch --no-pdf-compression, is not support using unpatched qt, and will be ignored.The switch --image-quality, is not support using unpatched qt, and will be ignored.The switch --image-dpi, is not support using unpatched qt, and will be ignored.The switch --print-media-type, is not support using unpatched qt, and will be ignored.QXcbConnection: Could not connect to display
```
Solution is to install wkhtmltopdf (> 0.12) with patched qt
```sh
cd ~
wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.3/wkhtmltox-0.12.3_linux-generic-amd64.tar.xz
tar vxf wkhtmltox-0.12.3_linux-generic-amd64.tar.xz
cp wkhtmltox/bin/wk* /usr/local/bin/

And you can confirm with:
$ wkhtmltopdf --version
wkhtmltopdf 0.12.3 (with patched qt)
```
