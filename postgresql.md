# `postgresql`
SQL databases are the backbone of many services and `postgreql` is one of the most popular options
available. A key motivation to learn how to install and configure `postgresql` is because it is the
default backend for `cuirass`, a continuous integration system built on top of `guix`. The instructions
below targets systems using `systemd` and where `guix` is used as a foreign package manager.


## Installation
We start by creating a dedcated `postgres` user to run the  `postgresql` server
```bash
sudo useradd -m -s /usr/sbin/nologin postgres
```
Note that creating a home directory allows the `postgres` user to leverage `guix` to install
software. Using `nologin` as the default shell reflects the fact that apart for the purpose of
occasional maintenance, there is no need to login as the `postgres` user.

Switch to `postgres` user and install local version of `guix`
```bash
sudo su postgres -s/bin/bash
guix pull
GUIX_PROFILE=$HOME/.config/guix/current/profile source ${GUIX_PROFILE}/etc/profile
```
Sourcing the profile updates the local version of `guix` to the path

We can now use `guix` to install `postgresql`
```bash
sudo su postgres -s/bin/bash
guix install postgresql
GUIX_PROFILE=$HOME/.guix-profile source ${GUIX_PROFILE}/etc/profile
```
Sourcing the profile adds the directory of `guix` managed executables to the path.

Depending on how profiles are configured on your system, you may have to put the above in
`/home/postgres/.bashrc` if you want to make the above environment updates permanent.


## Initialization
`postgresql` supports locales, but it will not work unless `guix` locale support is installed
```bash
guix install glibc-locales
```
Verify that the `GUIX_LOCPATH` environment variable is set. If not you can temporarily set it
to `~/.guix_profile/lib/locale`
```bash
export GUIX_LOCPATH=$HOME/.guix-profile/lib/locale
```

We are now ready to create and initialize a folder where the database cluster will be stored
```bash
sudo su postgres -s/bin/bash
mkdir /home/postgres/data
initdb -D /home/postgres/data
```
Without arguments,initdb will configure `postgresql` to use the default locale of your system. You
can specify any supported locale with the `--locale=<locale>`option, or turn off locale support
entirely with the `--no-locale` option. In the latter case, installing and configuring your environment
for `glibc-locales` is superfluous.


## Testing the server
Before we can start the server, we have to make sure that the folder `/var/run/postgres` exists
and that it is owned by the `postgres` user and group
```bash
sudo mkdir /var/run/postgresql
sudo chown -R postgres:postgres /var/run/postgresql
```
The server can now be started with `pg_ctl start`
```bash
sudo su postgres -s/bin/bash
pg_ctl start -D /home/postgres/data -l logfile
```
Similarly, the server can be stopped with `pg_ctl stop`
```bash
sudo su postgres -s/bin/bash
pg_ctl stop  -D /home/postgres/data
```
Note that the `-D` argument can be dropped if we set the `PGDATA` environment variable
```bash
sudo su postgres -s/bin/bash
export PGDATA=/home/postgres/data
```

## Creating a service
In practice, we do not want to managage the server manually. Below is a minimal
`postgreql.service` file that can be copied to `/etc/systemd/system`
```
[Unit]
Description=PostgreSQL database server

[Service]
Type=forking
User=postgres
RuntimeDirectory=postgresql
Environment=GUIX_LOCPATH=/home/postgres/.guix-profile/lib/locale
Environment=PGDATA=/home/postgres/data
ExecStart=/home/postgres/.guix-profile/bin/pg_ctl start
ExecStop=/home/postgres/.guix-profile/bin/pg_ctl stop
ExecReload=/home/postgres/.guix-profile/bin/pg_ctl reload

[Install]
WantedBy=multi-user.target
```
In order to verify that the service works as expected, you can run the following
commands
```
sudo systemctl daemon-reload
sudo systemctl start postgresql
sudo systemctl status postgresql
sudo systemctl stop postgresql
sudo systemctl status postgresql
```
If you want to make any changes, edit the `postgresql.service` file and rerun the
command above. Once you are satisfied, you can enable the sevice permanently by
executing.
```
sudo sytemctl enable postgresql
```
However, if you plan to use `postgresql` as a backend for other services, it is
better to configure those services to depend on `postgreql` instead.




## References
- https://www.postgresql.org/docs/current/runtime.html
- https://www.postgresql.org/docs/current/app-pg-ctl.html
- https://www.postgresql.org/docs/current/managing-databases.html
- https://www.postgresql.org/docs/current/user-manag.html
