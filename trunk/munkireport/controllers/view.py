# -*- coding: utf-8 -*-
"""Sample controller with all its actions protected."""
from tg import expose, flash, validate, abort
from pylons.i18n import ugettext as _, lazy_ugettext as l_
from repoze.what.predicates import has_permission
#from dbsprockets.dbmechanic.frameworks.tg2 import DBMechanic
#from dbsprockets.saprovider import SAProvider

from formencode import validators

from munkireport.lib.base import BaseController
from munkireport.model import DBSession, Client

import plistlib


__all__ = ['ViewController']


class ViewController(BaseController):
    """Gather client updates."""
    
    # The predicate that must be met for all the actions in this controller:
    allow_only = has_permission("view",
        msg=l_("Reports are only available for users with 'view' permission."))
    
    @expose('munkireport.templates.view.index')
    def index(self):
        """Let the user know that's visiting a protected controller."""
        return dict(clients=Client.all())
    
    
    @expose()
    def error(self):
        abort(403)
    
    
    @expose('munkireport.templates.view.report')
    @validate(
        validators={
            "mac":      validators.MACAddress(add_colons=True, notempty=True)
        },
        error_handler=error
    )
    def report(self, mac=None):
        """View a munki report."""
        client=Client.by_mac(mac)
        if not client:
            abort(404)
        
        return dict(
            client=client,
            report=dict(client.report_plist)
        )
    
