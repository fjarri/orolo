//
//  oroloMenulet.m
//  orolo
//
//  Created by Bogdan Opanchuk on 30/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Menulet.h"
#import "CalendarModel.h"


@implementation Menulet

- (void)dealloc {
	[calendarModel release];
    [statusItem release];
	[colorUpdateTimer release];
	[realTimeTimer release];
	[hkm release];
	[dateFormatter release];
	[statusIcon release];
	[super dealloc];
}

- (void)awakeFromNib {
	showingRealTime = NO;
	closestEvent = nil;

	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];

	NSString* imageName = [[NSBundle mainBundle] pathForResource:@"icon-menubar" ofType:@"png"];
	statusIcon = [[NSImage alloc] initWithContentsOfFile:imageName];

	statusItem = [[[NSStatusBar systemStatusBar]
				   statusItemWithLength:NSVariableStatusItemLength]
				  retain];
	[statusItem setHighlightMode:YES];
	[self setNoEventsStatus];
	[statusItem setEnabled:YES];
	[statusItem setToolTip:@"Orolo"]; // FIXME: remove hardcode

	// Tune menu
	[statusItem setMenu:theMenu];
	[theMenu setAutoenablesItems:NO];

	[menuFullTitle setTitle:[NSString stringWithFormat:@"%C", 0x221E]]; // FIXME: remove hardcode

	// Set a hotkey
	hkm = [[JFHotkeyManager alloc] init];
	[hkm bindKeyRef:1 // 's' key
	  withModifiers:cmdKey + controlKey
			 target:self
			 action:@selector(actionShowRealTime:)];

	[menuShowRealTime setKeyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
	[menuShowRealTime setKeyEquivalent:@"s"]; // FIXME: remove hardcode


	calendarModel = [[CalendarModel alloc] initWithTarget:self
												  selector:@selector(calendarsChanged:)];

	colorUpdateTimer = [[NSTimer
					scheduledTimerWithTimeInterval:60.0 // FIXME: remove hardcode
					target:self
					selector:@selector(updateColor:)
					userInfo:nil
					repeats:YES]
				   retain];
	[colorUpdateTimer fire];
}

- (void)calendarsChanged:(NSNotification *)notification {
	closestEvent = [calendarModel closest_event];
	[self updateStatus];
}

- (IBAction)updateColor:(NSTimer*)theTimer {
	[self updateStatus];
}

- (void)updateStatus {
	if (showingRealTime) {
		[self setTextStatus:[dateFormatter stringFromDate:[NSDate date]]];
	}
	else {
		if (closestEvent) {
			[self setTextStatus:[closestEvent title]];
		}
		else {
			[self setNoEventsStatus];
		}
	}
}

- (IBAction)actionQuit:(id)sender {
	[NSApp terminate:sender];
}

- (void)stopShowingRealTime:(NSTimer*)theTimer {
	showingRealTime = NO;
	[self updateStatus];
}

- (IBAction)actionShowRealTime:(id)sender {
	if (!showingRealTime) {
		showingRealTime = YES;
		realTimeTimer = [NSTimer
						  scheduledTimerWithTimeInterval:5.0 // FIXME: remove hardcode
						  target:self
						  selector:@selector(stopShowingRealTime:)
						  userInfo:nil
						  repeats:NO];
		[self updateStatus];
	}
}

- (void)setNoEventsStatus {
	[statusItem setTitle:@""];
	[statusItem setImage:statusIcon];
}

- (void)setTextStatus:(NSString *)title {
	[statusItem setImage:nil];
	[statusItem setTitle:title];
}

@end
