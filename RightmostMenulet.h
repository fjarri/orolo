//
//  RightmostMenulet.h
//  orolo
//
//  Created by Bogdan Opanchuk on 16/06/12.
//  Copyright 2012 Bogdan Opanchuk. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RightmostMenulet : NSObject {
	NSStatusItem *statusItem;
}

@property (readonly) NSStatusItem *statusItem;

@end
