# -*- coding: utf-8 -*-
"""Sample model module."""

from sqlalchemy import *
from sqlalchemy.orm import mapper, relation
from sqlalchemy import Table, ForeignKey, Column
from sqlalchemy.types import Integer, Unicode, PickleType
#from sqlalchemy.orm import relation, backref

from munkireport.model import DeclarativeBase, metadata, DBSession

from datetime import datetime


class Client(DeclarativeBase):
    __tablename__ = 'client'
    
    #{ Columns
    
    id = Column(Integer, autoincrement=True, primary_key=True)
    name = Column(Unicode(64))
    mac = Column(Unicode(17), nullable=False, unique=True)
    remote_ip = Column(Unicode(15))
    timestamp = Column(DateTime, default=datetime.now)
    runtype = Column(Unicode(64))
    runstate = Column(Unicode(16))
    console_user = Column(Unicode(64))
    errors = Column(Integer, default=0)
    warnings = Column(Integer, default=0)
    report_plist = Column(PickleType(mutable=False))
    
    #}
    
    def __repr__(self):
        return "<Client('%s', '%s', '%s', '%s', '%s', '%s', '%d' chars report)>" % \
            (self.name, self.mac, self.remote_ip, self.timestamp, \
            self.runtype, self.runstate, \
            len(self.report_plist) if self.report_plist else 0)
    
    @classmethod
    def by_mac(c, mac):
        return DBSession.query(c).filter_by(mac=mac).first()
    
    @classmethod
    def all(c):
        return reversed(DBSession.query(c).order_by(c.timestamp).all())
    