//
//  PreferencesController.m
//  orolo
//
//  Created by Bogdan Opanchuk on 9/06/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CalendarStore/CalendarStore.h>
#import "PreferencesController.h"
#import "LoginItemsModel.h"
#import "CalendarModel.h"
#import "PreferencesModel.h"


@implementation IntegerForcingDelegate

- (IBAction)controlTextDidChange:(NSNotification *)aNotification
{
    NSControl *text_field = [aNotification object];
    NSString *text = [text_field stringValue];

	NSMutableString *new_text = [NSMutableString
								 stringWithCapacity:text.length];

	for (int i=0; i < text.length; i++) {
		unichar c = [text characterAtIndex:i];
        if (isdigit(c)) {
			[new_text appendFormat:@"%c", c];
        }
	}

	if (new_text.length == 0) {
		[new_text appendString:@"1"];
	}

	[text_field setStringValue:new_text];
}

@end


@implementation CalendarListSource

- (CalendarListSource *)init {
	self = [super init];

	calendarModel = [[[CalendarModel alloc] init] retain];

	calendarTitles = [[NSMutableArray alloc] init];
	watchedList = [[NSMutableArray alloc] init];
	calendarUIDs = [[NSMutableArray alloc] init];

	[self update];

	return self;
}

- (void)dealloc {
	[calendarModel release];
	[calendarTitles release];
	[calendarUIDs release];
	[watchedList release];
	[super dealloc];
}

- (void)update {
	NSArray *calendars = [calendarModel calendars];

	NSArray *watched_uids = [PreferencesModel prefCalendarUIDs];

	[calendarUIDs removeAllObjects];
	[calendarTitles removeAllObjects];
	for (CalCalendar *cldr in calendars) {
		[calendarTitles addObject:[cldr title]];
		[calendarUIDs addObject:[cldr uid]];
	}

	[watchedList removeAllObjects];
	for (CalCalendar *cldr in calendars) {
		BOOL is_watched = (!watched_uids) || [watched_uids containsObject:[cldr uid]];
		[watchedList addObject:[NSNumber numberWithBool:is_watched]];
	}
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	return calendarTitles.count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	if ([[aTableColumn identifier] isEqualToString:@"IsWatched"]) {
		return [watchedList objectAtIndex:rowIndex];
	}
	else {
		return [calendarTitles objectAtIndex:rowIndex];
	}
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	if ([[aTableColumn identifier] isEqualToString:@"IsWatched"]) {
		[watchedList replaceObjectAtIndex:rowIndex withObject:[NSNumber numberWithBool:[anObject boolValue]]];

		NSMutableArray *watched_uids = [[[NSMutableArray alloc] init] autorelease];
		for (int i = 0; i < watchedList.count; i++) {
			if ([[watchedList objectAtIndex:i] boolValue]) {
				[watched_uids addObject:[calendarUIDs objectAtIndex:i]];
			}
		}
		[PreferencesModel setPrefCalendarUIDs:watched_uids];
	}
}

@end


@implementation PreferencesController

+ (void)initialize {
	[CalendarModel addCalendarsObserver:self selector:@selector(calendarsUpdated:)];
}

+ (void)calendarsUpdated:(NSNotification *)notification {
	// This method cleans preferences from outdated UIDs.
	// It may be called at the same time with instance calendarsUpdated: method,
	// but that's ok, since old UIDs will just be ignored there.

	NSArray *uids = [PreferencesModel prefCalendarUIDs];
	if (!uids) {
		return;
	}

	CalendarModel *calendarModel = [[[CalendarModel alloc] init] autorelease];
	NSArray *calendars = [calendarModel calendars];
	NSMutableArray *existing_uids = [[[NSMutableArray alloc] init] autorelease];
	NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];

	for (CalCalendar *cldr in calendars) {
		[existing_uids addObject:[cldr uid]];
	}

	for (NSString *uid in uids) {
		if ([existing_uids containsObject:uid]) {
			[result addObject:uid];
		}
	}
	[PreferencesModel setPrefCalendarUIDs:result];
}


- (id)init {
	self = [super initWithWindowNibName:@"Preferences"];
	ifDelegate = [[IntegerForcingDelegate alloc] init];
	calendarListSource = [[CalendarListSource alloc] init];
	calendarModel = [[CalendarModel alloc] init];

	[CalendarModel addCalendarsObserver:self selector:@selector(calendarsUpdated:)];

	return self;
}

