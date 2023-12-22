# Cuirass -- A CI/CD system build on top of `guix`


## `postgresql`


### Installation
It is advisable to run `postgresql` server as dedicated user
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

###  Locales
Postgresql supports locales, but it will not work unless guix locale support is installed
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

### Initialization

Create and initialize a folder where the database cluster will be stored
```bash
sudo su postgres
mkdir /home/postgres/data
initdb -D /home/postgres/data --no-locale
```
Without the `--no-locale` option, `postgresql` will use the default locale of your system. You
can specify any supported locale with the `--locale=<locale>`option.

### Starting and stopping the server
Starting and stopping the server
```bash
pg_ctl start -D /home/postgres/data -l logfile
pg_ctl stop  -D /home/postgres/data
```

### Creating a user
```sql
CREATE ROLE name
```

### Creating a database
```sql
CREATE DATABASE cuirass
```

### References
- https://www.postgresql.org/docs/current/runtime.html
- https://www.postgresql.org/docs/current/app-pg-ctl.html
- https://www.postgresql.org/docs/current/managing-databases.html
- https://www.postgresql.org/docs/current/user-manag.html
