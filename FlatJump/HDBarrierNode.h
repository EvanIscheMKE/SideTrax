//
//  HDPlatformNode.h
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import SpriteKit;
#import "HDObjectNode.h"

typedef NS_ENUM(NSUInteger, HDBarrierType) {
    HDDividerTypeMedium = 1,
    HDDividerTypeLarge  = 2,
};

@interface HDBarrierNode : HDObjectNode
@property (nonatomic, assign) HDBarrierType barrierType;
@end
