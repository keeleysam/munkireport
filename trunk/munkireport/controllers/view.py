# -*- coding: utf-8 -*-
"""Sample controller with all its actions protected."""
from tg import expose, flash
from pylons.i18n import ugettext as _, lazy_ugettext as l_
from repoze.what.predicates import has_permission
#from dbsprockets.dbmechanic.frameworks.tg2 import DBMechanic
#from dbsprockets.saprovider import SAProvider

from munkireport.lib.base import BaseController
from munkireport.model import DBSession, Client

import plistlib


__all__ = ['ViewController']


class ViewController(BaseController):
    """Gather client updates."""
    
    # The predicate that must be met for all the actions in this controller:
    allow_only = has_permission('admin',
                                msg=l_('Only for people with the "admin" permission'))
    
    @expose('munkireport.templates.view.index')
    def index(self):
        """Let the user know that's visiting a protected controller."""
        return dict(clients=Client.all())
    
    # FIXME: validation
    @expose('munkireport.templates.view.report')
    def report(self, mac=None):
        """View a munki report."""
        try:
            client=Client.by_mac(mac)
        except:
            raise
        
        return dict(
            client=client,
            report=dict(client.report_plist)
        )
    
