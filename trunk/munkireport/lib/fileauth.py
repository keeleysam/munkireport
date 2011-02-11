# -*- coding: utf-8 -*-
"""Authentication of users in a passwd-style file

Users should be stored in an utf-8 encoded text file called users in the etc
directory of the project. Each line should have colon separated entries with:

username:Real Name:password

The password is a salted sha224 hash stored as a hex string. The first eight
characters (four bytes) is the salt, which is fed to the digest algorithm
before the password string. The 56 remaining characters is the digested result
of salt + password string.
"""

import tg
import logging
import hashlib
import codecs
import os.path
from repoze.what.adapters import BaseSourceAdapter, SourceError


__all__ = ['FileAuthenticator', 'FileMetadataProvider']


# Get a logger.
log = logging.getLogger(__name__.split(".")[0])

# FIXME: create a real cache instead, you have to restart the application to add new users
users = None


class FileUser(object):
    """Container for users."""
    
    def __init__(self, username, realname, password):
        """Store name and password attributes."""
        self.username = username
        self.realname = realname
        self.salt = password[:8].decode("hex")
        self.hexdigest = password[8:64]
    

def read_etc_users():
    """Read and parse users file"""
    
    # path to where the users are stored
    appsupport_dir = tg.config.get("appsupport_dir")
    users_path = os.path.join(appsupport_dir, "users")
    
    users = dict()
    
    try:
        with codecs.open(users_path, "r", "utf-8") as f:
            for line in f:
                fields = line.strip().split(":")
                username, realname, password = [f.strip() for f in fields]
                users[username] = FileUser(username, realname, password)
    except IOError as e:
        log.warn("Couldn't read users from %s: %s" % (users_path, str(e)))
    
    return users
    

def get_users():
    """Return users, read from disk if necessary."""
    
    global users
    if users is None:
        users = read_etc_users()
    
    return users
    

class FileAuthenticator(object):
    """Authenticate users in a passwd style file."""
    
    def authenticate(self, environ, identity):
        print "FileAuthenticator.authenticate"
        # Read login and password.
        try:
            login = identity["login"]
            password = identity["password"]
        except KeyError:
            return None
        
        u = get_users()
        if login in u:
            user = u[login]
            sha = hashlib.sha224()
            sha.update(user.salt)
            sha.update(password)
            if sha.hexdigest() == user.hexdigest:
                log.info("FileAuthenticator successfully authenticated %s" % login)
                return login
        
        log.info("FileAuthenticator failed for %s" % login)
        return None
    

class FileMetadataProvider(object):
    """Provide metadata for Mac OS X users."""
    
    metadata = {}
    
    def add_metadata(self, environ, identity):
        # Read userid.
        userid = identity.get("repoze.who.userid")
        
        u = get_users()
        if userid in u:
            identity.update({"display_name": u[userid].realname})
            return
    

if __name__ == '__main__':
    import sys
    
    import getpass
    
    a = FileAuthenticator()
    md = FileMetadataProvider()
    
    username = raw_input("Username: ")
    password = getpass.getpass()
    
    userid = a.authenticate({}, {"login": username, "password": password})
    if userid is None:
        sys.stderr.write("Authentication failed\n")
        sys.exit(1)
    
    identity = {"repoze.who.userid": userid}
    md.add_metadata({}, identity)
    print "Metadata for %s:" % userid, repr(identity)
    
    sys.exit(0)
