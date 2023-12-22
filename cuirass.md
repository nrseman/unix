# Continuous integration with `guix`

## `cuirass`

### Installation
It is advisable to run `cuirass` server as a dedicated user
```bash
sudo useradd -m -s /bin/bash cuirass
```
Switch to `cuirass` user and install `cuirass`
```bash
sudo su cuirass
guix pull
guix install cuirass
```
You may have to update your environment after installation
```bash
GUIX_PROFILE=$HOME/.guix-profile
. ${GUIX_PROFILE}/etc/profile
```
Depending on how profiles are configured on your system, you may have to put the above in
`/home/cuirass/.bashrc` to automate the environment setting for future login.

### Socket directory
Before we can start a `cuirass` service, we have to make sure that the folder `/var/run/cuirass` exists
and that it is owned by the `cuirass` user and group
```bash
sudo mkdir /var/run/cuirass
sudo chown -R cuirass:cuirass /var/run/cuirass
```

### Database configuration
By default `cuirass` uses `postgresl` as a database backend for storing artifacts assoicated
with the continuous integration. A quickstart guide on how to get `postgresql` up and running is
provided below. Here, we will focus on how to configure a running `postgresql` server as a `cuirass`
backend. All we need is to create a `cuirass` user and a `cuirass` database owned by that user.
One way of doing this is to call `psql` as the `postgres` user to get an interactive admin shell to
the `postgresql` server
```bash
sudo su postgres
psql
```
and subsequently execute the following sql-queries
```
CREATE USER cuirass;
CREATE DATABASE cuirass OWNER cuirass;
```

### Starting `cuirass` services
The continuous integration server is started with
```
cuirass register --specifications <specs>
```
We will discuss the specifications file in more detail below, but for initial testing we can
simply omit it. A web interface to the continuous integration server is also availble
```
cuirass web
```
Note that the continous integration server must be started before the web server as the 
former creates a socket at `/var/run/cuirass/bridge` to which the latter must connect. 


## `postgresql`

### Installation
It is advisable to run `postgresql` server as a dedicated user
```bash
sudo useradd -m -s /bin/bash postgres
```

Switch to `postgres` user and install `postgresql`
```bash
sudo su postgres
guix pull
guix install postgresql
```
You may have to update your environment after installation
```bash
GUIX_PROFILE=$HOME/.guix-profile
. ${GUIX_PROFILE}/etc/profile
```
Depending on how profiles are configured on your system, you may have to put the above in
`/home/postgresql/.bashrc` to make the environment updated permanent.


### Initialization

Create and initialize a folder where the database cluster will be stored
```bash
sudo su postgres
mkdir /home/postgres/data
initdb -D /home/postgres/data --no-locale
```
Without the `--no-locale` option, `postgresql` will use the default locale of your system. You
can specify any supported locale with the `--locale=<locale>`option. Note that `initdb` may fail
without the `--no-locale` option unless `guix` locale support is intalled (more on that below).

### Server management
Before we can start the server, we have to make sure that the folder `/var/run/postgres` exists
and that it is owned by the `postgres` user and group
```bash
sudo mkdir /var/run/postgresql
sudo chown -R postgres:postgres /var/run/postgresql
```
The server can now be started with `pg_ctl start`
```bash
pg_ctl start -D /home/postgres/data -l logfile
```
Similarly, the server can be stopped with `pg_ctl stop`
```bash
pg_ctl stop  -D /home/postgres/data
```
There are several other `pg_ctl` subcommands.

###  Locales
`postgresql` supports locales, but it will not work unless `guix` locale support is installed
```bash
guix install glibc-locales
```
Once again, you may have to update your environment after installation
```bash
GUIX_PROFILE=$HOME/.guix-profile
export GUIX_LOCPATH=${GUIX_PROFILE}/lib/locale
```
Depending on how profiles are configured on your system, you may have to put the above in
`/home/postgresql/.bashrc` to make the environment updated permanent.

### References
- https://www.postgresql.org/docs/current/runtime.html
- https://www.postgresql.org/docs/current/app-pg-ctl.html
- https://www.postgresql.org/docs/current/managing-databases.html
- https://www.postgresql.org/docs/current/user-manag.html
