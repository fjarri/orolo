//
//  PreferencesModel.m
//  orolo
//
//  Created by Bogdan Opanchuk on 15/06/12.
//  Copyright 2012 Bogdan Opanchuk. All rights reserved.
//

#import "PreferencesModel.h"
#import "LoginItemsModel.h"

static NSString * const keyFadeInColor = @"FadeInColor";
static NSString * const keyFadeOutColor = @"FadeOutColor";
static NSString * const keyFadeInInterval = @"FadeInInterval";
static NSString * const keyFadeOutInterval = @"FadeOutInterval";
static NSString * const keyCalendarUIDs = @"CalendarUIDs";
static NSString * const keyWatchAllCalendars = @"WatchAllCalendars";
static NSString * const keyTitleLength = @"TitleLength";


@implementation PreferencesModel

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
	[defaultValues setObject:[NSNumber numberWithInt:10] forKey:keyTitleLength];

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

+ (int)prefTitleLength {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults integerForKey:keyTitleLength];
}

+ (void)setPrefTitleLength:(int)length {
	[[NSUserDefaults standardUserDefaults] setInteger:length forKey:keyTitleLength];
}

@end
