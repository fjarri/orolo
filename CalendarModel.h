//
//  CalendarModel.h
//  orolo
//
//  Created by Bogdan Opanchuk on 30/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CalCalendarStore;
@class CalEvent;

@interface CalResult : NSObject
{
	CalEvent *event; // event itself
	BOOL isForward; // YES if it is event in the future
	BOOL isBeginning; // YES if we caught a beginning of the event
	float fraction; // time from event till now divided by the time interval
}

@property (readonly) CalEvent *event;
@property (readonly) BOOL isForward;
@property (readonly) BOOL isBeginning;
@property (readonly) float fraction;

- (CalResult *)initWithEvent:(CalEvent *)ev forward:(BOOL)forward beginning:(BOOL)beginning fraction:(float)frac;

@end



@interface CalendarModel : NSObject {
	CalCalendarStore *cstore;
}

+ (void)addCalendarsObserver:(id)target selector:(SEL)selector;
+ (void)addEventsObserver:(id)target selector:(SEL)selector;
+ (void)removeCalendarsObserver:(id)target;
+ (void)removeEventsObserver:(id)target;

- (id) init;
- (NSArray *)calendars;
- (NSArray *)watchedCalendars;
- (CalResult *)closestEvent;
- (CalResult *)closestEventInRange:(int)range fadeIn:(BOOL)fadeIn calendars:(NSArray *)cldrs;

@end
