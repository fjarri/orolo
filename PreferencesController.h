//
//  PreferencesController.h
//  orolo
//
//  Created by Bogdan Opanchuk on 9/06/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSWindowController {
	IBOutlet NSColorWell *fadeInColorWell;
	IBOutlet NSColorWell *fadeOutColorWell;

	IBOutlet NSButton *launchAtLogin;

	IBOutlet NSTextField *fadeInInterval;
	IBOutlet NSTextField *fadeOutInterval;
}

+ (void)addObserver:(id)target selector:(SEL)selector;
+ (void)setDefaults;
+ (NSColor *)prefFadeInColor;
+ (void)setPrefFadeInColor:(NSColor *)color;
+ (NSColor *)prefFadeOutColor;
+ (void)setPrefFadeOutColor:(NSColor *)color;
+ (BOOL)prefLaunchAtLogin;
+ (void)setPrefLaunchAtLogin:(BOOL)launch;
+ (int)prefFadeInInterval;
+ (void)setPrefFadeInInterval:(int)interval;
+ (int)prefFadeOutInterval;
+ (void)setPrefFadeOutInterval:(int)interval;

- (IBAction)changeFadeInColor:(id)sender;
- (IBAction)changeFadeOutColor:(id)sender;
- (IBAction)changeLaunchAtLogin:(id)sender;

@end
