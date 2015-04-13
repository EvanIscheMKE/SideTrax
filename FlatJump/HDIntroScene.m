//
//  HDIntroScene.m
//  FlatJump
//
//  Created by Evan Ische on 4/9/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDIntroScene.h"
#import "UIColor+FlatColors.h"
#import "SKEmitterNode+HDEmitterAdditions.h"

@implementation HDIntroScene {
    SKSpriteNode *_rocketShip;
}

- (instancetype)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor flatMidnightBlueColor];
        [self _setup];
    }
    return self;
}

- (void)_setup {
    
    _rocketShip = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    _rocketShip.position = CGPointMake(self.size.width/2, self.size.height - self.size.height/3.65);
    _rocketShip.zRotation = -M_PI_4;
    [self addChild:_rocketShip];
}

- (void)landTheShip {
    [_rocketShip removeAllActions];
    [_rocketShip removeAllChildren];
    _rocketShip.position = CGPointMake(self.size.width/2, self.size.height - self.size.height/3.65);
}

- (void)takeOffWithCompletion:(dispatch_block_t)completion {
    [self _addThrustToNode:_rocketShip];
    [_rocketShip runAction:[SKAction moveTo:[[self class] pointFromRadius:700.0f center:_rocketShip.position angle:M_PI_4]
                                   duration:.5f] completion:^{
        if (completion) {
            completion();
        }
    }];
}

- (void)_addThrustToNode:(SKSpriteNode *)node {
    
    SKColor *thrustColor = [UIColor flatSTWhiteColor];
    SKEmitterNode *boost = [SKEmitterNode spaceshipThrustWithColor:thrustColor];
    boost.targetNode = self.scene;
    boost.position = CGPointMake(0.0f, -(node.size.height/2 + 5.0f));
    [node addChild:boost];
}

#pragma mark - Class

// Angle in Radians
+ (CGPoint)pointFromRadius:(CGFloat)radius center:(CGPoint)center angle:(CGFloat)angle  {
    return CGPointMake(center.x + radius*cosf(angle), center.y + radius * sinf(angle));
}

@end
