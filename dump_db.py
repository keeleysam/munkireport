#!/usr/bin/env python


import os
import sys
import pickle

from munkireport.model import DBSession, Client
import sqlalchemy


def usage():
    print "Usage: dump_db.py database.db"
    

def main(argv):
    try:
        dbpath = argv[1]
    except IndexError:
        usage()
        return 1
    
    try:
        engine = sqlalchemy.create_engine('sqlite:///%s' % dbpath)
        DBSession.configure(bind=engine)
    except BaseException as e:
        print >>sys.stderr, "Couldn't open sqlite database %s: %s" % (dbpath, e)
    
    if not os.path.exists("munkireport/websetup/dump"):
        try:
            os.makedirs("munkireport/websetup/dump")
        except BaseException as e:
            print >>sys.stderr, "Couldn't create dump directory: %s" % e
            return 2
    
    for client in DBSession.query(Client).all():
        print "%s %s" % (client.name, client.mac)
        c = dict()
        for prop in dir(Client):
            attr = getattr(Client, prop)
            if isinstance(attr, sqlalchemy.orm.attributes.InstrumentedAttribute):
                c[prop] = getattr(client, prop)
        with open("munkireport/websetup/dump/%s.pickle" % client.mac, "wb") as f:
            pickle.dump(c, f, pickle.HIGHEST_PROTOCOL)
    
    return 0
    

if __name__ == '__main__':
    sys.exit(main(sys.argv))
    
