//
//  PreferencesController.m
//  orolo
//
//  Created by Bogdan Opanchuk on 9/06/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PreferencesController.h"

@implementation PreferencesController

- (id)init {
	self = [super initWithWindowNibName:@"Preferences"];
	return self;
}

- (void)windowDidLoad {
	[super windowDidLoad];
	// initialization here
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
	//NSColor *color = [fadeInColorWell color];
}

- (IBAction)changeFadeOutColor:(id)sender {
	//NSColor *color = [fadeOutColorWell color];
}

- (IBAction)changeLaunchAtStartup:(id)sender {

}

@end
