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
    NSMutableDictionary *groups;
}

- (id)init;

- (BOOL)loadUsersPlist:(NSString *)usersPath;
- (BOOL)loadGroupsIni:(NSString *)groupsPath;
- (void)updateUsersWithGroups;

// NSTableViewDelegate
- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
    row:(NSInteger)rowIndex;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;

// NSTableViewDataSource

@end