- (void)dealloc {
	[CalendarModel removeCalendarsObserver:self];

	[calendarModel release];
	[calendarListSource release];
	[ifDelegate release];
	[super dealloc];
}

- (void)awakeFromNib {
	[fadeInInterval setDelegate:ifDelegate];
	[fadeOutInterval setDelegate:ifDelegate];
	[titleLength setDelegate:ifDelegate];
	[calendarList setDataSource:calendarListSource];
	[calendarList reloadData];
}

- (void)windowDidLoad {
	[super windowDidLoad];

	[fadeInColorWell setColor:[PreferencesModel prefFadeInColor]];
	[fadeOutColorWell setColor:[PreferencesModel prefFadeOutColor]];
	[launchAtLogin setState:[PreferencesModel prefLaunchAtLogin]];

	int fade_in = [PreferencesModel prefFadeInInterval];
	int fade_out = [PreferencesModel prefFadeOutInterval];
	[fadeInInterval setIntValue:fade_in];
	if (fade_out == 0) {
		[fadeOutEnabled setState:NO];
	}
	else {
		[fadeOutEnabled setState:YES];
		[fadeOutInterval setIntValue:fade_out];
	}
	[self changeFadeOutEnabled:nil];

	BOOL watching_all = ![PreferencesModel prefCalendarUIDs];
	[watchAllCalendars setState:watching_all];
	[self updateCalendarList:!watching_all];

	[titleLength setIntValue:[PreferencesModel prefTitleLength]];
}

- (void)calendarsUpdated:(NSNotification *)aNotification {
	[calendarListSource update];
	[calendarList reloadData];
}

- (void)updateCalendarList:(BOOL)enabled {
	[calendarListSource update];
	if (!enabled) {
		// setting to enabled because otherwise reloadData: will have no effect
		[calendarList setEnabled:YES]; 
	}
	[calendarList reloadData];
	[calendarList setEnabled:enabled];
}

- (IBAction)showWindow:(id)sender {
	[super showWindow:sender];

	// HACK: Since we do not have a main window, in case when the Preferences window was not closed,
	// then lost focus and moved to back, and user requests Preferences again,
	// showWindow is not enough to make it visible.
	// Therefore we briefly raise its level which makes it topmost,
	// and then lower level again so it could be moved to back again.
	[self.window setLevel: NSMainMenuWindowLevel];
	[self.window makeKeyAndOrderFront:sender];
	[self.window setLevel: NSNormalWindowLevel];
}

- (IBAction)changeFadeInColor:(id)sender {
	[PreferencesModel setPrefFadeInColor:[fadeInColorWell color]];
}

- (IBAction)changeFadeOutColor:(id)sender {
	[PreferencesModel setPrefFadeOutColor:[fadeOutColorWell color]];
}

- (IBAction)changeLaunchAtLogin:(id)sender {
	[PreferencesModel setPrefLaunchAtLogin:[launchAtLogin state]];
}

- (IBAction)changeFadeInInterval:(id)sender {
	[PreferencesModel setPrefFadeInInterval:[fadeInInterval intValue]];
}

- (IBAction)changeFadeOutInterval:(id)sender {
	[PreferencesModel setPrefFadeOutInterval:[fadeOutInterval intValue]];
}

- (IBAction)changeFadeOutEnabled:(id)sender {
	BOOL state = [fadeOutEnabled state];
	[fadeOutInterval setEnabled:state];
	[fadeOutColorWell setEnabled:state];

	if (state) {
		[fadeOutInterval setIntValue:1];
		[self changeFadeOutInterval:sender];
	}
	else {
		[fadeOutInterval setStringValue:@""];
		[PreferencesModel setPrefFadeOutInterval:0];
	}
}

- (IBAction)changeWatchAllCalendars:(id)sender {
	BOOL state = [watchAllCalendars state];

	if (state) {
		[PreferencesModel setPrefCalendarUIDs:nil];
	}
	else {
		NSArray *calendars = [calendarModel calendars];
		NSMutableArray *uids = [[[NSMutableArray alloc] init] autorelease];
		for (CalCalendar *cldr in calendars) {
			[uids addObject:[cldr uid]];
		}
		[PreferencesModel setPrefCalendarUIDs:uids];
	}

	[self updateCalendarList:!state];
}

- (IBAction)changeTitleLength:(id)sender {
	[PreferencesModel setPrefTitleLength:[titleLength intValue]];
}

@end
