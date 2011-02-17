//
//  UsersDataSource.m
//  MunkiReportPrefPane
//
//  Created by Pelle on 2011-02-17.
//  Copyright 2011 University of Gothenburg. All rights reserved.
//

#import "UsersDataSource.h"


@implementation UsersDataSource

- (int)loadUsersFile:(NSString *)usersPath
{
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	
	NSData *plistData = [[NSFileManager defaultManager] contentsAtPath:usersPath];
	users = (NSMutableArray *)[NSPropertyListSerialization
							   propertyListFromData:plistData
							   mutabilityOption:NSPropertyListMutableContainersAndLeaves
							   format:&format
							   errorDescription:&errorDesc];
	if (!users) {
		NSLog(@"Error reading users from %@: %@, format: %d", usersPath, errorDesc, format);
		return 0;
	}
	
	return [users count];
}

- (id)tableView:(NSTableView *)aTableView
	objectValueForTableColumn:(NSTableColumn *)aTableColumn
	row:(NSInteger)rowIndex
{
	NSDictionary *theUser;
	id theValue;
	
	if ([[aTableColumn identifier] isEqualToString:@"hasAdmin"]) {
		return [NSNumber numberWithBool:YES];
	}
	if ([[aTableColumn identifier] isEqualToString:@"hasView"]) {
		return [NSNumber numberWithBool:YES];
	}
	NSParameterAssert(rowIndex >= 0 && rowIndex < [users count]);
	theUser = [users objectAtIndex:rowIndex];
	theValue = [theUser objectForKey:[aTableColumn identifier]];
	return theValue;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [users count];
}

@end
