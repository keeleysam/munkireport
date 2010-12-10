# -*- coding: utf-8 -*-
"""Sample controller with all its actions protected."""
from tg import expose, flash, request, abort, validate
from pylons.i18n import ugettext as _, lazy_ugettext as l_
from repoze.what.predicates import has_permission
#from dbsprockets.dbmechanic.frameworks.tg2 import DBMechanic
#from dbsprockets.saprovider import SAProvider

from formencode import validators

from munkireport.lib.base import BaseController
from munkireport.model import DBSession, Client

from datetime import datetime
import sys
import plistlib
import base64
import bz2
import pprint


__all__ = ['LookupController']


class LookupController(BaseController):
    """Gather client updates."""
    
    # The predicate that must be met for all the actions in this controller:
    #allow_only = has_permission("report",
    #   msg=l_("Only users with the 'report' permission can submit report updates."))
    
    @expose()
    def index(self):
        abort(403)
    
    
    @expose()
    def error(self):
        abort(401)
    
    
    @expose(content_type="text/plain")
    def ip(self):
        """Lookup external IP."""
        
        remote_ip = unicode(request.environ['REMOTE_ADDR'])
        return "%s\n" % remote_ip
    
    
    @expose("json")
    @validate(
        validators={
            "mac":      validators.MACAddress(add_colons=True, notempty=True)
        },
        error_handler=error
    )
    def client_info(self, mac):
        """Look up client information summary."""
        
        client_info = dict()
        
        client = Client.by_mac(mac)
        if not client:
            return abort(404)
        
        client_info["machine_info"] = dict(client.report_plist["MachineInfo"])
        client_info["munki_info"] = dict()
        for key in ("AvailableDiskSpace",
                    "ConsoleUser",
                    "EndTime",
                    "ManagedInstallVersion",
                    "ManifestName",
                    "RunType",
                    "StartTime"):
            if key in client.report_plist:
                client_info["munki_info"][key] = client.report_plist[key]
        
        return client_info
    
