//
//  HDSaveNode.m
//  FlatJump
//
//  Created by Evan Ische on 3/30/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDSaveNode.h"

@implementation HDSaveNode

- (void)checkNodePositionForRemoval:(CGFloat)position {
    if (position > self.position.y + 150.0f) {
        [self removeFromParent];
    }
}

@end
