//
//  MunkiReportPrefPanePref.h
//  MunkiReportPrefPane
//
//  Created by Per Olofsson on 2011-02-15.
//  Copyright (c) 2010-2011 University of Gothenburg. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import <SecurityInterface/SFAuthorizationView.h>


@interface MunkiReportPrefPanePref : NSPreferencePane 
{
	IBOutlet NSButton *theOnButton;
	IBOutlet NSButton *theOffButton;
	IBOutlet NSTextField *theServerURLText;
	IBOutlet NSTextField *theStatusText;
	IBOutlet NSTextField *theMunkiReportVersionText;
    IBOutlet SFAuthorizationView *authView;
}

- (void) mainViewDidLoad;
- (IBAction) onButtonClicked:(id)sender;
- (IBAction) offButtonClicked:(id)sender;
- (BOOL) isUnlocked;
- (void) updateButtonAuthorization;

@end
