## Postgresql
It is advisable to run `postgreql` server as dedicated user
```
sudo useradd -m -s /bin/bash postgres
```

Switch to `postgres` user and install `postgresql`
```
sudo su postgres
guix pull
guix install postgresql
```

If necessary install guix locale support
```
guix install glibc-locales
```
and configure the appropriate environment variables, and make sure that
the environment is properly set up by sourcing the following at every 
`postgresql` user login, e.g. by adding to `/home/postgresql/.bashrc`

```
GUIX_PROFILE=$HOME/.guix-profile
source ${GUIX_PROFILE}/etc/profile
export GUIX_LOCPATH=${GUIX_PROFILE}/lib/locale
```

Initialize the folder where the database cluster will be stored
```
sudo su postgres
mkdir /home/postgres/data
initdb -D /home/postgres/data --no-locale
```

Starting the server
```
pg_ctl start -D /home/postgres/data -l logfile
```

https://www.postgresql.org/docs/current/runtime.html
