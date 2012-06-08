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
	[hkm release];
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

	// Set a hotkey
	hkm = [[JFHotkeyManager alloc] init];
	[hkm bindKeyRef:1 // 's' key
	  withModifiers:cmdKey + controlKey
			 target:self
			 action:@selector(actionShowRealTime:)];

	[menuShowRealTime setKeyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
	[menuShowRealTime setKeyEquivalent:@"s"];


	calendarModel = [[CalendarModel alloc] initWithTarget:self
												  selector:@selector(calendarsChanged:)];

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

- (IBAction)actionQuit:(id)sender {
	[NSApp terminate:sender];
}

- (IBAction)actionShowRealTime:(id)sender {
	[statusItem setTitle:@"FIXME: time here"];
}

@end
