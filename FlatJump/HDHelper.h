//
//  HDHelper.h
//  FlatJump
//
//  Created by Evan Ische on 4/16/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import UIKit;
#import <Foundation/Foundation.h>

#define IS_IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#define TRANSFORM_SCALE_X [UIScreen mainScreen].bounds.size.width  / 375.0f
#define TRANSFORM_SCALE_Y [UIScreen mainScreen].bounds.size.height / 667.0f

extern const CGFloat ipadBoundsInset;
@interface HDHelper : NSObject
+ (CGFloat)universalBarrierWidth;
+ (CGFloat)universalRowHeight;
+ (CGFloat)universalColumnWidth;
+ (CGFloat)verticalBarrierHeight;
+ (CGFloat)verticalBarrierWidth;
+ (CGSize)verticalBarrierSize;
@end
