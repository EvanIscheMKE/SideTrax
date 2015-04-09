//
//  HDObjectNode.m
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDObjectNode.h"

@implementation HDObjectNode

- (void)collisionWithPlayer:(SKNode *)player completion:(dispatch_block_t)completion{
    
    if (completion) {
        completion();
    }
}

- (void)checkNodePositionForRemoval:(CGFloat)position {
    if (position > self.position.y + 350.0f) {
        [self removeFromParent];
    }
}

@end
