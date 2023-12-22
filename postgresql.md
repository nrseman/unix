# `postgresql`
SQL databases are the backbone of many services and `postgreql` is among the most popular options
available. A key motivation to learn how to install and configure `postgresql` is because it is the
default backend for `cuirass`, a continuous integration system built on top of `guix`. While the
instructions below are `guix` specific, they are easily adapted to alternative was of getting
`postgresql` up and running


## Installation
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


## Initialization

Create and initialize a folder where the database cluster will be stored
```bash
sudo su postgres
mkdir /home/postgres/data
initdb -D /home/postgres/data --no-locale
```
Without the `--no-locale` option, `postgresql` will use the default locale of your system. You
can specify any supported locale with the `--locale=<locale>`option. Note that `initdb` may fail
without the `--no-locale` option unless `guix` locale support is installed (more on that below).


## Server management
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
Note that the `-D` argument can be dropped if we set the `PGDATA` environment variable
```bash
export PGDATA=/home/postgres/data
```
Similarly, the `-l` argument can be dropped if we set the `PGLOG` environment variable
```bash
export PGLOG=/home/postgres/logfile
```
There are several other `pg_ctl` subcommands.


##  Locales
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


## References
- https://www.postgresql.org/docs/current/runtime.html
- https://www.postgresql.org/docs/current/app-pg-ctl.html
- https://www.postgresql.org/docs/current/managing-databases.html
- https://www.postgresql.org/docs/current/user-manag.html
