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
sys.path.append("/System/Library/Frameworks/Python.framework/Versions/2.6/Extras/lib/python/PyObjC")
#from Foundation import NSData, NSPropertyListSerialization, NSPropertyListMutableContainers
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
    
    
    @expose(content_type="text/plain")
    def ip(self):
        """Lookup external IP."""
        
        remote_ip = unicode(request.environ['REMOTE_ADDR'])
        return "%s\n" % remote_ip
    
