//
//  PreferencesController.h
//  orolo
//
//  Created by Bogdan Opanchuk on 9/06/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IntegerForcingDelegate : NSObject <NSTextFieldDelegate> {

}

- (void)controlTextDidChange:(NSNotification *)aNotification;

@end


@interface PreferencesController : NSWindowController {

	IntegerForcingDelegate *ifDelegate;

	IBOutlet NSColorWell *fadeInColorWell;
	IBOutlet NSColorWell *fadeOutColorWell;

	IBOutlet NSButton *launchAtLogin;

	IBOutlet NSTextField *fadeInInterval;
	IBOutlet NSTextField *fadeOutInterval;
	IBOutlet NSButton *fadeOutEnabled;
}

+ (void)addObserver:(id)target selector:(SEL)selector;
+ (void)removeObserver:(id)target;

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
- (IBAction)changeFadeInInterval:(id)sender;
- (IBAction)changeFadeOutInterval:(id)sender;
- (IBAction)changeFadeOutEnabled:(id)sender;

@end
