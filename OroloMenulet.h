//
//  oroloMenulet.h
//  orolo
//
//  Created by Bogdan Opanchuk on 30/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CalendarModel.h"
#import "JFHotkeyManager.h"


@interface OroloMenulet : NSObject {
	NSStatusItem *statusItem;

	IBOutlet NSMenu *theMenu;
	IBOutlet NSMenuItem *menuFullTitle;
	IBOutlet NSMenuItem *menuShowRealTime;
	IBOutlet NSMenuItem	*menuPreferences;
	IBOutlet NSMenuItem *menuQuit;

	NSTimer *updateTimer;
	CalendarModel *calendarModel;
	JFHotkeyManager *hkm;
}

- (void)calendarsChanged:(NSNotification *)notification;
- (IBAction)timerUpdated:(id)sender;
- (void)updateTime;

- (IBAction)actionQuit:(id)sender;
- (IBAction)actionShowRealTime:(id)sender;

@end
