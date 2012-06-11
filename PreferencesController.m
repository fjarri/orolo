//
//  PreferencesController.m
//  orolo
//
//  Created by Bogdan Opanchuk on 9/06/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PreferencesController.h"
#import "LoginItemsModel.h"

static NSString * const keyFadeInColor = @"FadeInColor";
static NSString * const keyFadeOutColor = @"FadeOutColor";
static NSString * const keyFadeInInterval = @"FadeInInterval";
static NSString * const keyFadeOutInterval = @"FadeOutInterval";


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
	[defaultValues setObject:[NSNumber numberWithInt:60] forKey:keyFadeInInterval];
	[defaultValues setObject:[NSNumber numberWithInt:30] forKey:keyFadeOutInterval];

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

- (id)init {
	self = [super initWithWindowNibName:@"Preferences"];
	ifDelegate = [[IntegerForcingDelegate alloc] init];
	return self;
}

- (void)dealloc {
	[ifDelegate dealloc];
	[super dealloc];
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

	[fadeInInterval setDelegate:ifDelegate];
	[fadeOutInterval setDelegate:ifDelegate];
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
	if ([fadeOutEnabled state]) {
		[fadeOutInterval setEnabled:YES];
		[fadeOutColorWell setEnabled:YES];
		[fadeOutInterval setIntValue:1];
		[self changeFadeOutInterval:sender];
	}
	else {
		[fadeOutInterval setEnabled:NO];
		[fadeOutColorWell setEnabled:NO];
		[fadeOutInterval setStringValue:@""];
		[PreferencesController setPrefFadeOutInterval:0];
	}
}

@end
