//
//  PreferencesController.m
//  orolo
//
//  Created by Bogdan Opanchuk on 9/06/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PreferencesController.h"

static NSString * const keyFadeInColor = @"FadeInColor";
static NSString * const keyFadeOutColor = @"FadeOutColor";
static NSString * const keyFadeInInterval = @"FadeInInterval";
static NSString * const keyFadeOutInterval = @"FadeOutInterval";


@implementation PreferencesController

+ (void)addObserver:(id)target selector:(SEL)selector {
	NSNotificationCenter *ncenter = [NSNotificationCenter defaultCenter];
	[ncenter addObserver:target
				selector:selector
					name:NSUserDefaultsDidChangeNotification
				  object:nil];
}

+ (void)setDefaults {
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];

	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor redColor]]
					  forKey:keyFadeInColor];
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:[NSColor blueColor]]
					  forKey:keyFadeOutColor];

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
	//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	//return [defaults boolForKey:keyStartAtLogin];

	// check if self is in login items
	return NO;
}

+ (void)setPrefLaunchAtLogin:(BOOL)start {
//	[[NSUserDefaults standardUserDefaults] setBool:start forKey:keyStartAtLogin];

	// Add self to login items
}

+ (int)fadeInInterval {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults integerForKey:keyFadeInInterval];
}


- (id)init {
	self = [super initWithWindowNibName:@"Preferences"];
	return self;
}

- (void)windowDidLoad {
	[super windowDidLoad];
	[fadeInColorWell setColor:[PreferencesController prefFadeInColor]];
	[fadeOutColorWell setColor:[PreferencesController prefFadeOutColor]];
	[launchAtLogin setState:[PreferencesController prefLaunchAtLogin]];
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

@end
