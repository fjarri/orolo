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

- (void)dealloc
{
    [statusItem release];
	[updateTimer release];
	[super dealloc];
}

- (void)awakeFromNib
{
	statusItem = [[[NSStatusBar systemStatusBar]
				   statusItemWithLength:NSVariableStatusItemLength]
				  retain];
	[statusItem setHighlightMode:YES];
	[statusItem setTitle:[NSString stringWithFormat:@"%C", 0x221E]];
	[statusItem setEnabled:YES];
	[statusItem setToolTip:@"Orolo"];

	[statusItem setMenu:theMenu];
	//ipMenuItem = [[NSMenuItem alloc] initWithTitle:@"0.0.0.0"
	//										action:@selector(updateIPAddress:) keyEquivalent:@""];
	//[ipMenuItem setTarget:self];
	//[theMenu insertItem:ipMenuItem atIndex:1];

	//[statusItem setAction:@selector(updateTime:)];
	//[statusItem setTarget:self];

	updateTimer = [[NSTimer
					scheduledTimerWithTimeInterval:60.0
					target:self
					selector:@selector(updateTime:)
					userInfo:nil
					repeats:YES]
				   retain];
	[updateTimer fire];
}

- (IBAction)updateTime:(id)sender
{
//	NSString *time = [NSString stringWithString:@"":];
	CalendarModel *cm = [[CalendarModel alloc] init];
	id event = [cm closest_event];
	[statusItem setTitle: [event title]];
}

@end
