//
//  PreferencesModel.h
//  orolo
//
//  Created by Bogdan Opanchuk on 15/06/12.
//  Copyright 2012 Bogdan Opanchuk. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PreferencesModel : NSObject {

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

@end
