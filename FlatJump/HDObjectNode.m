//
//  HDObjectNode.m
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDObjectNode.h"

@implementation HDObjectNode

- (void)collisionWithPlayer:(SKNode *)player completion:(CompletionBlock)completion{
    
    if (completion) {
        completion(NO,HDObjectTypeNone);
    }
}

- (void)checkNodePositionForRemoval:(CGFloat)position completion:(RemovalBlock)completion; {
    if (position > self.position.y + CGRectGetHeight([UIScreen mainScreen].bounds)/1.75f) {
        if (completion) {
            completion(YES);
            return;
        }
    }
    if (completion) {
        completion(NO);
    }
}



@end
