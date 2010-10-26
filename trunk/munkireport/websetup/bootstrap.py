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
    
    # <websetup.bootstrap.before.auth
    from sqlalchemy.exc import IntegrityError
    try:
        report_user = model.User()
        report_user.user_name = u'munkireport'
        report_user.display_name = u'Munki Reporter'
        report_user.password = u'munkadent'
        model.DBSession.add(report_user)
        
        reporters_group = model.Group()
        reporters_group.group_name = u'reporters'
        reporters_group.display_name = u'Reporters'
        reporters_group.users.append(report_user)
        model.DBSession.add(reporters_group)
        
        report_perm = model.Permission()
        report_perm.permission_name = u'report'
        report_perm.description = u'This permission is needed to submit reports'
        report_perm.groups.append(reporters_group)
        model.DBSession.add(report_perm)
        
        admin_user = model.User()
        admin_user.user_name = u'munkiadmin'
        admin_user.display_name = u'Munki Administrator'
        admin_user.password = u'hejsan'
        model.DBSession.add(admin_user)
        
        greg_user = model.User()
        greg_user.user_name = u'greg'
        greg_user.display_name = u'Greg Neagle'
        greg_user.password = u'munkiguest'
        model.DBSession.add(greg_user)
        
        admins_group = model.Group()
        admins_group.group_name = u'admins'
        admins_group.display_name = u'Administrators'
        admins_group.users.append(admin_user)
        model.DBSession.add(admins_group)
        
        admin_perm = model.Permission()
        admin_perm.permission_name = u'admin'
        admin_perm.description = u'This permission is needed to administrate reports'
        admin_perm.groups.append(admins_group)
        model.DBSession.add(admin_perm)
        
        model.DBSession.flush()
        transaction.commit()
    except IntegrityError:
        print 'Warning, there was a problem adding your auth data, it may have already been added:'
        import traceback
        print traceback.format_exc()
        transaction.abort()
        print 'Continuing with bootstrapping...'
    
    # <websetup.bootstrap.after.auth>
    
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
    
