//
//  HDHelper.m
//  FlatJump
//
//  Created by Evan Ische on 4/16/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"

const CGFloat iphoneBarrierWidth = 14.0f;
const CGFloat ipadBoundsInset    = 80.0f;
const CGFloat ipadBarrierWidth   = 26.0f;
const CGFloat rowHeightMultiplier = 1.9f;

@implementation HDHelper

+ (CGFloat)ipadBoundsWithInset {
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat width = CGRectGetWidth(bounds);
    width -= ipadBarrierWidth*2;
    width -= ipadBoundsInset*2;
    return width;
}

+ (CGFloat)universalBarrierWidth {
    return IS_IPAD ? ipadBarrierWidth : roundf(iphoneBarrierWidth * TRANSFORM_SCALE_X);
}

+ (CGFloat)universalRowHeight {
    return floorf(rowHeightMultiplier * [HDHelper universalColumnWidth]);
}

+ (CGFloat)universalColumnWidth {
    return IS_IPAD ? ceilf([[self class] ipadBoundsWithInset]/5): floorf([[self class] iphoneColumnWidth]/5);
}

+ (CGFloat)iphoneColumnWidth {
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat width = CGRectGetWidth(bounds);
    width -= iphoneBarrierWidth*2;
    return width;
}

@end
