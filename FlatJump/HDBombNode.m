//
//  HDBombNode.m
//  FlatJump
//
//  Created by Evan Ische on 3/29/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDBombNode.h"

@implementation HDBombNode

- (void)collisionWithPlayer:(SKNode *)player completion:(CompletionBlock)completion {
    if (completion) {
        completion(NO,HDObjectTypeBomb);
    };
}

@end
