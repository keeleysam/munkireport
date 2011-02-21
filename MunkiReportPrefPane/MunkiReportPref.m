//
//  MunkiReportPref.m
//  MunkiReport
//
//  Created by Per Olofsson on 2011-02-15.
//  Copyright (c) 2010-2011 University of Gothenburg. All rights reserved.
//

#import "MunkiReportPref.h"


static NSString *launchDaemonPath = @"/Library/LaunchDaemons/com.googlecode.munkireport.plist";
static NSString	*appSupportPath = @"/Library/Application Support/MunkiReport";


@implementation MyTableView

- (void)cancelOperation:(id)sender
{
    if ([self currentEditor] != nil) {
        [self abortEditing];
        [[self window] makeFirstResponder:self];
    }
}

/*
- (void)textDidEndEditing:(NSNotification *)aNotification
{
    NSLog(@"textDidEndEditing:");
    NSLog(@"        name:%@", [aNotification name]);
    NSLog(@"      object:%@", [aNotification object]);
    NSLog(@"    userInfo:%@", [aNotification userInfo]);
}
*/

@end


@implementation MunkiReportPref

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
    if ([usersDataSource loadUsersPlist:[appSupportPath stringByAppendingPathComponent:@"users.plist"]] == NO) {
        NSLog(@"Failed to load users file");
        [self alertBox:@"Failed to load users file" details:@""];
    }
    if ([usersDataSource loadGroupsIni:[appSupportPath stringByAppendingPathComponent:@"groups.ini"]] == YES) {
        [usersDataSource updateUsersWithGroups];
    } else {
        NSLog(@"Failed to load groups file");
        [self alertBox:@"Failed to load groups file" details:@""];
    }
    [theUsersTableView setDelegate:usersDataSource];
    [theUsersTableView setDataSource:usersDataSource];
    NSTableColumn *usernameColumn = [theUsersTableView tableColumnWithIdentifier:@"username"];
    [[usernameColumn dataCell] setFormatter:[[UsernameFormatter alloc] init]];
    
    // Initialize GUI.
    [self updateButtonAuthorization];
    [theOnButton setState:NSOffState];
    [theOffButton setState:NSOffState];
    [theMunkiReportVersionText setStringValue:@"MunkiReport vUNKNOWN"];
    [self updateServerStatus];
    
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

// Display alert

