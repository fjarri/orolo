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

static NSString * const keyFadeInColor = @"FadeInColor";
static NSString * const keyFadeOutColor = @"FadeOutColor";
static NSString * const keyFadeInInterval = @"FadeInInterval";
static NSString * const keyFadeOutInterval = @"FadeOutInterval";
static NSString * const keyCalendarUIDs = @"CalendarUIDs";
static NSString * const keyWatchAllCalendars = @"WatchAllCalendars";


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

	viewIsEnabled = NO;

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

- (void)setViewIsEnabled:(BOOL)enabled {
	viewIsEnabled = enabled;
	if (enabled) {
		[self update];
	}
}

- (void)update {
	NSArray *calendars = [calendarModel calendars];

	NSArray *watched_uids = [PreferencesController prefCalendarUIDs];

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
	if(viewIsEnabled) {
		return calendarTitles.count;
	}
	else {
		return 0;
	}
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
		[PreferencesController setPrefCalendarUIDs:watched_uids];
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

	NSArray *uids = [PreferencesController prefCalendarUIDs];
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
	[PreferencesController setPrefCalendarUIDs:result];
}

+ (void)addObserver:(id)target selector:(SEL)selector {
	NSNotificationCenter *ncenter = [NSNotificationCenter defaultCenter];
	[ncenter addObserver:target
				selector:selector
					name:NSUserDefaultsDidChangeNotification
				  object:nil];
}

+ (void)removeObserver:(id)target {
	NSNotificationCenter *ncenter = [NSNotificationCenter defaultCenter];
	[ncenter removeObserver:target
					   name:NSUserDefaultsDidChangeNotification
					 object:nil];
}

+ (void)setDefaults {
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];

	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor redColor]]
					  forKey:keyFadeInColor];
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor blueColor]]
					  forKey:keyFadeOutColor];
	[defaultValues setObject:[NSNumber numberWithInt:5] forKey:keyFadeInInterval];
	[defaultValues setObject:[NSNumber numberWithInt:3] forKey:keyFadeOutInterval];
	[defaultValues setObject:[[[NSArray alloc] init] autorelease] forKey:keyCalendarUIDs];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:keyWatchAllCalendars];

	[[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];
}

+ (NSColor *)prefFadeInColor {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *colorAsData = [defaults objectForKey:keyFadeInColor];
	return [NSKeyedUnarchiver unarchiveObjectWithData:colorAsData];
}

+ (void)setPrefFadeInColor:(NSColor *)color {
	NSData *colorAsData = [NSKeyedArchiver archivedDataWithRootObject:color];
	[[NSUserDefaults standardUserDefaults] setObject:colorAsData forKey:keyFadeInColor];
}

+ (NSColor *)prefFadeOutColor {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *colorAsData = [defaults objectForKey:keyFadeOutColor];
	return [NSKeyedUnarchiver unarchiveObjectWithData:colorAsData];
}

+ (void)setPrefFadeOutColor:(NSColor *)color {
	NSData *colorAsData = [NSKeyedArchiver archivedDataWithRootObject:color];
	[[NSUserDefaults standardUserDefaults] setObject:colorAsData forKey:keyFadeOutColor];
}

+ (BOOL)prefLaunchAtLogin {
	LoginItemsModel *loginItems = [[[LoginItemsModel alloc] init] autorelease];
	return [loginItems loginItemExists];
}

+ (void)setPrefLaunchAtLogin:(BOOL)launch {
	LoginItemsModel *loginItems = [[[LoginItemsModel alloc] init] autorelease];
	if (launch) {
		[loginItems enableLoginItem];
	}
	else {
		[loginItems disableLoginItem];
	}
}

+ (int)prefFadeInInterval {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults integerForKey:keyFadeInInterval];
}

+ (void)setPrefFadeInInterval:(int)interval {
	[[NSUserDefaults standardUserDefaults] setInteger:interval forKey:keyFadeInInterval];
}

+ (int)prefFadeOutInterval {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults integerForKey:keyFadeOutInterval];
}

+ (void)setPrefFadeOutInterval:(int)interval {
	[[NSUserDefaults standardUserDefaults] setInteger:interval forKey:keyFadeOutInterval];
}

+ (NSArray *)prefCalendarUIDs {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber *watchAllCalendars = [defaults objectForKey:keyWatchAllCalendars];
	if ([watchAllCalendars boolValue]) {
		return nil;
	}
	else {
		return [defaults objectForKey:keyCalendarUIDs];
	}
}

+ (void)setPrefCalendarUIDs:(NSArray *)uids {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (uids) {
		[defaults setObject:uids forKey:keyCalendarUIDs];
		[defaults setObject:[NSNumber numberWithBool:NO] forKey:keyWatchAllCalendars];
	}
	else {
		[defaults setObject:[[[NSArray alloc] init] autorelease] forKey:keyCalendarUIDs];
		[defaults setObject:[NSNumber numberWithBool:YES] forKey:keyWatchAllCalendars];
	}
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
	[calendarList setDataSource:calendarListSource];
	[calendarList reloadData];
}

- (void)windowDidLoad {
	[super windowDidLoad];

	[fadeInColorWell setColor:[PreferencesController prefFadeInColor]];
	[fadeOutColorWell setColor:[PreferencesController prefFadeOutColor]];
	[launchAtLogin setState:[PreferencesController prefLaunchAtLogin]];

	int fade_in = [PreferencesController prefFadeInInterval];
	int fade_out = [PreferencesController prefFadeOutInterval];
	[fadeInInterval setIntValue:fade_in];
	if (fade_out == 0) {
		[fadeOutEnabled setState:NO];
	}
	else {
		[fadeOutEnabled setState:YES];
		[fadeOutInterval setIntValue:fade_out];
	}
	[self changeFadeOutEnabled:nil];

	BOOL watching_all = ![PreferencesController prefCalendarUIDs];
	[watchAllCalendars setState:watching_all];
	[calendarListSource setViewIsEnabled:!watching_all];
	[calendarList setEnabled:!watching_all];
	[calendarList reloadData];
}

- (void)calendarsUpdated:(NSNotification *)aNotification {
	[calendarListSource update];
	[calendarList reloadData];
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
	[PreferencesController setPrefFadeInColor:[fadeInColorWell color]];
}

- (IBAction)changeFadeOutColor:(id)sender {
	[PreferencesController setPrefFadeOutColor:[fadeOutColorWell color]];
}

- (IBAction)changeLaunchAtLogin:(id)sender {
	[PreferencesController setPrefLaunchAtLogin:[launchAtLogin state]];
}

- (IBAction)changeFadeInInterval:(id)sender {
	[PreferencesController setPrefFadeInInterval:[fadeInInterval intValue]];
}

- (IBAction)changeFadeOutInterval:(id)sender {
	[PreferencesController setPrefFadeOutInterval:[fadeOutInterval intValue]];
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
		[PreferencesController setPrefFadeOutInterval:0];
	}
}

- (IBAction)changeWatchAllCalendars:(id)sender {
	BOOL state = [watchAllCalendars state];
	[calendarListSource setViewIsEnabled:!state];
	[calendarList setEnabled:!state];
	[calendarList reloadData];

	if (state) {
		[PreferencesController setPrefCalendarUIDs:nil];
	}
	else {
		NSArray *calendars = [calendarModel calendars];
		NSMutableArray *uids = [[[NSMutableArray alloc] init] autorelease];
		for (CalCalendar *cldr in calendars) {
			[uids addObject:[cldr uid]];
		}
		[PreferencesController setPrefCalendarUIDs:uids];
	}
}

@end
