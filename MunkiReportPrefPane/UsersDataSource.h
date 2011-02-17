//
//  UsersDataSource.h
//  MunkiReportPrefPane
//
//  Created by Pelle on 2011-02-17.
//  Copyright 2011 University of Gothenburg. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface UsersDataSource : NSObject <NSTableViewDelegate, NSTableViewDataSource> {
	NSMutableArray *users;
}

- (int)loadUsersFile:(NSString *)usersPath;
- (id)tableView:(NSTableView *)aTableView
	objectValueForTableColumn:(NSTableColumn *)aTableColumn
	row:(NSInteger)rowIndex;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;

@end
