This file is for you to describe the munkireport application. Typically
you would include information such as the information below:

Installation and Setup
======================

Make sure you're using system Python 2.6 on Mac OS X 10.6.

Install virtualenv:
> $ easy_install virtualenv

To avoid installing all dependencies in the system, create a virtual
environment to run MunkiReport:
> $ mkdir ~/Library/Python   (or wherever)
> $ cd ~/Library/Python
> $ virtualenv --no-site-packages -p python2.6 tg21env

Activate the virtualenv:
> $ source ~/Library/Python/tg21env/bin/activate

Install MunkiReport:
> (tg2env)$ easy_install MunkiReport-x.y.z_rXXX-py2.6.egg

Now edit production.ini, providing a secret string where indicated (two
places, same string, uuidgen is a quick and easy way to generate one). For
clients to be able to connect to the server you'll also need to enter the
public IP address of your server (but 127.0.0.1 is fine for development and
local testing).

Create a user for yourself using bin/mkuser.py. You can also log in using a
regular Mac OS X user (AD/OD or local), but you'll want https for that.
Add your user to group.ini to get the proper permissions (viewers can view
reports, admins can edit the db).

Then you can set up the sqlite db:
> (tg2env)$ paster setup-app production.ini

Start the server with:
> (tg2env)$ paster serve --reload development.ini

Under scripts/ you'll find preflight and postflight scripts. Edit the URL and
distribute it to your clients running munki. Run ./make_script_dmg.sh to
create a dmg that distributes the scripts with munki.
