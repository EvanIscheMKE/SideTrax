//
//  HDPlatformNode.m
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDBarrierNode.h"
#import "SKEmitterNode+HDEmitterAdditions.h"

@implementation HDBarrierNode

- (void)collisionWithPlayer:(SKNode *)player completion:(CompletionBlock)completion {
    
    [player removeAllChildren];
    [player removeAllActions];
    
    SKEmitterNode *explosion = [SKEmitterNode explosionNode];
    [player addChild:explosion];
        
    NSTimeInterval delayInSeconds = explosion.numParticlesToEmit / explosion.particleBirthRate + explosion.particleLifetime;
    [explosion performSelector:@selector(removeFromParent) withObject:nil afterDelay:delayInSeconds];

    if (completion) {
        completion(YES, HDObjectTypePlatform);
    };
}

@end
