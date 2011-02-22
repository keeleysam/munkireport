//
//  MunkiReportPref.h
//  MunkiReport
//
//  Created by Per Olofsson on 2011-02-15.
//  Copyright (c) 2010-2011 University of Gothenburg. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import <SecurityInterface/SFAuthorizationView.h>

#import "UsersDataSource.h"


@interface MyTableView : NSTableView @end


@interface MunkiReportPref : NSPreferencePane 
{
    // Main server control.
    IBOutlet NSButton *theOnButton;
    IBOutlet NSButton *theOffButton;

    // Authorization.
    IBOutlet SFAuthorizationView *authView;
    
    // Status pane.
    IBOutlet NSImageView *theStatusIndicator;
    IBOutlet NSTextField *theStatusText;
    IBOutlet NSTextField *theMunkiReportVersionText;
    
    NSImage *statusImageError;
    NSImage *statusImageRunning;
    NSImage *statusImageStopped;
    NSImage *statusImageUnknown;
    
    // Users pane.
    IBOutlet NSButton *theAddUserButton;
    IBOutlet NSButton *theRemoveUserButton;
    IBOutlet MyTableView *theUsersTableView;
    UsersDataSource *usersDataSource;
}

- (void) mainViewDidLoad;
- (void) alertBox:(NSString *)message details:(NSString *)details;

// Main server control.
- (NSDictionary *) mrserver:(NSString *)action;
- (IBAction) onButtonClicked:(id)sender;
- (IBAction) offButtonClicked:(id)sender;

// Authorization.
- (BOOL) isUnlocked;
- (void) updateButtonAuthorization;

// Status pane.
- (void) updateServerStatus;

// Users pane.
- (IBAction) addUserButtonClicked:(id)sender;
- (IBAction) removeUserButtonClicked:(id)sender;

@end