//
//  oroloMenulet.h
//  orolo
//
//  Created by Bogdan Opanchuk on 30/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CalendarModel.h"

@class PreferencesController;
@class AboutController;
@class CalendarModel;
@class JFHotkeyManager;
@class CalEvent;
@class StatusItemView;

@interface MenuletController : NSObject {
	PreferencesController *preferencesController;
	AboutController *aboutController;

	NSStatusItem *statusItem;
	StatusItemView *statusItemView;

	IBOutlet NSMenu *theMenu;
	IBOutlet NSMenuItem *menuFullTitle;
	IBOutlet NSMenuItem *menuShowRealTime;
	IBOutlet NSMenuItem	*menuPreferences;
	IBOutlet NSMenuItem *menuAbout;
	IBOutlet NSMenuItem *menuQuit;

	NSTimer *colorUpdateTimer;
	NSTimer *realTimeTimer;
	CalendarModel *calendarModel;
	JFHotkeyManager *hkm;

	NSDateFormatter *dateFormatter;

	Boolean showingRealTime;
	NSImage *statusIcon;
}

- (void)setNoEventsStatus;
- (void)setTextStatus:(NSString *)title withColor:(NSColor *)color;

- (void)preferencesChanged:(NSNotification *)notification;
- (void)calendarsChanged:(NSNotification *)notification;
- (void)updateColor:(NSTimer*)theTimer;
- (void)updateStatus;

- (IBAction)actionPreferences:(id)sender;
- (IBAction)actionAbout:(id)sender;
- (IBAction)actionQuit:(id)sender;

- (void)stopShowingRealTime:(NSTimer*)theTimer;
- (IBAction)actionShowRealTime:(id)sender;

@end
