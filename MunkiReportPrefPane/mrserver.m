//
//  mrserver.m
//  MunkiReport
//
//  Created by Pelle on 2011-02-21.
//  Copyright 2011 University of Gothenburg. All rights reserved.
//


#import <Foundation/Foundation.h>


void NSPrint(NSString *string) {
    [string writeToFile:@"/dev/stdout"
             atomically:NO
               encoding:NSUTF8StringEncoding
                  error:NULL];
    [@"\n" writeToFile:@"/dev/stdout"
            atomically:NO
              encoding:NSUTF8StringEncoding
                 error:NULL];
}


static int enable(NSArray *args) {
    NSPrint(@"enable");
    return 0;
}


static int disable(NSArray *args) {
    NSPrint(@"disable");
    return 0;
}


static int status(NSArray *args) {
    NSPrint(@"status");
    return 0;
}


static int err_usage(void) {
    NSPrint(@"Usage: mrserver <action> [options] [args]");
    NSPrint(@"");
    NSPrint(@"Available actions:");
    NSPrint(@"  enable");
    NSPrint(@"  disable");
    NSPrint(@"  status");
    return 1;
}


static int err_permissions(void) {
    NSPrint(@"This command must be run as root.");
    return 1;
}


int main(int argc, char *argv[]) {
    if (argc < 2) {
        return err_usage();
    }
    
    if (setuid(0) != 0) {
        return err_permissions();
    }
    
    NSMutableArray *args = [NSMutableArray arrayWithCapacity:argc];
    for (int i = 0; i < argc; ++i) {
        [args addObject:[NSString stringWithCString:argv[i] encoding:NSUTF8StringEncoding]];
    }
    
    NSString *action = [args objectAtIndex:1];
    if ([action isEqual:@"enable"]) {
        return enable(args);
    } else if ([action isEqual:@"disable"]) {
        return disable(args);
    } else if ([action isEqual:@"status"]) {
        return status(args);
    } else {
        return err_usage();
    }
}
