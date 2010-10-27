# -*- coding: utf-8 -*-
"""Setup the munkireport application"""

import glob
import pickle

import logging
from tg import config
from munkireport import model

import transaction


def bootstrap(command, conf, vars):
    """Place any commands to setup munkireport here"""
    
    for item in glob.iglob("munkireport/websetup/dump/*.pickle"):
        with open(item, "rb") as f:
            pickled_client = pickle.load(f)
        print pickled_client.name
        client = model.Client()
        client.name         = pickled_client.name
        client.mac          = pickled_client.mac
        client.remote_ip    = pickled_client.remote_ip
        client.timestamp    = pickled_client.timestamp
        client.runtype      = pickled_client.runtype
        client.runstate     = pickled_client.runstate
        client.console_user = pickled_client.console_user
        client.errors       = pickled_client.errors
        client.warnings     = pickled_client.warnings
        client.report_plist = pickled_client.report_plist
        model.DBSession.add(client)
        model.DBSession.flush()
        transaction.commit()
    
