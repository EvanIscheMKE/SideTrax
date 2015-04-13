//
//  HDPlatformNode.h
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import SpriteKit;
#import "HDObjectNode.h"

typedef NS_ENUM(int8_t, HDBarrierType) {
    HDBarrierTypeHorizontalSquare = 1,
    HDBarrierTypeVerticalSquare  = 2,
    HDBarrierTypeNone = 0
};

@interface HDBarrierNode : HDObjectNode
@property (nonatomic, assign) HDBarrierType barrierType;
@end
