//
//  CalendarModel.m
//  orolo
//
//  Created by Bogdan Opanchuk on 30/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CalendarModel.h"


@implementation CalendarModel

- (id) initWithTarget:(id)target selector:(SEL)selector {
	self = [super init];

	// TODO: may need non-defaults here
	cstore = [[CalCalendarStore defaultCalendarStore] retain];
	ncenter = [[NSNotificationCenter defaultCenter] retain];

	[ncenter addObserver:target
				selector:selector
					name:CalCalendarsChangedExternallyNotification
				  object:nil];
    [ncenter addObserver:target
				selector:selector
					name:CalEventsChangedExternallyNotification
				  object:nil];

	return self;
}

- (void)dealloc
{
    [ncenter release];
	[cstore release];
	[super dealloc];
}

- (CalEvent *)closest_event {
	NSArray *cldrs = [cstore calendars];
	NSPredicate *allEventsPredicate = [CalCalendarStore eventPredicateWithStartDate:[NSDate date]
																			endDate:[NSDate distantFuture]
																		  calendars:cldrs];
	NSArray *events = [cstore eventsWithPredicate:allEventsPredicate];
	if ([events count] > 0) {
		return [events objectAtIndex:0];
	}
	else {
		return nil;
	}


}

@end
