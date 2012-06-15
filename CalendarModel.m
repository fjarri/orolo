//
//  CalendarModel.m
//  orolo
//
//  Created by Bogdan Opanchuk on 30/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CalendarStore/CalendarStore.h>
#import "CalendarModel.h"
#import "PreferencesModel.h"

@implementation CalResult

@synthesize event;
@synthesize isForward;
@synthesize isBeginning;
@synthesize fraction;

- (CalResult *)initWithEvent:(CalEvent *)ev forward:(BOOL)forward beginning:(BOOL)beginning fraction:(float)frac {
	self = [super init];

	[ev retain];
	event = ev;
	isForward = forward;
	isBeginning = beginning;
	fraction = frac;

	return self;
}

- (void)dealloc {
	[event release];
	[super dealloc];
}

@end


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

+ (void)removeCalendarsObserver:(id)target {
	NSNotificationCenter *ncenter = [NSNotificationCenter defaultCenter];
	[ncenter removeObserver:target
					   name:CalCalendarsChangedExternallyNotification
					 object:nil];
}

+ (void)removeEventsObserver:(id)target {
	NSNotificationCenter *ncenter = [NSNotificationCenter defaultCenter];
	[ncenter removeObserver:target
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

- (NSArray *)calendars {
	return [cstore calendars];
}

- (NSArray *)watchedCalendars {
	NSArray *cldrs = [self calendars];
	NSArray *uids = [PreferencesModel prefCalendarUIDs];

	if (!uids) {
		return cldrs;
	}

	NSMutableArray *result = [[[NSMutableArray alloc] init] autorelease];
	for (CalCalendar *cldr in cldrs) {
		if ([uids containsObject:[cldr uid]]) {
			[result addObject:cldr];
		}
	}
	return result;
}

- (CalResult *)closestEvent {
	int fadeInInterval = [PreferencesModel prefFadeInInterval] * 60;
	int fadeOutInterval = [PreferencesModel prefFadeOutInterval] * 60;
	NSArray *cldrs = [self watchedCalendars];

	CalResult *fwResult = [self closestEventInRange:fadeInInterval fadeIn:YES calendars:cldrs];
	if (fwResult || fadeOutInterval == 0) {
		return fwResult;
	}

	return [self closestEventInRange:fadeOutInterval fadeIn:NO calendars:cldrs];
}

- (CalResult *)closestEventInRange:(int)range fadeIn:(BOOL)fadeIn calendars:(NSArray *)cldrs {

	float time_direction = fadeIn ? 1 : -1;
	NSDate *now = [NSDate date];
	NSDate *border = [now dateByAddingTimeInterval:range * time_direction];

	NSPredicate *allEventsPredicate = [CalCalendarStore eventPredicateWithStartDate:(fadeIn ? now : border)
																			endDate:(fadeIn ? border : now)
																		  calendars:cldrs];
	NSArray *events = [cstore eventsWithPredicate:allEventsPredicate];

	SEL closeDate = fadeIn ? @selector(startDate) : @selector(endDate);
	SEL farDate = fadeIn ? @selector(endDate) : @selector(startDate);

	CalEvent *best_event = nil;
	BOOL best_beginning = NO;
	float best_distance = 1e10; // hope that's big enough

	for(CalEvent *event in events) {
		NSDate *close_end = [event performSelector:closeDate];
		NSDate *far_end = [event performSelector:farDate];

		float close_end_distance = [close_end timeIntervalSinceNow] * time_direction;
		float far_end_distance = [far_end timeIntervalSinceNow] * time_direction;

		if (close_end_distance >= 0 && close_end_distance < best_distance && close_end_distance <= range) {
			best_event = event;
			best_beginning = fadeIn;
			best_distance = close_end_distance;
		}
		else if (far_end_distance >= 0 && far_end_distance < best_distance && far_end_distance <= range) {
			best_event = event;
			best_beginning = !fadeIn;
			best_distance = far_end_distance;
		}
	}

	if (best_event) {
		return [[[CalResult alloc] initWithEvent:best_event
										 forward:fadeIn
									   beginning:best_beginning
										fraction:best_distance / range] autorelease];
	}
	else {
		return nil;
	}
}

@end
