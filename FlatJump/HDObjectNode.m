//
//  HDObjectNode.m
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDObjectNode.h"

@implementation HDObjectNode

- (BOOL)collisionWithPlayer:(SKNode *)player {
    return YES;
}

- (BOOL)checkNodePositionForRemoval:(CGFloat)position {
    static CGFloat height = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        height = CGRectGetHeight([UIScreen mainScreen].bounds)/1.75f;
    });
    return (position > self.position.y + height);
}

@end
