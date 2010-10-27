# -*- coding: utf-8 -*-
"""Admin Controller"""

from tgext.admin.tgadminconfig import TGAdminConfig
from tgext.admin.config import CrudRestControllerConfig
from sprox.tablebase import TableBase
from sprox.fillerbase import TableFiller
from repoze.what import predicates

from munkireport.model import Client

__all__ = ['MunkiReportAdminController']


class MunkiReportAdminController(TGAdminConfig):
    """Subclassing TGAdminConfig to override permissions."""
    allow_only = predicates.has_permission("admin", msg=u"Only available to users with admin permission.")
    class client(CrudRestControllerConfig):
        class table_type(TableBase):
            __entity__ = Client
            __limit_fields__ = ['id', 'name', 'mac', 'remote_ip', 'timestamp', 'console_user']
            __url__ = "../clients" # FIXME: pagination doesn't work
        class table_filler_type(TableFiller):
            __entity__ = Client
            __limit_fields__ = ['id', 'name', 'mac', 'remote_ip', 'timestamp', 'console_user']

