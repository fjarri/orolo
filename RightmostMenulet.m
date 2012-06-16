//
//  RightmostMenulet.m
//  orolo
//
//  Created by Bogdan Opanchuk on 16/06/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RightmostMenulet.h"


@implementation RightmostMenulet

@synthesize statusItem;

- (void)restartSystemUIServer {
    NSTask *killSystemUITask = [[[NSTask alloc] init] autorelease];
    NSMutableArray *args = [NSMutableArray array];
    [args addObject:@"SystemUIServer"];
    [args addObject:@"-HUP"];
    [killSystemUITask setLaunchPath:@"/usr/bin/killall"];
    [killSystemUITask setArguments:args];
    [killSystemUITask launch];
}

- (NSStatusItem *)itemWithRestart {
	return nil;
}

- (NSStatusItem *)itemWithoutRestart {
	return nil;
}

- (NSStatusItem *)itemFallback {
	return [[NSStatusBar systemStatusBar]
			statusItemWithLength:NSVariableStatusItemLength];
}


- (RightmostMenulet *)init {
	self = [super init];

	// try to apply private API
	statusItem = [self itemWithoutRestart];
	if (!statusItem) {
		// fallback to usual non-rightmost item
		statusItem = [self itemFallback];
	}
	[statusItem retain];

	return self;
}

- (void)dealloc {
	[statusItem release];
	[super dealloc];
}

@end
