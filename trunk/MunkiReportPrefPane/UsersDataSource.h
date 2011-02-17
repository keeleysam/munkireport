//
//  UsersDataSource.h
//  MunkiReportPrefPane
//
//  Created by Pelle on 2011-02-17.
//  Copyright 2011 University of Gothenburg. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface UsersDataSource : NSObject {
	NSMutableArray *users;
}

- (int)loadUsersFile:(NSString *)usersPath;

@end
