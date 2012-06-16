//
//  oroloAppDelegate.h
//  orolo
//
//  Created by Bogdan Opanchuk on 29/05/12.
//  Copyright 2012 Bogdan Opanchuk. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
