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
//	NSMenuItem *ipMenuItem;

	NSTimer *updateTimer;
	CalendarModel *calendarModel;
}

- (void)calendarsChanged:(NSNotification *)notification;
- (IBAction)timerUpdated:(id)sender;
- (void)updateTime;

@end
