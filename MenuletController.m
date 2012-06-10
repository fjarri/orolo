//
//  oroloMenulet.m
//  orolo
//
//  Created by Bogdan Opanchuk on 30/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CalendarStore/CalendarStore.h>
#import "MenuletController.h"
#import "CalendarModel.h"
#import "PreferencesController.h"
#import "AboutController.h"
#import "JFHotkeyManager.h"
#import "StatusItemView.h"

// TODO: move to preferences?
static float colorUpdateInterval = 10.0;
static float realTimeInterval = 5.0;

@implementation MenuletController

+ (void)initialize {
	[PreferencesController setDefaults];
}


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

	// prepare date formatter
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];

	NSString* imageName = [[NSBundle mainBundle] pathForResource:@"icon-menubar" ofType:@"png"];
	statusIcon = [[NSImage alloc] initWithContentsOfFile:imageName];

	statusItem = [[[NSStatusBar systemStatusBar]
				   statusItemWithLength:NSVariableStatusItemLength]
				  retain];
	statusItemView = [[[StatusItemView alloc] init] retain];
	statusItemView.statusItem = statusItem;
	[statusItemView setMenu:theMenu];
	[statusItem setView:statusItemView];

	[self setNoEventsStatus];

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


	calendarModel = [[CalendarModel alloc] init];
	[CalendarModel addEventsObserver:self selector:@selector(calendarsChanged:)];
	[CalendarModel addCalendarsObserver:self selector:@selector(calendarsChanged:)];

	colorUpdateTimer = [[NSTimer
					scheduledTimerWithTimeInterval:colorUpdateInterval
					target:self
					selector:@selector(updateColor:)
					userInfo:nil
					repeats:YES]
				   retain];
	[colorUpdateTimer fire];

	// prepare notification for changed settings
	[PreferencesController addObserver:self selector:@selector(preferencesChanged:)];

	[self updateClosestEvent];
	[self updateStatus];
}

- (void)preferencesChanged:(NSNotification *)notification {
	[self updateStatus];
}

- (void)updateClosestEvent {
	CalResult *newClosestEvent = [[calendarModel closestEvent] retain];
	[closestEvent release];
	closestEvent = newClosestEvent;
}

- (void)calendarsChanged:(NSNotification *)notification {
	closestEvent = [[calendarModel closestEvent] retain];
	[self updateStatus];
}

- (void)updateColor:(NSTimer*)theTimer {
	[self updateStatus];
}

- (void)updateStatus {
	if (showingRealTime) {
		[self setTextStatus:[dateFormatter stringFromDate:[NSDate date]] withColor:[NSColor blackColor]];
	}
	else if (closestEvent) {
		float fraction = [closestEvent fraction];

		NSColor *targetColor = [closestEvent isForward] ?
			[PreferencesController prefFadeInColor] :
			[PreferencesController prefFadeOutColor];

		NSColor *startingColor = [NSColor controlTextColor];
		NSColor *color = [targetColor blendedColorWithFraction:fraction ofColor:startingColor];

		[self setTextStatus:[[closestEvent event] title] withColor:color];
	}
	else {
		[self setNoEventsStatus];
	}
}

- (IBAction)actionPreferences:(id)sender {
	if (!preferencesController) {
		preferencesController = [[PreferencesController alloc] init];
	}
	[preferencesController showWindow:self];
}

- (IBAction)actionAbout:(id)sender {
	if (!aboutController) {
		aboutController = [[AboutController alloc] init];
	}
	[aboutController showWindow:self];
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
						  scheduledTimerWithTimeInterval:realTimeInterval
						  target:self
						  selector:@selector(stopShowingRealTime:)
						  userInfo:nil
						  repeats:NO];
		[self updateStatus];
	}
}

- (void)setNoEventsStatus {
	[statusItemView setImage:statusIcon withTitle:nil withColor:nil];
}

- (void)setTextStatus:(NSString *)title withColor:(NSColor *)color {
	[statusItemView setImage:nil withTitle:title withColor:color];
}

@end
