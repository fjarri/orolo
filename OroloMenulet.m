//
//  oroloMenulet.m
//  orolo
//
//  Created by Bogdan Opanchuk on 30/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "OroloMenulet.h"
#import "CalendarModel.h"


@implementation OroloMenulet

- (void)dealloc {
	[calendarModel release];
    [statusItem release];
	[updateTimer release];
	[super dealloc];
}

- (void)awakeFromNib {
	statusItem = [[[NSStatusBar systemStatusBar]
				   statusItemWithLength:NSVariableStatusItemLength]
				  retain];
	[statusItem setHighlightMode:YES];
	[statusItem setTitle:[NSString stringWithFormat:@"%C", 0x221E]];
	[statusItem setEnabled:YES];
	[statusItem setToolTip:@"Orolo"];

	// Tune menu
	[statusItem setMenu:theMenu];
	[theMenu setAutoenablesItems:NO];

	[menuFullTitle setEnabled:NO];
	[menuFullTitle setTitle:[NSString stringWithFormat:@"%C", 0x221E]];

	//ipMenuItem = [[NSMenuItem alloc] initWithTitle:@"0.0.0.0"
	//										action:@selector(updateIPAddress:) keyEquivalent:@""];
	//[ipMenuItem setTarget:self];
	//[theMenu insertItem:ipMenuItem atIndex:1];

	//[statusItem setAction:@selector(updateTime:)];
	//[statusItem setTarget:self];

	calendarModel = [[[CalendarModel alloc] initWithTarget:self selector:@selector(calendarsChanged:)]
					 retain];



	updateTimer = [[NSTimer
					scheduledTimerWithTimeInterval:60.0
					target:self
					selector:@selector(timerUpdated:)
					userInfo:nil
					repeats:YES]
				   retain];
	[updateTimer fire];
}

- (void)calendarsChanged:(NSNotification *)notification {
	[self updateTime];
}

- (IBAction)timerUpdated:(id)sender {
	[self updateTime];
}

- (void)updateTime {
//	NSString *time = [NSString stringWithString:@"":];
	id event = [calendarModel closest_event];
	if (event) {
		[statusItem setTitle:[event title]];
	}
	else {
		[statusItem setTitle:[NSString stringWithFormat:@"%C", 0x221E]];
	}
}

- (IBAction)quit:(id)sender {
	[NSApp terminate:sender];
}

@end
