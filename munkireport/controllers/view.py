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

import re
import plistlib


__all__ = ['ViewController']


re_result = re.compile(r'^(Removal|Install) of (?P<dname>.+?)(-(?P<version>[^:]+))?: (?P<result>.*)$')


class ViewController(BaseController):
    """Gather client updates."""
    
    # The predicate that must be met for all the actions in this controller:
    allow_only = has_permission("view",
        msg=l_("Reports are only available for users with 'view' permission."))
    
    
    @expose()
    def error(self):
        abort(403)
    
    
    @expose('munkireport.templates.view.index')
    @validate(
        validators={
            "order_by": validators.OneOf((u"name", u"user", u"ip", u"activity")),
            "reverse": validators.StringBool(if_missing=False)
        },
        error_handler=error
    )
    def index(self, order_by=None, reverse=False):
        """Report overview."""
        sort_keys = {
            None: Client.timestamp,
            u"name": Client.name,
            u"user": Client.console_user,
            u"ip": Client.remote_ip,
            u"activity": Client.timestamp,
        }
        sort_key = sort_keys[order_by]
        error_clients=DBSession.query(Client).filter(Client.errors > 0).order_by(sort_key).all()
        warning_clients=DBSession.query(Client).filter(Client.errors == 0).filter(Client.warnings > 0).order_by(sort_key).all()
        activity_clients=DBSession.query(Client).filter(Client.activity != None).order_by(sort_key).all()
        if reverse:
            error_clients.reverse()
            warning_clients.reverse()
            activity_clients.reverse()
        return dict(
            page="reports",
            error_clients=error_clients,
            warning_clients=warning_clients,
            activity_clients=activity_clients
        )
    
    @expose('munkireport.templates.view.client_list')
    def client_list(self):
        """List all clients."""
        return dict(
            page="reports",
            clients=reversed(DBSession.query(Client).order_by(Client.timestamp).all())
        )
    
    
    @expose(content_type="application/xml")
    @validate(
        validators={
            "mac":      validators.MACAddress(add_colons=True, notempty=True)
        },
        error_handler=error
    )
    def report_plist(self, mac=None):
        """View a munki report."""
        client=Client.by_mac(mac)
        if not client:
            abort(404)
        
        # Work with a copy of the client report so we can modify it without
        # causing a database update.
        report = dict(client.report_plist)
        return plistlib.writePlistToString(report)
    
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
        
        # Work with a copy of the client report so we can modify it without
        # causing a database update.
        report = dict(client.report_plist)
        
        # Move install results over to their install items.
        install_results = dict()
        if "InstallResults" in report:
            for result in report["InstallResults"]:
                m = re_result.search(result)
                if m:
                    install_results["%s-%s" % (m.group("dname"), m.group("version"))] = {
                        "result": "Installed" if m.group("result") == "SUCCESSFUL" else m.group("result")
                    }
        if "ItemsToInstall" in report:
            for item in report["ItemsToInstall"]:
                item["install_result"] = "Pending"
                dversion = "%s-%s" % (item["display_name"], item["version_to_install"])
                if dversion in install_results:
                    res = install_results[dversion]
                    item["install_result"] = res["result"]
        if "AppleUpdateList" in report:
            for item in report["AppleUpdateList"]:
                item["install_result"] = "Pending"
                dversion = "%s-%s" % (item["display_name"], item["version_to_install"])
                if dversion in install_results:
                    res = install_results[dversion]
                    item["install_result"] = res["result"]
        
        # Move install results over to their install items.
        removal_results = dict()
        if "RemovalResults" in report:
            for result in report["RemovalResults"]:
                m = re_result.search(result)
                if m:
                    removal_results[m.group("dname")] = {
                        "result": "Removed" if m.group("result") == "SUCCESSFUL" else m.group("result")
                    }
        if "ItemsToRemove" in report:
            for item in report["ItemsToRemove"]:
                item["removal_result"] = "Pending"
                dversion = item["display_name"]
                if dversion in removal_results:
                    res = removal_results[dversion]
                    item["removal_result"] = res["result"]
        
        return dict(
            page="reports",
            client=client,
            report=report,
            install_results=install_results,
            removal_results=removal_results
        )
    
