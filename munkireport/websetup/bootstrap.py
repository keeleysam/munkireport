# -*- coding: utf-8 -*-
"""Setup the munkireport application"""

import glob
import pickle
import types

import logging
from tg import config
from munkireport.model import DBSession, Client
import sqlalchemy

import transaction


def bootstrap(command, conf, vars):
    """Place any commands to setup munkireport here"""
    
    for item in glob.iglob("munkireport/websetup/dump/*.pickle"):
        print "Importing %s" % item
        with open(item, "rb") as f:
            pickled_client = pickle.load(f)
        client = Client()
        for prop in dir(Client):
            attr = getattr(Client, prop)
            if isinstance(attr, sqlalchemy.orm.attributes.InstrumentedAttribute):
                try:
                    value = pickled_client[prop]
                except KeyError:
                    print "Warning: no pickled '%s' attribute" % prop
                else:
                    v = repr(value)
                    if len(v) > (70 - len(prop)):
                        v = v[:67] + "..."
                    #print "client.%s = %s" % (prop, v)
                    setattr(client, prop, value)
        client.update_report(pickled_client["report_plist"])
        #print client
        DBSession.add(client)
        DBSession.flush()
        transaction.commit()
