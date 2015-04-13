//
//  SKSpriteNode+HDSpriteNodeAdditions.m
//  FlatJump
//
//  Created by Evan Ische on 4/10/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "SKSpriteNode+HDSpriteNodeAdditions.h"

@implementation SKSpriteNode (HDSpriteNodeAdditions)

- (void)checkNodePositionForRemoval:(CGFloat)position {
    if (position > self.position.y + 350.0f) {
        [self removeFromParent];
    }
}

@end
