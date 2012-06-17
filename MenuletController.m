//
//  oroloMenulet.m
//  orolo
//
//  Created by Bogdan Opanchuk on 30/05/12.
//  Copyright 2012 Bogdan Opanchuk. All rights reserved.
//

#import <CalendarStore/CalendarStore.h>
#import "MenuletController.h"
#import "CalendarModel.h"
#import "PreferencesController.h"
#import "PreferencesModel.h"
#import "JFHotkeyManager.h"
#import "StatusItemView.h"
#import "RightmostMenulet.h"


// TODO: move to preferences?
static float colorUpdateInterval = 10.0; // interval for color update in Show Events mode
static float briefShowInterval = 5.0; // interval for briefly showing some info in status


@implementation MenuletController

+ (void)initialize {
	[PreferencesModel setDefaults];
}


- (void)dealloc {
	[PreferencesModel removeObserver:self];
	[CalendarModel removeEventsObserver:self];
	[CalendarModel removeCalendarsObserver:self];

	[calendarModel release];
    [menulet release];
	[constantUpdateTimer invalidate];

	[hkm release];
	[dateFormatter release];
	[super dealloc];
}

- (void)awakeFromNib {
	menuletMode = MenuletModeEvents;
	menuletState = MenuletStateMode;

	// prepare date formatter
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];

	menulet = [[[RightmostMenulet alloc] init] retain];
	statusItemView = [[[StatusItemView alloc] init] retain];
	// FIXME: do view and menulet really need to reference each other?
	statusItemView.statusItem = menulet.statusItem;
	[statusItemView setMenu:theMenu];
	[menulet.statusItem setView:statusItemView];

	// Tune menu
	[theMenu setAutoenablesItems:NO];

	[self setNoEventsStatus];

	// Set hotkeys
	hkm = [[JFHotkeyManager alloc] init];

	[hkm bindKeyRef:1 // 's' key
	  withModifiers:cmdKey + controlKey
			 target:self
			 action:@selector(actionShowRealTime:)];
	[menuShowRealTime setKeyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
	[menuShowRealTime setKeyEquivalent:@"s"]; // FIXME: remove hardcode

	[hkm bindKeyRef:0x0E // 'e' key
	  withModifiers:cmdKey + controlKey
			 target:self
			 action:@selector(actionShowTimeTillNextEvent:)];
	[menuShowTimeTillNextEvent setKeyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
	[menuShowTimeTillNextEvent setKeyEquivalent:@"e"]; // FIXME: remove hardcode

	[hkm bindKeyRef:0x11 // 't' key
	  withModifiers:cmdKey + controlKey
			 target:self
			 action:@selector(actionConstantlyShowRealTime:)];
	[menuConstantlyShowRealTime setKeyEquivalentModifierMask: NSControlKeyMask | NSCommandKeyMask];
	[menuConstantlyShowRealTime setKeyEquivalent:@"t"]; // FIXME: remove hardcode


	calendarModel = [[CalendarModel alloc] init];
	[self updateStatus];

	constantUpdateTimer = nil;
	[self setTimerForMode];

	// prepare notifications
	[CalendarModel addEventsObserver:self selector:@selector(calendarsChanged:)];
	[CalendarModel addCalendarsObserver:self selector:@selector(calendarsChanged:)];
	[PreferencesModel addObserver:self selector:@selector(preferencesChanged:)];

}

- (void)preferencesChanged:(NSNotification *)notification {
	[self updateStatus];
}

- (void)calendarsChanged:(NSNotification *)notification {
	[self updateStatus];
}

- (void)setTimerForMode {
	[constantUpdateTimer invalidate];
	if (menuletMode == MenuletModeEvents) {
		constantUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:colorUpdateInterval
															   target:self
															 selector:@selector(updateColor:)
															 userInfo:nil
															  repeats:YES];
	}
	else {
		// calculate the closest date with whole number of minutes
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		NSUInteger comp_flags = NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit
			| NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
		NSDateComponents *components = [gregorian components:comp_flags
													fromDate:[NSDate date]];
		[components setMinute:[components minute] + 1]; // hours and other greater units will update automatically
		NSDate *date = [gregorian dateFromComponents:components];
		[gregorian release];

		constantUpdateTimer = [[[NSTimer alloc] initWithFireDate:date
													   interval:60
														 target:self
													   selector:@selector(updateColor:)
													   userInfo:nil
														repeats:YES] autorelease];
		[[NSRunLoop currentRunLoop] addTimer:constantUpdateTimer
									 forMode:NSDefaultRunLoopMode];
	}
}

- (void)updateColor:(NSTimer*)theTimer {
	[self updateStatus];
}

- (void)updateStatus {
	if (menuletMode == MenuletModeEvents && menuletState == MenuletStateMode) {

		CalResult *closest_event = [calendarModel closestEvent];

		if (!closest_event) {
			[self setNoEventsStatus];
			return;
		}

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
	else if (menuletState == MenuletStateTimeRemaining) {
		CalResult *closest_event = [calendarModel closestFutureEvent];
		if(!closest_event) {
			[self setTextStatus:NSLocalizedString(@">day", nil)
					  withColor:[NSColor controlTextColor]];
		}
		int hours = [closest_event distance] / 60.0;
		int minutes = [closest_event distance] - hours * 60;
		NSString *status;
		if (hours == 0) {
			status = [NSString stringWithFormat:NSLocalizedString(@"~%d minutes", nil), minutes];
		}
		else {
			status = [NSString stringWithFormat:NSLocalizedString(@"~%d hours", nil), hours];
		}
		[self setTextStatus:status withColor:[NSColor controlTextColor]];
	}
	else {
		[self setTextStatus:[dateFormatter stringFromDate:[NSDate date]] withColor:[NSColor controlTextColor]];
	}
}

- (IBAction)actionPreferences:(id)sender {
	if (!preferencesController) {
		preferencesController = [[PreferencesController alloc] init];
	}
	[preferencesController showWindow:self];
}

- (IBAction)actionAbout:(id)sender {
	[NSApp orderFrontStandardAboutPanel:sender];
}

- (IBAction)actionQuit:(id)sender {
	[NSApp terminate:sender];
}

- (void)restoreStateToMode:(NSTimer*)theTimer {
	menuletState = MenuletStateMode;
	[self updateStatus];
}

- (IBAction)actionShowRealTime:(id)sender {
	if (menuletMode == MenuletModeEvents && menuletState == MenuletStateMode) {
		menuletState = MenuletStateTimeBriefly;
		briefStatusTimer = [NSTimer
						  scheduledTimerWithTimeInterval:briefShowInterval
						  target:self
						selector:@selector(restoreStateToMode:)
						  userInfo:nil
						  repeats:NO];
		[self updateStatus];
	}
}

- (IBAction)actionConstantlyShowRealTime:(id)sender {
	[menuConstantlyShowRealTime setState:![menuConstantlyShowRealTime state]];
	if (menuletMode == MenuletModeEvents) {
		menuletMode = MenuletModeTime;
	}
	else {
		menuletMode = MenuletModeEvents;
	}
	[self setTimerForMode];
	[self updateStatus];
}

- (IBAction)actionShowTimeTillNextEvent:(id)sender {
	if (menuletState == MenuletStateMode) {
		menuletState = MenuletStateTimeRemaining;
		briefStatusTimer = [NSTimer
							scheduledTimerWithTimeInterval:briefShowInterval
							target:self
							selector:@selector(restoreStateToMode:)
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
