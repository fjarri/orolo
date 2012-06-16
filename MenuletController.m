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
#import "PreferencesModel.h"
#import "AboutController.h"
#import "JFHotkeyManager.h"
#import "StatusItemView.h"

// TODO: move to preferences?
static float colorUpdateInterval = 10.0;
static float realTimeInterval = 5.0;


@implementation MenuletController

+ (void)initialize {
	[PreferencesModel setDefaults];
}


- (void)dealloc {
	[PreferencesModel removeObserver:self];
	[CalendarModel removeEventsObserver:self];
	[CalendarModel removeCalendarsObserver:self];

	[calendarModel release];
    [statusItem release];
	[colorUpdateTimer release];
	[realTimeTimer release];
	[hkm release];
	[dateFormatter release];
	[super dealloc];
}

- (void)awakeFromNib {
	showingRealTime = NO;

	// prepare date formatter
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];

	statusItem = [[[NSStatusBar systemStatusBar]
				   statusItemWithLength:NSVariableStatusItemLength]
				  retain];
	statusItemView = [[[StatusItemView alloc] init] retain];
	statusItemView.statusItem = statusItem;
	[statusItemView setMenu:theMenu];
	[statusItem setView:statusItemView];

	// Tune menu
	[statusItem setMenu:theMenu];
	[theMenu setAutoenablesItems:NO];

	[self setNoEventsStatus];

	// Set a hotkey
	hkm = [[JFHotkeyManager alloc] init];
	[hkm bindKeyRef:1 // 's' key
	  withModifiers:cmdKey + controlKey
			 target:self
			 action:@selector(actionShowRealTime:)];

	[menuShowRealTime setKeyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
	[menuShowRealTime setKeyEquivalent:@"s"]; // FIXME: remove hardcode


	calendarModel = [[CalendarModel alloc] init];

	colorUpdateTimer = [[NSTimer
					scheduledTimerWithTimeInterval:colorUpdateInterval
					target:self
					selector:@selector(updateColor:)
					userInfo:nil
					repeats:YES]
				   retain];
	[colorUpdateTimer fire];

	// prepare notifications
	[CalendarModel addEventsObserver:self selector:@selector(calendarsChanged:)];
	[CalendarModel addCalendarsObserver:self selector:@selector(calendarsChanged:)];
	[PreferencesModel addObserver:self selector:@selector(preferencesChanged:)];

	[self updateStatus];
}

- (void)preferencesChanged:(NSNotification *)notification {
	[self updateStatus];
}

- (void)calendarsChanged:(NSNotification *)notification {
	[self updateStatus];
}

- (void)updateColor:(NSTimer*)theTimer {
	[self updateStatus];
}

- (void)updateStatus {
	if (showingRealTime) {
		[self setTextStatus:[dateFormatter stringFromDate:[NSDate date]] withColor:[NSColor blackColor]];
		return;
	}

	CalResult *closest_event = [calendarModel closestEvent];

	if (closest_event) {
		float fraction = [closest_event fraction];

		NSColor *target_color = [closest_event isForward] ?
			[PreferencesModel prefFadeInColor] :
			[PreferencesModel prefFadeOutColor];

		NSColor *starting_color = [NSColor controlTextColor];
		NSColor *color = [target_color blendedColorWithFraction:fraction ofColor:starting_color];

		NSString *full_event_title = [[closest_event event] title];
		NSString *event_title;
		int max_length = [PreferencesModel prefTitleLength];
		if (full_event_title.length > max_length) {
			event_title = [full_event_title substringToIndex:max_length];
			event_title = [event_title stringByAppendingString:@"..."];
		}
		else {
			event_title = full_event_title;
		}

		NSString *type_marker = [closest_event isBeginning] ?
			NSLocalizedString(@"Starts: ", nil) :
			NSLocalizedString(@"Ends: ", nil);
		NSString *type_symbol = [closest_event isBeginning] ?
			NSLocalizedString(@"START_SYMBOL", nil) :
			NSLocalizedString(@"STOP_SYMBOL", nil);

		[self setTextStatus:[type_symbol stringByAppendingString:event_title] withColor:color];
		[menuFullTitle setTitle:[type_marker stringByAppendingString:full_event_title]];
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
	[statusItemView setImage:nil
				   withTitle:NSLocalizedString(@"NO_EVENTS_SYMBOL", nil)
				   withColor:[NSColor controlTextColor]];
	[menuFullTitle setTitle:NSLocalizedString(@"<No events>", nil)];
}

- (void)setTextStatus:(NSString *)title withColor:(NSColor *)color {
	[statusItemView setImage:nil withTitle:title withColor:color];
}

@end
