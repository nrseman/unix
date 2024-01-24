# Running a local git server
For those of us that develop code for work or pleasure, `git` has become an indispensible
tool. Distributed version control is a powerful thing, and among its key advantages is
that there is very little difference between a `git server` and a local copy of the same
repository created by `git clone`. As we start to accmulate repositories, most of us
organize them into a folder structure. For those of us who use text-based editors, this
allows us to do all or work, i.e. editing, compiling, debugging, and testing in the 
terminal. However, there are times when we secretly miss some of the features that
web-based git hosts provide. Personally, I would like a way of verifying that my
markdown files render properly before I push them upstream. In the following we will
describe how `cgit`, a minimalistic web interface adopted by GNU/Linux can serve as
an inteface to your local `git` repositories.

## Configuring a web server 

```
server.document-root = "/home/kjetil/" 

server.port = 80
server.username = "kjetil"
server.groupname = "kjetil"

server.modules += ( "mod_cgi", "mod_rewrite", "mod_setenv", "mod_alias" )

$HTTP["host"] =~ "^(www\.)?git.haugen.home" {

    setenv.add-environment += ( "CGIT_CONFIG" => "/home/kjetil/cgit.conf" )
    server.document-root    = "/home/kjetil/.guix-profile/lib/cgit"

    index-file.names        = ( "cgit.cgi" )
    cgi.assign              = ( "cgit.cgi" => "" )
    mimetype.assign         = (     ".css" => "text/css" )
    alias.url              += (  "/share/" => "/home/kjetil/.guix-profile/share/cgit/" )
    url.rewrite-once        = (
                            "^/share/.*"  => "",
        "^/([^?/]+/[^?]*)?(?:\?(.*))?$"   => "/cgit.cgi?url=$1&$2",
    )
}
```

### /etc/cgit/cgitrc
```
css=/cgit/cgit-highlight.css
logo=/cgit/cgit.png
source-filter=/usr/lib/cgit/filters/syntax-highlighting3.sh
enable-git-config=1
enable-index-owner=0
enable-commit-graph=1
enable-index-links=1
enable-log-linecount=1
enable-log-filecount=1
#cache-size=512
robots=noindex, nofollow
root-title=Dhole's git repositories
root-desc=my personal repositories
remove-suffix=1
clone-prefix=https://lizard.kyasuka.com/cgit/cgit.cgi ssh://git@lizard.kyasuka.com:
scan-path=/mnt/distk/git/pub/
```


### /etc/lighttpd/cgit.conf
```
server.modules += ("mod_redirect",
                   "mod_alias",
                   "mod_cgi",
                   "mod_fastcgi",
                   "mod_rewrite",
                   "mod_alias",)

var.webapps = "/usr/share/webapps/"
$HTTP["url"] =~ "^/cgit" {
        setenv.add-environment += ( "CGIT_CONFIG" => "/etc/cgit/cgitrc" )
        server.document-root = webapps
        server.indexfiles = ("cgit.cgi")
        cgi.assign = ("cgit.cgi" => "")
        mimetype.assign = ( ".css" => "text/css" )
}
url.redirect = (
        "^/git/(.*)$" => "/cgit/cgit.cgi/$1",
)
```

### lighttpd.conf 
```
server.modules += ( "mod_cgi", "mod_rewrite" )

#$SERVER["socket"] == ":443" {
$SERVER["socket"] == ":80" {
    #ssl.engine                    = "enable"
    #ssl.pemfile                   = "/etc/lighttpd/ssl/git.example.com.pem"

    server.name          = "git.example.com"
    server.document-root = "/usr/share/webapps/cgit/"

    index-file.names     = ( "cgit.cgi" )
    cgi.assign           = ( "cgit.cgi" => "" )
    mimetype.assign      = ( ".css" => "text/css" )
    url.rewrite-once     = (
        "^/cgit/cgit.css"   => "/cgit.css",
        "^/cgit/cgit.png"   => "/cgit.png",
        "^/([^?/]+/[^?]*)?(?:\?(.*))?$"   => "/cgit.cgi?url=$1&$2",
    )
}
```

### References
- https://dhole.github.io/post/raspberry_pi_git
- https://wiki.archlinux.org/title/cgit
- https://redmine.lighttpd.net/projects/1/wiki/TutorialConfiguration 
