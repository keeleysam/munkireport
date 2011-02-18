//
//  UsersDataSource.m
//  MunkiReportPrefPane
//
//  Created by Pelle on 2011-02-17.
//  Copyright 2011 University of Gothenburg. All rights reserved.
//

#import "UsersDataSource.h"


// FIXME: these should use NSError.


@implementation UsersDataSource

-(id)init
{
    if ((self = [super init])) {
        users = [[NSMutableArray alloc] init];
        groups = [[NSMutableDictionary alloc] init];
    }
    return self;
}


// Load users with username, realname, and password from a plist.
- (BOOL)loadUsersPlist:(NSString *)usersPath
{
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    
    NSData *plistData = [[NSFileManager defaultManager] contentsAtPath:usersPath];
    users = (NSMutableArray *)[NSPropertyListSerialization propertyListFromData:plistData
                                                               mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                                         format:&format
                                                               errorDescription:&errorDesc];
    if (users == nil) {
        NSLog(@"Error reading users from %@: %@, format: %d", usersPath, errorDesc, format);
        return NO;
    }
    
    return YES;
}

// Load an ini file with [groups] containing one user per line.
- (BOOL)loadGroupsIni:(NSString *)groupsPath
{
    groups = [[NSMutableDictionary alloc] init];
    NSError *error;
    
    NSString *groupsFile = [NSString stringWithContentsOfFile:groupsPath
                                                     encoding:NSUTF8StringEncoding
                                                        error:&error];
    if (groupsFile == nil) {
        NSLog(@"Couldn't read %@: %@", groupsPath, error);
        return NO;
    }
    
    NSArray *lines = [groupsFile componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray *members = nil;
    for (NSString *line in lines) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([line hasPrefix:@"["]) {
            NSString *group = [line stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]];
            members = [[NSMutableArray alloc] init];
            [groups setObject:members forKey:group];
        } else if ([line length] > 0) {
            if (members != nil) {
                [members addObject:line]; 
            } else {
                NSLog(@"Unknown characters in %@: %@", groupsPath, line);
            }
        }
    }
    
    if ([groups objectForKey:@"admins"] == nil) {
        NSLog(@"%@ is missing [admins]", groupsPath);
        return NO;
    }
    if ([groups objectForKey:@"viewers"] == nil) {
        NSLog(@"%@ is missing [viewers]", groupsPath);
        return NO;
    }
    return YES;
}

// Set hasAdmin and hasView for users based on group membership.
- (void)updateUsersWithGroups
{
    NSArray *admins = [groups objectForKey:@"admins"];
    NSArray *viewers = [groups objectForKey:@"viewers"];
    for (NSMutableDictionary *user in users) {
        if ([admins containsObject:[user objectForKey:@"username"]]) {
            [user setObject:[NSNumber numberWithBool:YES] forKey:@"hasAdmin"];
        } else {
            [user setObject:[NSNumber numberWithBool:NO] forKey:@"hasAdmin"];
        }

        if ([viewers containsObject:[user objectForKey:@"username"]]) {
            [user setObject:[NSNumber numberWithBool:YES] forKey:@"hasView"];
        } else {
            [user setObject:[NSNumber numberWithBool:NO] forKey:@"hasView"];
        }
    }
}


// NSTableViewDataSource

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
    row:(NSInteger)rowIndex
{
    NSDictionary *theUser;
    id theValue;
    
    /*
    if ([[aTableColumn identifier] isEqualToString:@"hasAdmin"]) {
        return [NSNumber numberWithBool:YES];
    }
    if ([[aTableColumn identifier] isEqualToString:@"hasView"]) {
        return [NSNumber numberWithBool:YES];
    }
    */
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
