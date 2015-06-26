//
//  MenuletController.h
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


typedef enum {
	MenuletModeEvents, // showing events
	MenuletModeTime // showing current time
} MenuletMode;

typedef enum {
	MenuletStateMode, // normal state, showing things for current mode
	MenuletStateTimeBriefly, // briefly showing current time
	MenuletStateTimeRemaining // briefly showing time remaining till the closest event
} MenuletState;


@interface MenuletController : NSObject {
	PreferencesController *preferencesController;
	AboutController *aboutController;

	NSStatusItem *menulet;
	StatusItemView *statusItemView;

	MenuletMode menuletMode;
	MenuletState menuletState;

	IBOutlet NSMenu *theMenu;
	IBOutlet NSMenuItem *menuFullTitle;
	IBOutlet NSMenuItem *menuShowRealTime;
	IBOutlet NSMenuItem *menuConstantlyShowRealTime;
	IBOutlet NSMenuItem *menuShowTimeTillNextEvent;
	IBOutlet NSMenuItem	*menuPreferences;
	IBOutlet NSMenuItem *menuAbout;
	IBOutlet NSMenuItem *menuQuit;

	NSTimer *briefStatusTimer;
	NSTimer *constantUpdateTimer;

	CalendarModel *calendarModel;
	JFHotkeyManager *hkm;

	NSDateFormatter *dateFormatter;
}

- (void)setTimerForMode;

- (void)setNoEventsStatus;
- (void)setTextStatus:(NSString *)title withColor:(NSColor *)color;

- (void)updateStatus;

- (IBAction)actionPreferences:(id)sender;
- (IBAction)actionAbout:(id)sender;
- (IBAction)actionQuit:(id)sender;

- (void)restoreStateToMode:(NSTimer*)theTimer;
- (IBAction)actionShowRealTime:(id)sender;
- (IBAction)actionConstantlyShowRealTime:(id)sender;
- (IBAction)actionShowTimeTillNextEvent:(id)sender;

@end
