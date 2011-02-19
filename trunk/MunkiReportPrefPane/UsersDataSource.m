//
//  UsersDataSource.m
//  MunkiReportPrefPane
//
//  Created by Pelle on 2011-02-17.
//  Copyright 2011 University of Gothenburg. All rights reserved.
//

#import "UsersDataSource.h"
#import <CommonCrypto/CommonDigest.h>


/*
 Convert NSData to hex string.
 */
@interface NSData (NSData_HexAdditions)
- (NSString *)getBytesAsHexString;
@end

@implementation NSData (NSData_HexAdditions)
- (NSString *)getBytesAsHexString {
	NSMutableString *hexString = [NSMutableString stringWithCapacity:([self length] * 2)];
	const unsigned char *data = [self bytes];
	for (int i = 0; i < [self length]; ++i) {
		[hexString appendFormat:@"%02x", data[i]];
	}
	return hexString;
}
@end


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

// Salt and hash password.
- (NSData *)hashPassword:(NSString *)password
{
    CC_SHA256_CTX context; // There is no CC_SHA224_CTX, documentation is wrong.
    unsigned char digest[32];
    u_int32_t *salt = (u_int32_t *)digest;
    
    CC_SHA224_Init(&context);
    
    *salt = arc4random();
    CC_SHA224_Update(&context, digest, 4);
    
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    CC_SHA224_Update(&context, [passwordData bytes], [passwordData length]);
    CC_SHA224_Final(&digest[4], &context);
    
    return [NSData dataWithBytes:digest length:sizeof(digest)];
}

// Add a user at the end.
- (void)addUser
{
    [users addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                      @"username", @"",
                      @"realname", @"",
                      @"password", @"",
                      @"hasAdmin", [NSNumber numberWithBool:NO],
                      @"hasView", [NSNumber numberWithBool:NO],
                      nil]];
}

// Remove a user.
- (void)removeUserAtIndex:(NSInteger)index
{
    NSParameterAssert(index >= 0 && index < [users count]);
    [users removeObjectAtIndex:index];
}


/*
 NSTableViewDataSource
 */

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
    row:(NSInteger)rowIndex
{
    NSDictionary *theUser;
    id theValue;
    
    NSParameterAssert(rowIndex >= 0 && rowIndex < [users count]);
    theUser = [users objectAtIndex:rowIndex];
    theValue = [theUser objectForKey:[aTableColumn identifier]];
    if ([[aTableColumn identifier] isEqualToString:@"password"]) {
        return @"••••••••";
    } else {
        return theValue;
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [users count];
}


/*
 NSTableViewDelegate
 */

- (void)tableView:(NSTableView *)aTableView
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn
              row:(NSInteger)rowIndex
{
    NSDictionary *theUser = [users objectAtIndex:rowIndex];
    if ([[aTableColumn identifier] isEqualToString:@"password"]) {
        NSData *hashedPassword = [self hashPassword:anObject];
        NSString *hexHashedPassword = [hashedPassword getBytesAsHexString];
        [theUser setValue:hexHashedPassword forKey:[aTableColumn identifier]];
    } else {
        [theUser setValue:anObject forKey:[aTableColumn identifier]];
    }
}

//selectionShouldChangeInTableView:
//tableView:shouldEditTableColumn:row:
//tableViewSelectionDidChange:        NSTableViewSelectionDidChangeNotification
//tableViewSelectionIsChanging:        NSTableViewSelectionIsChangingNotification

/*
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    return YES;
}
*/

@end
