//
//  oroloMenulet.h
//  orolo
//
//  Created by Bogdan Opanchuk on 30/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CalendarModel.h"

@interface OroloMenulet : NSObject {
	NSStatusItem *statusItem;

	IBOutlet NSMenu *theMenu;
	IBOutlet NSMenuItem *menuFullTitle;
	IBOutlet NSMenuItem *menuShowTime;
	IBOutlet NSMenuItem	*menuPreferences;
	IBOutlet NSMenuItem *menuQuit;

	NSTimer *updateTimer;
	CalendarModel *calendarModel;
}

- (void)calendarsChanged:(NSNotification *)notification;
- (IBAction)timerUpdated:(id)sender;
- (void)updateTime;

- (IBAction)actionQuit:(id)sender;

@end
