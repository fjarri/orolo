//
//  CalendarModel.m
//  orolo
//
//  Created by Bogdan Opanchuk on 30/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <CalendarStore/CalendarStore.h>
#import "CalendarModel.h"
#import "PreferencesController.h"


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

- (CalResult *)closestEvent {
	int fadeInInterval = [PreferencesController prefFadeInInterval] * 60;
	int fadeOutInterval = [PreferencesController prefFadeOutInterval] * 60;

	CalResult *fwResult = [self closestEventInRange:fadeInInterval fadeIn:YES];
	if (fwResult || fadeOutInterval == 0) {
		return fwResult;
	}

	return [self closestEventInRange:fadeOutInterval fadeIn:NO];
}

- (CalResult *)closestEventInRange:(int)range fadeIn:(BOOL)fadeIn {
	NSArray *cldrs = [cstore calendars];

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

		if (close_end_distance >= 0 && close_end_distance < best_distance) {
			best_event = event;
			best_beginning = fadeIn;
			best_distance = close_end_distance;
		}
		else if (far_end_distance >= 0 && far_end_distance < best_distance) {
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
