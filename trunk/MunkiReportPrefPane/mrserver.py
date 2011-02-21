#!/usr/bin/python
# encoding: utf-8
#
# MunkiReport
#
# Created by Per Olofsson on 2011-02-21.
# Copyright 2011 University of Gothenburg. All rights reserved.


import os
import sys
import optparse
import subprocess
import plistlib
import cStringIO


JOB = "com.googlecode.munkireport"
LAUNCHDAEMON_PATH = "/Library/LaunchDaemons/%s.plist" % JOB


# subprocess.check_output backported from 2.7.
if 'check_output' not in dir(subprocess):
    def check_output(*popenargs, **kwargs):
        r"""Run command with arguments and return its output as a byte string.

        If the exit code was non-zero it raises a CalledProcessError.  The
        CalledProcessError object will have the return code in the returncode
        attribute and output in the output attribute.

        The arguments are the same as for the Popen constructor.  Example:

        >>> check_output(["ls", "-l", "/dev/null"])
        'crw-rw-rw- 1 root root 1, 3 Oct 18  2007 /dev/null\n'

        The stdout argument is not allowed as it is used internally.
        To capture standard error in the result, use stderr=STDOUT.

        >>> check_output(["/bin/sh", "-c",
        ...               "ls -l non_existent_file ; exit 0"],
        ...              stderr=STDOUT)
        'ls: non_existent_file: No such file or directory\n'
        """
        if 'stdout' in kwargs:
            raise ValueError('stdout argument not allowed, it will be overridden.')
        process = subprocess.Popen(stdout=subprocess.PIPE, stderr=subprocess.PIPE, *popenargs, **kwargs)
        output, unused_err = process.communicate()
        retcode = process.poll()
        if retcode:
            cmd = kwargs.get("args")
            if cmd is None:
                cmd = popenargs[0]
            raise subprocess.CalledProcessError(retcode, cmd)
        return output
    subprocess.check_output = check_output
    

def enable(argv):
    try:
        subprocess.check_call(["/bin/launchctl", "load", "-w", LAUNCHDAEMON_PATH])
    except subprocess.CalledProcessError as e:
        print >>sys.stderr, "LaunchDaemon load failed: %s" % e
        return 2
    return 0
    

def disable(argv):
    try:
        subprocess.check_call(["/bin/launchctl", "unload", "-w", LAUNCHDAEMON_PATH])
    except subprocess.CalledProcessError as e:
        print >>sys.stderr, "LaunchDaemon unload failed: %s" % e
        return 2
    return 0
    

def status(argv):
    try:
        status_output = subprocess.check_output(["/bin/launchctl", "list", "-x", JOB])
    except subprocess.CalledProcessError as e:
        print >>sys.stderr, "LaunchDaemon status failed: %s" % e
        return 2
    plist = plistlib.readPlistFromString(status_output)
    if "PID" in plist:
        print "running"
    if plist.LastExitStatus == 0:
        print "stopped"
    else:
        print "error"
    return 0
    

def main(argv):
    p = optparse.OptionParser()
    p.set_usage(u"""Usage: %prog action

Available actions:
    enable
    disable
    status

%prog must be run as root.""")
    # p.add_option("-v", "--verbose", action="store_true",
    #              help="Verbose output.")
    options, argv = p.parse_args(argv)
    if len(argv) < 2:
        print >>sys.stderr, p.get_usage()
        return 1
    
    try:
        os.setuid(0)
    except OSError as e:
        print >>sys.stderr, u"Permission denied, must be run as root."
        return 1
    
    action = argv[1]
    
    actions = {
        u"enable": enable,
        u"disable": disable,
        u"status": status,
    }
    
    if action in actions:
        return actions[action](argv[1:])
    else:
        print >>sys.stderr, u"Unknown action: %s\n" % action
        print >>sys.stderr, p.get_usage()
        return 1
    

if __name__ == '__main__':
    org_stdout = sys.stdout
    org_stderr = sys.stderr
    
    my_stdout = cStringIO.StringIO()
    sys.stdout = my_stdout
    my_stderr = cStringIO.StringIO()
    sys.stderr = my_stderr
    my_exitcode = main(sys.argv)
    
    sys.stdout = org_stdout
    sys.stderr = org_stderr
    
    plistlib.writePlist(
        {
            "exitcode": my_exitcode,
            "stdout": my_stdout.getvalue(),
            "stderr": my_stderr.getvalue(),
        },
        sys.stdout,
    )
    
    sys.exit(0)
