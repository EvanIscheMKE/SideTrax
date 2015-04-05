//
//  HDKeyNode.m
//  FlatJump
//
//  Created by Evan Ische on 4/1/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDKeyNode.h"
#import "HDPointsManager.h"

@implementation HDKeyNode

- (void)collisionWithPlayer:(SKNode *)player completion:(CompletionBlock)completion {
    
    [HDPointsManager sharedManager].keys += 1;
    
    [self removeFromParent];
    
    if (completion) {
        completion(YES,HDObjectTypeKey);
    };
}

@end
