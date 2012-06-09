//
//  CalendarModel.m
//  orolo
//
//  Created by Bogdan Opanchuk on 30/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CalendarModel.h"
#import <CalendarStore/CalendarStore.h>


@implementation CalendarModel

+ (void)addCalendarsObserver:(id)target selector:(SEL)selector {
	NSNotificationCenter *ncenter = [NSNotificationCenter defaultCenter];
	[ncenter addObserver:target
				selector:selector
					name:CalCalendarsChangedExternallyNotification
				  object:nil];
}

+ (void)addEventsObserver:(id)target selector:(SEL)selector {
	NSNotificationCenter *ncenter = [NSNotificationCenter defaultCenter];
	[ncenter addObserver:target
				selector:selector
					name:CalEventsChangedExternallyNotification
				  object:nil];
}

- (id)init {
	self = [super init];

	// TODO: may need non-defaults here
	cstore = [[CalCalendarStore defaultCalendarStore] retain];

	return self;
}

- (void)dealloc
{
	[cstore release];
	[super dealloc];
}

- (CalEvent *)closestEvent {

	NSArray *cldrs = [cstore calendars];

	NSTimeInterval window = 60 * 60; // FIXME: remove hardcoding
	NSDate *now = [NSDate date];
	NSDate *border = [now dateByAddingTimeInterval:window];

	NSPredicate *allEventsPredicate = [CalCalendarStore eventPredicateWithStartDate:now
																			endDate:border
																		  calendars:cldrs];
	NSArray *events = [cstore eventsWithPredicate:allEventsPredicate];

	CalEvent *closest_start = nil;
	CalEvent *closest_end = nil;

	for(CalEvent *event in events) {
		NSDate *start = [event startDate];
		NSDate *end = [event endDate];

		if ([now compare:start] == NSOrderedAscending) {
			if (closest_start == nil || [[closest_start startDate] compare:start] == NSOrderedDescending) {
				closest_start = event;
			}
		}
		if ([border compare:end] == NSOrderedDescending) {
			if (closest_end == nil || [[closest_end endDate] compare:end] == NSOrderedDescending) {
				closest_end = event;
			}
		}
	}

	if (closest_start == nil && closest_end == nil) {
		return nil;
	}
	else if (closest_end == nil) {
		return closest_start;
	}
	else if (closest_start == nil) {
		return closest_end;
	}
	else if ([[closest_start startDate] compare:[closest_end endDate]] == NSOrderedAscending) {
		return closest_start;
	}
	else {
		return closest_end;
	}
}

@end
