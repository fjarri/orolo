//
//  CalendarModel.h
//  orolo
//
//  Created by Bogdan Opanchuk on 30/05/12.
//  Copyright 2012 Bogdan Opanchuk. All rights reserved.
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
	NSTimeInterval distance; // time in seconds till the event
}

@property (readonly) CalEvent *event;
@property (readonly) BOOL isForward;
@property (readonly) BOOL isBeginning;
@property (readonly) float fraction;
@property (readonly) NSTimeInterval distance;

- (CalResult *)initWithEvent:(CalEvent *)ev forward:(BOOL)forward beginning:(BOOL)beginning
	fraction:(float)frac distance:(NSTimeInterval)dist;

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
- (CalResult *)closestFutureEvent;
- (CalResult *)closestEvent;
- (CalResult *)closestEventInRange:(int)range fadeIn:(BOOL)fadeIn calendars:(NSArray *)cldrs;

@end
