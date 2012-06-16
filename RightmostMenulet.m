//
//  RightmostMenulet.m
//  orolo
//
//  Created by Bogdan Opanchuk on 16/06/12.
//  Copyright 2012 Bogdan Opanchuk. All rights reserved.
//

#import "RightmostMenulet.h"

static const int RightmostPriority = INT_MAX - 1; // INT_MAX seems to be the priority of Spotlight


// Private status bar API
@interface NSStatusBar (NSStatusBar_Private)
- (id)_statusItemWithLength:(float)l withPriority:(int)p;
- (id)_insertStatusItem:(NSStatusItem *)i withPriority:(int)p;
@end


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
	// This method makes a bit of a fuss, but is more reliable

	NSStatusBar *status_bar = [NSStatusBar systemStatusBar];
	NSStatusItem *status_item = nil;

	if ([status_bar respondsToSelector:@selector(_statusItemWithLength:withPriority:)]) {
        if (!status_item) {
            status_item = [status_bar _statusItemWithLength:0 withPriority:INT_MAX-1];
        }
        [status_item setLength:NSVariableStatusItemLength];
        [self restartSystemUIServer];
    }
	return status_item;
}

- (void)positionItemWithoutRestart:(NSStatusItem *)item {
	// Warning: should be called only if corresponding selectors are supported.

	NSStatusBar *status_bar = [NSStatusBar systemStatusBar];
	[status_bar removeStatusItem:item];
	[status_bar _insertStatusItem:item withPriority:RightmostPriority];
	[item setLength:NSVariableStatusItemLength];
}

- (void)menuIsRecreated:(NSNotification *)notification {
	[self positionItemWithoutRestart:statusItem];
}

- (NSStatusItem *)itemWithoutRestart {
	// This method has been reported to glitch in Lion's fullscreen mode

	NSStatusBar *status_bar = [NSStatusBar systemStatusBar];
	NSStatusItem *status_item = nil;

	if ([status_bar respondsToSelector:@selector(_statusItemWithLength:withPriority:)] &&
		[status_bar respondsToSelector:@selector(_insertStatusItem:withPriority:)]) {
		status_item = [status_bar _statusItemWithLength:0
										   withPriority:RightmostPriority];
		[self positionItemWithoutRestart:status_item];
	}

	// In Snow Leopard, if user manually calls 'killall SystemUIServer',
	// the menulet moves to the right side of the Spotlight icon.
	// We have to catch this event and reposition our menulet.
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self
														selector:@selector(menuIsRecreated:)
															name:@"com.apple.menuextra.added"
														  object:nil];

	return status_item;
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
	else {
		// When the application quits, in case of 'hacky' menulet there remains an empty place in the menubar.
		// So we are restarting SystemUIServer to return everything back to normal.
		NSNotificationCenter *ncenter = [NSNotificationCenter defaultCenter];
		[ncenter addObserver:self
					selector:@selector(restartSystemUIServer)
						name:NSApplicationWillTerminateNotification
					  object:nil];
	}

	[statusItem retain];

	return self;
}

- (void)dealloc {
	[statusItem release];
	[super dealloc];
}

@end
