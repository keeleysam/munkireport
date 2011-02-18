//
//  MunkiReportPrefPanePref.m
//  MunkiReportPrefPane
//
//  Created by Per Olofsson on 2011-02-15.
//  Copyright (c) 2010-2011 University of Gothenburg. All rights reserved.
//

#import "MunkiReportPrefPanePref.h"


static NSString *launchDaemonPath = @"/Library/LaunchDaemons/com.googlecode.munkireport.plist";


@implementation MunkiReportPrefPanePref

- (void) mainViewDidLoad
{
    // Load status images.
    statusImageError =   [[NSImage alloc] initWithContentsOfFile:[[self bundle] pathForImageResource:@"status-error"]];
    statusImageRunning = [[NSImage alloc] initWithContentsOfFile:[[self bundle] pathForImageResource:@"status-running"]];
    statusImageStopped = [[NSImage alloc] initWithContentsOfFile:[[self bundle] pathForImageResource:@"status-stopped"]];
    statusImageUnknown = [[NSImage alloc] initWithContentsOfFile:[[self bundle] pathForImageResource:@"status-unknown"]];
    
    // Setup security.
    AuthorizationItem items = {kAuthorizationRightExecute, 0, NULL, 0};
    AuthorizationRights rights = {1, &items};
    [authView setAuthorizationRights:&rights];
    authView.delegate = self;
    [authView updateStatus:nil];
    
    // Load users plist.
    usersDataSource = [[UsersDataSource alloc] init];
    if ([usersDataSource loadUsersPlist:@"/Library/Application Support/MunkiReport/users.plist"] == NO) {
        NSLog(@"Failed to load users file");
    }
    if ([usersDataSource loadGroupsIni:@"/Library/Application Support/MunkiReport/groups.ini"] == NO) {
        NSLog(@"Failed to load groups file");
    }
    [usersDataSource updateUsersWithGroups];
    [theUsersTableView setDelegate:usersDataSource];
    [theUsersTableView setDataSource:usersDataSource];
    
    // Initialize GUI.
    [self updateButtonAuthorization];
    [theOnButton setState:NSOffState];
    [theOffButton setState:NSOnState];
    [theStatusText setStringValue:@"Checking status..."];
    [theMunkiReportVersionText setStringValue:@"MunkiReport v0.7.0.unknown"];
    
    // Setup timer to periodically update server status.
    NSInvocation *updateServerStatusInvocation;
    updateServerStatusInvocation = [NSInvocation invocationWithMethodSignature:
                                    [self
                                     methodSignatureForSelector:@selector(updateServerStatus)]];
    [updateServerStatusInvocation setTarget:self];
    [updateServerStatusInvocation setSelector:@selector(updateServerStatus)];
    
    [NSTimer scheduledTimerWithTimeInterval:2
             invocation:updateServerStatusInvocation
             repeats:YES];
}

// LaunchDaemon control

- (void) launchctl:(NSString *)subcommand
{
    // load or unload LaunchDaemon.
    
    NSArray *args = [NSArray arrayWithObjects:subcommand,
                             @"-w",
                             launchDaemonPath,
                             nil];
    
    // Convert NSArray into char-* array.
    const char **argv = (const char **)malloc(sizeof(char *) * [args count] + 1);
    int argvIndex = 0;
    for (NSString *string in args) {
        argv[argvIndex] = [string UTF8String];
        argvIndex++;
    }
    argv[argvIndex] = nil;
    
    OSErr processError = AuthorizationExecuteWithPrivileges([[authView authorization] authorizationRef],
                                                            [@"/bin/launchctl" UTF8String],
                                                            kAuthorizationFlagDefaults,
                                                            (char *const *)argv,
                                                            nil);
    free(argv);
    
    if (processError != errAuthorizationSuccess) {
        NSLog(@"MunkiReport server start failed: %d", processError);
    }
    
}

- (IBAction) onButtonClicked:(id)sender
{
    //NSLog(@"onButtonClicked");
    [theOnButton setState:NSOnState];
    [theOffButton setState:NSOffState];
    
    [self launchctl:@"load"];
    
    [theStatusText setStringValue:@"Running at http://0.0.0.0:8444/"];
    [theStatusIndicator setImage:statusImageRunning];
    //NSLog(@"theOnButton = %d, theOffButton = %d", [theOnButton state], [theOffButton state]);
}

- (IBAction) offButtonClicked:(id)sender
{
    //NSLog(@"offButtonClicked");
    [theOnButton setState:NSOffState];
    [theOffButton setState:NSOnState];
    
    [self launchctl:@"unload"];
    
    [theStatusText setStringValue:@"Stopped"];
    [theStatusIndicator setImage:statusImageStopped];
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

// Status pane.

- (void) updateServerStatus
{
    if ( ! [[NSFileManager defaultManager] fileExistsAtPath:launchDaemonPath]) {
        [theStatusIndicator setImage:statusImageError];
        [theStatusText setStringValue:@"LaunchDaemon is missing!"];
        return;
    }
}

// Users pane.

- (IBAction) addUserButtonClicked:(id)sender
{
    NSLog(@"addUserButtonClicked");
}

- (IBAction) removeUserButtonClicked:(id)sender
{
    NSLog(@"removeUserButtonClicked");
}

// NSTableView delegates.

//selectionShouldChangeInTableView:
//tableView:shouldEditTableColumn:row:
//tableViewSelectionDidChange:        NSTableViewSelectionDidChangeNotification
//tableViewSelectionIsChanging:        NSTableViewSelectionIsChangingNotification

@end
