//
//  CalendarModel.h
//  orolo
//
//  Created by Bogdan Opanchuk on 30/05/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CalendarStore/CalendarStore.h>


@interface CalendarModel : NSObject {
	CalCalendarStore *cstore;
}

+ (void)addCalendarsObserver:(id)target selector:(SEL)selector;
+ (void)addEventsObserver:(id)target selector:(SEL)selector;

- (id) init;
- (CalEvent *)closestEvent;

@end
