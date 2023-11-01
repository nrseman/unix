# Installing guix

- Install
```
sudo apt-get update
sudo apt install guix
```

- Upgrade
```
guix pull
. "$HOME/.config/guix/current/etc/profile" (obsolete)
. /etc/profile.d/guix.sh (preferred)
hash guix ?
```

- Update build daemon
```
sudo -i guix pull
sudo systemctl restart guix-daemon.service
```

- Relocate `/gnu/store`


- Invoke time-machine
```
guix describe -f channels-sans-intro >> test.scm
guix time-machine -- install test
```