- (void) alertBox:(NSString *)message details:(NSString *)details
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:message];
    [alert setInformativeText:details];
    [alert beginSheetModalForWindow:[[self mainView] window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

// LaunchDaemon control

- (NSDictionary *) mrserver:(NSString *)action
{
    NSString *mrserver = [[self bundle] pathForResource:@"mrserver" ofType:@"py"];
    
    const char *argv[] = {
        [action UTF8String],
        NULL
    };
    
    FILE *mrserver_out;
    OSErr processError = AuthorizationExecuteWithPrivileges([[authView authorization] authorizationRef],
                                                            [mrserver UTF8String],
                                                            kAuthorizationFlagDefaults,
                                                            (char *const *)argv,
                                                            &mrserver_out);
    if (processError != errAuthorizationSuccess) {
        NSLog(@"Authorization for mrserver.py failed with code %d", processError);
    }
    
    NSData *mrserverOutputPlist = [[[NSFileHandle alloc]
                                    initWithFileDescriptor:fileno(mrserver_out)]
                                   readDataToEndOfFile];
    fclose(mrserver_out);
    
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSDictionary *plist = (NSDictionary *)[NSPropertyListSerialization
                                           propertyListFromData:mrserverOutputPlist
                                               mutabilityOption:NSPropertyListImmutable
                                                         format:&format
                                               errorDescription:&errorDesc];
    if (plist == nil) {
        NSLog(@"Error reading output from mrserver.py: %@: %d", errorDesc);
    }
    
    return plist;
}

- (IBAction) onButtonClicked:(id)sender
{
    [theOnButton setState:NSOnState];
    [theOffButton setState:NSOffState];
    
    [theStatusText setStringValue:@"Starting server..."];
    [theStatusIndicator setImage:statusImageUnknown];
    
    NSDictionary *response = [self mrserver:@"enable"];
    if ([[response objectForKey:@"exitcode"] intValue] != 0) {
        [self alertBox:@"Couldn't start server" details:[response objectForKey:@"stderr"]];
    }
}

- (IBAction) offButtonClicked:(id)sender
{
    [theOnButton setState:NSOffState];
    [theOffButton setState:NSOnState];
    
    [theStatusText setStringValue:@"Stopping server..."];
    [theStatusIndicator setImage:statusImageUnknown];
    
    NSDictionary *response = [self mrserver:@"disable"];
    if ([[response objectForKey:@"exitcode"] intValue] != 0) {
        [self alertBox:@"Couldn't stop server" details:[response objectForKey:@"stderr"]];
    }
}

// Authorization

- (BOOL) isUnlocked
{
    return [authView authorizationState] == SFAuthorizationViewUnlockedState;
}

- (void) updateButtonAuthorization {
    [theOnButton setEnabled:[self isUnlocked]];
    [theOffButton setEnabled:[self isUnlocked]];
    [theAddUserButton setEnabled:[self isUnlocked]];
    [theRemoveUserButton setEnabled:[self isUnlocked]];
    [theUsersTableView setEnabled:[self isUnlocked]];
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
    // Default to both buttons unselected.
    [theOnButton setState:NSOffState];
    [theOffButton setState:NSOffState];
    
    // Start with sanity checks.
    if ( ! [[NSFileManager defaultManager] fileExistsAtPath:launchDaemonPath]) {
        // LaunchDaemon is missing.
        [theStatusIndicator setImage:statusImageError];
        [theStatusText setStringValue:@"LaunchDaemon is missing!"];
        return;
    }
    if ( ! [self isUnlocked]) {
        // Don't have authority to check server status.
        [theStatusIndicator setImage:statusImageUnknown];
        [theStatusText setStringValue:@"Preference Pane not authorized, unlock panel"];
        return;
    }
    
    // Read server status.
    NSDictionary *response = [self mrserver:@"status"];
    
    if ([[response objectForKey:@"exitcode"] intValue] != 0) {
        // Server status check failed.
        [theStatusIndicator setImage:statusImageError];
        [theStatusText setStringValue:[response objectForKey:@"stderr"]];
        return;
    }
    
    // Parse server status.
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *status = [[response objectForKey:@"stdout"]
                        stringByTrimmingCharactersInSet:whitespace];
    
    if ([status isEqual:@"running"]) {
        // Server is running, on button selected.
        [theStatusIndicator setImage:statusImageRunning];
        [theStatusText setStringValue:@"Running"];
        [theOnButton setState:NSOnState];
    } else if ([status isEqual:@"stopped"]) {
        // Server is stopped, off button selected.
        [theStatusIndicator setImage:statusImageStopped];
        [theStatusText setStringValue:@"Stopped"];
        [theOffButton setState:NSOnState];
    } else if ([status isEqual:@"error"]) {
        // Server is stopped with error, off button selected.
        [theStatusIndicator setImage:statusImageError];
        [theStatusText setStringValue:@"Terminated"];
        [theOffButton setState:NSOnState];
    } else {
        // Unknown state.
        [theStatusIndicator setImage:statusImageUnknown];
        [theStatusText setStringValue:[response objectForKey:@"stdout"]];
    }
}

// Users pane.

- (IBAction) addUserButtonClicked:(id)sender
{
    [usersDataSource addUser];
    [theUsersTableView reloadData];
    NSInteger newUserRow = [theUsersTableView numberOfRows] - 1;
    [theUsersTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:newUserRow]
                   byExtendingSelection:NO];
    [theUsersTableView editColumn:0
                              row:newUserRow
                        withEvent:nil
                           select:YES];
}

- (IBAction) removeUserButtonClicked:(id)sender
{
    if ([theUsersTableView selectedRow] != -1) {
        [usersDataSource removeUserAtIndex:[theUsersTableView selectedRow]];
        [theUsersTableView reloadData];
    }
}

@end
