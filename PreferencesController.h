//
//  PreferencesController.h
//  orolo
//
//  Created by Bogdan Opanchuk on 9/06/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CalendarModel;

@interface IntegerForcingDelegate : NSObject <NSTextFieldDelegate> {

}

- (void)controlTextDidChange:(NSNotification *)aNotification;

@end

@interface CalendarListSource : NSObject <NSTableViewDataSource> {
	CalendarModel *calendarModel;
	NSMutableArray *calendarUIDs;
	NSMutableArray *calendarTitles;
	NSMutableArray *watchedList;
	BOOL viewIsEnabled;
}

- (void)setViewIsEnabled:(BOOL)enabled;

- (void)update;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;

@end



@interface PreferencesController : NSWindowController {

	IntegerForcingDelegate *ifDelegate;
	CalendarListSource *calendarListSource;
	CalendarModel *calendarModel;

	IBOutlet NSColorWell *fadeInColorWell;
	IBOutlet NSColorWell *fadeOutColorWell;

	IBOutlet NSButton *launchAtLogin;

	IBOutlet NSTextField *fadeInInterval;
	IBOutlet NSTextField *fadeOutInterval;
	IBOutlet NSButton *fadeOutEnabled;

	IBOutlet NSTableView *calendarList;
	IBOutlet NSButton *watchAllCalendars;
	IBOutlet NSTextField *titleLength;
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
+ (NSArray *)prefCalendarUIDs;
+ (void)setPrefCalendarUIDs:(NSArray *)uids;
+ (int)prefTitleLength;
+ (void)setPrefTitleLength:(int)length;


- (void)calendarsUpdated:(NSNotification *)notification;

- (IBAction)changeFadeInColor:(id)sender;
- (IBAction)changeFadeOutColor:(id)sender;
- (IBAction)changeLaunchAtLogin:(id)sender;
- (IBAction)changeFadeInInterval:(id)sender;
- (IBAction)changeFadeOutInterval:(id)sender;
- (IBAction)changeFadeOutEnabled:(id)sender;
- (IBAction)changeWatchAllCalendars:(id)sender;
- (IBAction)changeTitleLength:(id)sender;

@end
