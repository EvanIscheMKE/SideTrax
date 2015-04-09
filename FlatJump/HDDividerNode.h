//
//  HDPlatformNode.h
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import SpriteKit;
#import "HDObjectNode.h"

typedef NS_ENUM(NSUInteger, HDDividerType) {
    HDDividerTypeMedium = 1,
    HDDividerTypeLarge  = 2,
    HDDividerTypeSmall  = 3,
    HDDividerTypeBreak  = 4
};

@interface HDDividerNode : HDObjectNode
@property (nonatomic, assign) HDDividerType platformType;
@end
