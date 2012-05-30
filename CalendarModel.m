//
//  CalendarModel.m
//  orolo
//
//  Created by Bogdan Opanchuk on 30/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CalendarModel.h"


@implementation CalendarModel

- (NSArray *)calendars {
	return [[CalCalendarStore defaultCalendarStore] calendars];
}

- (NSArray *)events {
	CalCalendarStore *store = [CalCalendarStore defaultCalendarStore];
    // Pull all events starting now from all calendars in the CalendarStore
	NSPredicate *allEventsPredicate = [CalCalendarStore eventPredicateWithStartDate:[NSDate date]
																			endDate:[NSDate distantFuture]
																		  calendars:[store calendars]];
	return [store eventsWithPredicate:allEventsPredicate];
}

- (NSArray *)tasks {
	CalCalendarStore *store = [CalCalendarStore defaultCalendarStore];
    // Pull all uncompleted tasks from all calendars in the CalendarStore
	return [store tasksWithPredicate:[CalCalendarStore taskPredicateWithUncompletedTasks:[store calendars]]];
}

- (CalEvent *)closest_event {
	CalCalendarStore *store = [CalCalendarStore defaultCalendarStore];
    // Pull all events starting now from all calendars in the CalendarStore
	NSPredicate *allEventsPredicate = [CalCalendarStore eventPredicateWithStartDate:[NSDate date]
																			endDate:[NSDate distantFuture]
																		  calendars:[store calendars]];
	NSArray *events = [store eventsWithPredicate:allEventsPredicate];
	return [events objectAtIndex:0];
}

@end
