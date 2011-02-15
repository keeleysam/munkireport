//
//  MunkiReportPrefPanePref.m
//  MunkiReportPrefPane
//
//  Created by Per Olofsson on 2011-02-15.
//  Copyright (c) 2010-2011 University of Gothenburg. All rights reserved.
//

#import "MunkiReportPrefPanePref.h"


@implementation MunkiReportPrefPanePref

- (void) mainViewDidLoad
{
    // Setup security.
    AuthorizationItem items = {kAuthorizationRightExecute, 0, NULL, 0};
    AuthorizationRights rights = {1, &items};
    [authView setAuthorizationRights:&rights];
    authView.delegate = self;
    [authView updateStatus:nil];
	
	[self updateButtonAuthorization];
	[theOnButton setState:NSOffState];
	[theOffButton setState:NSOnState];
	[theServerURLText setStringValue:@"Determining..."];
	[theStatusText setStringValue:@"Determining..."];
	[theMunkiReportVersionText setStringValue:@"MunkiReport v0.7.0.unknown"];
}

// LaunchDaemon control

- (IBAction) onButtonClicked:(id)sender
{
	//NSLog(@"onButtonClicked");
	[theOnButton setState:NSOnState];
	[theOffButton setState:NSOffState];
    
	NSMutableArray *args = [NSMutableArray array];
    [args addObject:@"load"];
    [args addObject:@"-w"];
    [args addObject:@"/Library/LaunchDaemons/com.googlecode.munkireport.plist"];
	
    // Convert array into void-* array.
    const char **argv = (const char **)malloc(sizeof(char *) * [args count] + 1);
    int argvIndex = 0;
    for (NSString *string in args) {
        argv[argvIndex] = [string UTF8String];
        argvIndex++;
    }
    argv[argvIndex] = nil;
	
    OSErr processError = AuthorizationExecuteWithPrivileges([[authView authorization] authorizationRef], [@"/bin/launchctl" UTF8String],
                                                            kAuthorizationFlagDefaults, (char *const *)argv, nil);
    free(argv);
	
    if (processError != errAuthorizationSuccess) {
        NSLog(@"MunkiReport server start failed: %d", processError);
	}
	
	[theStatusText setStringValue:@"Running"];
	[theServerURLText setStringValue:@"http://howdy!/"];
	//NSLog(@"theOnButton = %d, theOffButton = %d", [theOnButton state], [theOffButton state]);
}

- (IBAction) offButtonClicked:(id)sender
{
	//NSLog(@"offButtonClicked");
	[theOnButton setState:NSOffState];
	[theOffButton setState:NSOnState];
	[theStatusText setStringValue:@"Stopped"];
	[theServerURLText setStringValue:@""];
	//NSLog(@"theOnButton = %d, theOffButton = %d", [theOnButton state], [theOffButton state]);
}

// Authorization

- (BOOL) isUnlocked
{
    return [authView authorizationState] == SFAuthorizationViewUnlockedState;
}

- (void) updateButtonAuthorization {
    [theOnButton setEnabled:[self isUnlocked]];
    [theOffButton setEnabled:[self isUnlocked]];
}

// SFAuthorization delegates

- (void) authorizationViewDidAuthorize:(SFAuthorizationView *)view
{
	[self updateButtonAuthorization];
}

- (void) authorizationViewDidDeauthorize:(SFAuthorizationView *)view
{
	[self updateButtonAuthorization];
}

@end
