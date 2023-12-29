# Continuous integration with `cuirass`
The following instructions explain how to get the `cuirass`continuous integration server
up and running on a system using `guix` as a foreign package manager and running the `systemd`
init system.

## Installation
It is advisable to create a dedicated user to run the `cuirass` server
```bash
sudo useradd -m -s /usr/sbin/nologin cuirass
```
Note that creating a home directory allows the `cuirass` user to leverage `guix` to install
software. Using `nologin` as the default shell reflects the fact that apart for the purpose of
occasional maintenance, there is no need to login as the `cuirass` user.


Switch to the `cuirass` user and install local version of `guix`
```bash
sudo su cuirass -s/bin/bash
guix pull
GUIX_PROFILE=$HOME/.config/guix/current/profile source ${GUIX_PROFILE}/etc/profile
```
Sourcing the profile updates the local version of `guix` to the path

We can now use `guix` to install `cuirass`
```bash
sudo su cuirass -s/bin/bash
guix install cuirass
GUIX_PROFILE=$HOME/.guix-profile source ${GUIX_PROFILE}/etc/profile
```
Sourcing the profile adds the directory of `guix` managed executables to the path.

Depending on how profiles are configured on your system, you may have to put the above in
`/home/cuirass/.bashrc` to automate the environment settings for future login.


## Database configuration
By default `cuirass` uses `postgresql` as a database backend for storing artifacts assoicated
with the continuous integration. A quickstart guide on how to get `postgresql` up and running is
provided [elsewhere](postgresql.md). Here, we will focus on how to configure a running `postgresql`
server as a `cuirass`backend. All we need is to create a `cuirass` user and a `cuirass` database
owned by that user. One way of doing this is to call `psql` as the `postgres` user to get an
interactive admin shell to the `postgresql` server
```bash
sudo systemctl start postgresql
sudo su postgres -s/bin/bash
psql
```
and subsequently execute the following sql-queries
```
CREATE USER cuirass;
CREATE DATABASE cuirass OWNER cuirass;
QUIT;
```

## Testing `cuirass` services
Before we can start a `cuirass` service, we have to make sure that the folder `/var/run/cuirass` exists
and that it is owned by the `cuirass` user and group
```bash
sudo mkdir /var/run/cuirass
sudo chown -R cuirass:cuirass /var/run/cuirass
```

The continuous integration server can now be  started with
```
sudo su cuirass -s/bin/bash
cuirass register --specifications <specs>
```
We will discuss the specifications file in more detail below, but for initial testing we can
simply omit it. A web interface to the continuous integration server is also available
```
sudo su cuirass -s/bin/bash
cuirass web --listen=<host> --port=<port>
```
Note that the continous integration server must be started before the web server as the 
former creates a socket at `/var/run/cuirass/bridge` to which the latter must connect. The
`listen` and `port` options specify which interface to monitor incoming http requests.
Defaultas are `localhost` and `8080`, respectively.

## Creating services
Cuirass offers several services. Here we are only interested in the ci and web services. In the
following we provide minimalistic `systemd` service files that you can copy to the 
`/etc/systemd/system` folder.

### cuirass-ci
We first create a `cuirass-ci` service and make sure it depends on the `postgresql` service
```
[Unit]
Description=Cuirass CI server
Requires=postgresql.service

[Service]
User=cuirass
RuntimeDirectory=cuirass
ExecStart=/home/cuirass/.guix-profile/bin/cuirass register

[Install]
WantedBy=multi-user.target
```

In order to verify that everything works as expected:
- Reload the `systemd` daemon
- Stop the `postqresql` service
- Start the `cuirass-ci` service
- Verify that the `postgresql` service was started
- Stop the `cuirass-ci` service
```
sudo systemctl daemon-reload

sudo systemctl stop postgresql
sudo systemctl status postgresql

sudo systemctl start cuirass-ci
sudo systemctl status cuirass-ci

sudo systemctl status postgresql

sudo systemctl stop cuirass-ci
sudo systemctl status cuirass-ci
```

### cuirass-web
Next, we create a `cuirass-web` service which provides a web-based frontend to `cuirass-ci` 
and make sure that it depends on the `cuirass-ci` service
```
[Unit]
Description=Cuirass web server
Requires=cuirass-ci.service
After=cuirass-ci.service

[Service]
User=cuirass
ExecStart=/home/cuirass/.guix-profile/bin/cuirass web --listen <host>
Restart=always

[Install]
WantedBy=multi-user.target
```

In order to verify that everything works as expected:
- Reload the `systemd` daemon
- Stop the `cuirass-ci` service
- Stop the `postqresql` service
- Start the `cuirass-web` service
- Verify that you can access the web interface at `<host>:<port>`
- Verify that the `postgresql` service was started
- Verify that the `cuirass-ci` service was started
- Stop the `cuirass-web` service
```
sudo systemctl daemon-reload

sudo systemctl stop cuirass-ci
sudo systemctl status cuirass-ci

sudo systemctl stop postgresql
sudo systemctl status postgresql

sudo systemctl start cuirass-web
sudo systemctl status cuirass-web

sudo systemctl status postgresql
sudo systemctl status cuirass-ci

sudo systemctl stop cuirass-web
sudo systemctl status cuirass-web
```

## References
- https://othacehe.org/building-your-own-channels.html



