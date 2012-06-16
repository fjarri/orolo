//
//  StatusItemView.h
//  orolo
//
//  Created by Bogdan Opanchuk on 10/06/12.
//  Copyright 2012 Bogdan Opanchuk. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface StatusItemView : NSView <NSMenuDelegate> {
	NSStatusItem *statusItem;
    NSString *title;
	NSImage *image;
	NSColor *color;
    BOOL isMenuVisible;
}

@property (retain, nonatomic) NSStatusItem *statusItem;

- (void)menuWillOpen:(NSMenu *)menu;
- (void)menuDidClose:(NSMenu *)menu;

- (NSColor *)titleForegroundColor;
- (NSDictionary *)titleAttributes;
- (NSRect)titleBoundingRect;
- (void)setImage:(NSImage *)newImage withTitle:(NSString *)newTitle withColor:(NSColor *)newColor;

@end
