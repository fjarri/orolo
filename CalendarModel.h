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

}

@property(readonly) NSArray *calendars;
@property(readonly) NSArray *events;
@property(readonly) NSArray *tasks;
@property(readonly) CalEvent *closest_event;

//- (void)calendarsChanged:(NSNotification *)notification;
//- (void)eventsChanged:(NSNotification *)notification;
//- (void)tasksChanged:(NSNotification *)notification;


@end
