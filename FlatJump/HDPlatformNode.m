//
//  HDPlatformNode.m
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDPlatformNode.h"

static const CGFloat kVelocityY = 445.0f;
@implementation HDPlatformNode

- (void)collisionWithPlayer:(SKNode *)player completion:(CompletionBlock)completion {
    
    SKSpriteNode *child = (SKSpriteNode *)[[self children] firstObject];
    SKSpriteNode *playerChild = (SKSpriteNode *)[[player children] firstObject];
    
    const CGFloat kPlayerPosition = player.position.y - playerChild.size.height/2 + 7.4f;
    const CGFloat kSelfPosition = child.size.height/2 + self.position.y;
    
    BOOL update = NO;
    NSLog(@"PlayerPosition:%f, SelfPosition:%f",kPlayerPosition, kSelfPosition);
    if (player.physicsBody.velocity.dy < 0 && kPlayerPosition > kSelfPosition ) {
        
        update = YES;
        
        CGVector velocity;
        switch (self.platformType) {
            case HDPlatformTypeBreak:
                velocity = CGVectorMake(player.physicsBody.velocity.dx, 400.0f);
                break;
            case HDPlatformTypeLarge:
                velocity = CGVectorMake(player.physicsBody.velocity.dx, 400.0f);
                break;
            case HDPlatformTypeMedium:
                velocity = CGVectorMake(player.physicsBody.velocity.dx, kVelocityY);
                break;
            case HDPlatformTypeSmall:
                velocity = CGVectorMake(player.physicsBody.velocity.dx, 405.0f);
                break;

            default:
                break;
        }
        player.physicsBody.velocity = velocity;
    }
    if (completion) {
        completion(update, HDObjectTypePlatform);
    };
}

@end
