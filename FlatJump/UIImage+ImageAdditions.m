//
//  UIImage+ImageAdditions.m
//  FlatJump
//
//  Created by Evan Ische on 4/17/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "UIColor+FlatColors.h"
#import "UIImage+ImageAdditions.h"

@implementation UIImage (ImageAdditions)

+ (UIImage *)backgroundImage {
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    UIGraphicsBeginImageContextWithOptions(bounds.size, YES, 0);
    
    //
    UIColor *stripeColor = [UIColor flatSTAccentColor];
    UIColor *backgroundColor = [UIColor flatSTBackgroundColor];
    
    //
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    //
    NSArray *gradientColors = @[(id)stripeColor.CGColor,
                                (id)backgroundColor.CGColor];
    
    //
    CGFloat gradientLocations[] = { 0.0f, 0.925f };
    
    //
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocations);
    
    UIBezierPath *background = [UIBezierPath bezierPathWithRect:bounds];
    [backgroundColor setFill];
    [background fill];
    
    const NSUInteger numberOfColumns = 5;
    const CGFloat columnWidth = [HDHelper universalColumnWidth];
    
    const CGFloat startXPosition = CGRectGetMidX(bounds) - (numberOfColumns/2.0f * columnWidth);
    for (NSUInteger column = 0; column < numberOfColumns; column++) {
        
        CGRect stripeFrame = CGRectMake(startXPosition + (columnWidth * column), 0.0f, columnWidth, CGRectGetHeight(bounds));
        if ((column % 2 == 0)) {
            UIBezierPath *stripe = [UIBezierPath bezierPathWithRect:stripeFrame];
            [backgroundColor setFill];
            [stripe fill];
        } else {
            UIBezierPath *stripe = [UIBezierPath bezierPathWithRect:stripeFrame];
            CGContextSaveGState(UIGraphicsGetCurrentContext());
            [stripe addClip];
            CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(),
                                        gradient,
                                        CGPointMake(CGRectGetMidX(bounds), 0),
                                        CGPointMake(CGRectGetMidX(bounds), CGRectGetHeight(bounds)), 0);
            CGContextRestoreGState(UIGraphicsGetCurrentContext());
        }
    }
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    
    UIImage *wallPaper = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return wallPaper;
}

+ (UIImage *)playerWithSize:(CGSize)size {
    
    NSLog(@"SIZE %@",NSStringFromCGSize(size));
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);

    const CGFloat layerOffset = roundf(size.width/7);
    
    [[UIColor flatSilverColor] setFill];
    UIRectFill(CGRectMake(0.0f, layerOffset, size.width, size.height - layerOffset));
    
    [[UIColor whiteColor] setFill];
    UIRectFill(CGRectMake(0.0f, 0.0f, size.width, size.height - layerOffset));
    
    UIImage *player = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return player;
}

+ (UIImage *)shadowedBarrier:(CGSize)size {
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    UIColor *barrierColor = [UIColor flatSTEmeraldColor];
    UIColor *shadowColor  = [UIColor colorWithRed:(74/255.0f) green:(118/255.0f) blue:(70/255.0f) alpha:1];
    
    const CGFloat barrierOffset = roundf([HDHelper universalBarrierWidth]/4.25f);
    NSLog(@"%f",barrierOffset);
    
    [shadowColor setFill];
    UIRectFill(CGRectMake(0.0f, barrierOffset, size.width, size.height - barrierOffset));
    
    [barrierColor setFill];
    UIRectFill(CGRectMake(0.0f, 0.0f, size.width, size.height - barrierOffset));

    UIImage *barrier = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return barrier;
}


@end
