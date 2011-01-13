MunkiReport
===========


Requirements
------------

MunkiReport has been developed with system Python 2.6 on Mac OS X 10.6.

virtualenv is required, to avoid cluttering the system Python install with
modules. Install it with easy_install if needed:

    $ easy_install virtualenv


Installation
------------

Untar the distribution, cd to it, and run setup.sh. This will create a virtual
environment, install the MunkiReport module, create a config file, an admin
user (with permission to admin and view reports), and create an empty database.

    $ tar jxf MunkiReport-x.y.z.XXX.tar.bz2
    $ cd MunkiReport-x.y.z.XXX/
    $ ./setup.sh
    Checking virtualenv...
    Checking for PyPI access...
    Checking virtual environment...
    Creating virtual environment...
    Activating virtual environment
    Installing egg into virtual environment...
    Creating production.ini...
    Creating munkireport admin user...
    Username:  <- enter username (e.g. "munkireport")
    Real name: <- enter human readable name (e.g. "MunkiReport Admin")
    Password:  <- enter password
    Creating groups.ini...
    Creating database...
    Setup done. The server can be started with ./start.sh.
    $ 


Testing the server
------------------

Start the server with `./start.sh` and point your browser to
`http://your.external.ip.or.hostname:8444/` and you should be greeted with a
link to view reports. Click it and log in as the user you created during setup.
Distribute the reporting scripts to your clients (see below), do a munki run,
and their reports should start showing up.


Adding clients
--------------

Under scripts/ you'll find preflight, postflight and report_broken_client
scripts. Edit the URL to point to your MunkiReport server. To wrap them in a
dmg for distribution, run:

    $ ./make_script_dmg.sh

The resulting dmg and package info can be added to your Munki repository, and
your clients will automatically install the scripts and start submitting their
reports.


Adding a LaunchDaemon
---------------------

TODO: add launchd instructions.


Configuring logging
-------------------

TODO: add logging instructions.


Adding users, and using AD/OD
-----------------------------

By default, MunkiReport authenticates users against both the local `etc/users`
file, and with Directory Services. To add more local users, run:

    $ bin/mkuser.py

Open `etc/groups.ini` and add this user to the appropriate groups (admins can
admin the database, viewers can view reports).

You can also add regular Mac OS X users (including AD and OD users) to
`etc/groups.ini`.

You can also add a group of users to `etc/permissions.ini`. For example, if
your IT staff is in the active directory group APPLE\IT-staff, and you want
all of them to be able to view Munki reports, simply grant it [view]
permission:

    [admin]
    admins
    
    [view]
    viewers
    APPLE\IT-staff

TODO: verify that group names with backslash and space works.
