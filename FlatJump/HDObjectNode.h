//
//  HDObjectNode.h
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import SpriteKit;

typedef NS_OPTIONS(NSUInteger, HDObjectType) {
    HDObjectTypePlatform = 3,
    HDObjectTypeNone     = 0
};

@interface HDObjectNode : SKNode
- (BOOL)collisionWithPlayer:(SKNode *)player;
- (BOOL)checkNodePositionForRemoval:(CGFloat)position ;
@end
