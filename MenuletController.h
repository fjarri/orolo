//
//  oroloMenulet.h
//  orolo
//
//  Created by Bogdan Opanchuk on 30/05/12.
//  Copyright 2012 Bogdan Opanchuk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CalendarModel.h"

@class PreferencesController;
@class AboutController;
@class CalendarModel;
@class JFHotkeyManager;
@class CalEvent;
@class StatusItemView;
@class RightmostMenulet;

@interface MenuletController : NSObject {
	PreferencesController *preferencesController;
	AboutController *aboutController;

	RightmostMenulet *menulet;
	StatusItemView *statusItemView;

	IBOutlet NSMenu *theMenu;
	IBOutlet NSMenuItem *menuFullTitle;
	IBOutlet NSMenuItem *menuShowRealTime;
	IBOutlet NSMenuItem *menuConstantlyShowRealTime;
	IBOutlet NSMenuItem *menuShowTimeTillNextEvent;
	IBOutlet NSMenuItem	*menuPreferences;
	IBOutlet NSMenuItem *menuAbout;
	IBOutlet NSMenuItem *menuQuit;

	NSTimer *colorUpdateTimer;
	NSTimer *realTimeTimer;
	CalendarModel *calendarModel;
	JFHotkeyManager *hkm;

	NSDateFormatter *dateFormatter;

	Boolean showingRealTime;
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
- (IBAction)actionConstantlyShowRealTime:(id)sender;
- (IBAction)actionShowTimeTillNextEvent:(id)sender;

@end
