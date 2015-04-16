//
//  HDObjectNode.h
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import SpriteKit;

typedef NS_OPTIONS(u_int8_t, HDObjectType) {
    HDObjectTypePlatform = 3,
    HDObjectTypeNone     = 0
};

typedef void (^CompletionBlock)(BOOL update, HDObjectType type);
typedef void (^RemovalBlock)(BOOL remove);

@interface HDObjectNode : SKNode
- (void)collisionWithPlayer:(SKNode *)player completion:(CompletionBlock)completion;
- (void)checkNodePositionForRemoval:(CGFloat)position completion:(RemovalBlock)completion;
@end
