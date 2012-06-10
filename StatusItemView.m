//
//  StatusItemView.m
//  orolo
//
//  Created by Bogdan Opanchuk on 10/06/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "StatusItemView.h"

#define StatusItemViewTitlePaddingWidth  6
#define StatusItemViewImagePaddingWidth  2
#define StatusItemViewPaddingHeight 3


@implementation StatusItemView

@synthesize statusItem;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        statusItem = nil;
		image = nil;
        title = nil;
		color = nil;
        isMenuVisible = NO;
    }
    return self;
}

- (void)dealloc {
    [statusItem release];
    [title release];
	[image release];
	[color release];
    [super dealloc];
}

- (void)mouseDown:(NSEvent *)event {
    [[self menu] setDelegate:self];
    [statusItem popUpStatusItemMenu:[self menu]];
    [self setNeedsDisplay:YES];
}

- (void)rightMouseDown:(NSEvent *)event {
    // Treat right-click just like left-click
    [self mouseDown:event];
}

- (void)menuWillOpen:(NSMenu *)menu {
    isMenuVisible = YES;
    [self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
    isMenuVisible = NO;
    [menu setDelegate:nil];
    [self setNeedsDisplay:YES];
}

- (NSColor *)titleForegroundColor {
    if (isMenuVisible) {
        return [NSColor whiteColor];
    }
    else {
        return color;
    }
}

- (NSDictionary *)titleAttributes {
    // Use default menu bar font size
    NSFont *font = [NSFont menuBarFontOfSize:0];

    NSColor *foregroundColor = [self titleForegroundColor];

    return [NSDictionary dictionaryWithObjectsAndKeys:
            font,            NSFontAttributeName,
            foregroundColor, NSForegroundColorAttributeName,
            nil];
}

- (NSRect)titleBoundingRect {
    return [title boundingRectWithSize:NSMakeSize(1e100, 1e100)
                               options:0
                            attributes:[self titleAttributes]];
}

- (void)setImage:(NSImage *)newImage withTitle:(NSString *)newTitle withColor:(NSColor *)newColor {
    if (![title isEqual:newTitle] || ![image isEqual:newImage]) {
        [newTitle retain];
        [title release];
        title = newTitle;

		[newImage retain];
		[image release];
		image = newImage;

        // Update status item size (which will also update this view's bounds)
        int newWidth;
		NSRect titleBounds = [self titleBoundingRect];
		if (newTitle && newImage) {
			newWidth = image.size.width + titleBounds.size.width +
				2 * StatusItemViewTitlePaddingWidth + StatusItemViewImagePaddingWidth;
		}
		else if (newTitle) {
			newWidth = titleBounds.size.width + 2 * StatusItemViewTitlePaddingWidth;
		}
		else if (newImage) {
			newWidth = image.size.width + 2 * StatusItemViewImagePaddingWidth;
		}
		else {
			newWidth = StatusItemViewTitlePaddingWidth;
		}

        [statusItem setLength:newWidth];

        [self setNeedsDisplay:YES];
    }

	if(![color isEqual:newColor]) {
        [newColor retain];
        [color release];
        color = newColor;

		[self setNeedsDisplay:YES];
	}
}


- (void)drawRect:(NSRect)dirtyRect {
    // Draw status bar background, highlighted if menu is showing
    [statusItem drawStatusBarBackgroundInRect:[self bounds]
                                withHighlight:isMenuVisible];

    // Draw image and title string
	int titleShift = image ? StatusItemViewImagePaddingWidth + image.size.width : 0;
    NSPoint imageOrigin = NSMakePoint(StatusItemViewImagePaddingWidth, 0);
	NSPoint titleOrigin = NSMakePoint(StatusItemViewTitlePaddingWidth + titleShift,
									  StatusItemViewPaddingHeight);

	if(image) {
		[image drawAtPoint:imageOrigin
				  fromRect:NSZeroRect
				 operation:NSCompositeSourceOver
				  fraction:1.0];
	}
	if(title) {
		CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
		CGSize size = CGSizeMake(0, -1);
		CGFloat components[] = {1.0, 1.0, 1.0, 0.3};
		CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
		CGColorRef cref = CGColorCreate(cs, components);

		CGContextSaveGState(context);

		CGContextSetShadowWithColor(context, size, 1.0, cref);
		CGColorSpaceRelease(cs);
		CGColorRelease(cref);
		[title drawAtPoint:titleOrigin
			withAttributes:[self titleAttributes]];

		CGContextRestoreGState(context);
	}
}

@end
