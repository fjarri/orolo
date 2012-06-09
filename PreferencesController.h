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

	IBOutlet NSButton *launchAtStartup;
}

- (IBAction)changeFadeInColor:(id)sender;
- (IBAction)changeFadeOutColor:(id)sender;
- (IBAction)changeLaunchAtStartup:(id)sender;

@end
