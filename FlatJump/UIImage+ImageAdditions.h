//
//  UIImage+ImageAdditions.h
//  FlatJump
//
//  Created by Evan Ische on 4/17/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageAdditions)
+ (UIImage *)backgroundImage;
+ (UIImage *)shadowedBarrier:(CGSize)size;
+ (UIImage *)playerWithSize:(CGSize)size;
@end
