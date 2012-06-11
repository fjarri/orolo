//
//  LoginItemsModel.h
//  orolo
//
//  Created by Bogdan Opanchuk on 11/06/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
//  Code taken from: https://github.com/carpeaqua/Shared-File-List-Example

#import <Cocoa/Cocoa.h>


@interface LoginItemsModel : NSObject {
	LSSharedFileListRef loginItems;
	NSString *appPath;
}

- (void)enableLoginItem;
- (void)disableLoginItem;
- (BOOL)loginItemExists;

@end
