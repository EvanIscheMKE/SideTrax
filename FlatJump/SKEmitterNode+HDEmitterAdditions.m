//
//  SKEmitterNode+HDEmitterAdditions.m
//  FlatJump
//
//  Created by Evan Ische on 3/28/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "UIColor+FlatColors.h"
#import "SKEmitterNode+HDEmitterAdditions.h"

@implementation SKEmitterNode (HDEmitterAdditions)

+ (SKEmitterNode *)playerBoostWithColor:(SKColor *)color {
    
    SKEmitterNode *boost = [SKEmitterNode node];
    boost.particleTexture = [SKTexture textureWithImageNamed:@"spark"];
    boost.emissionAngle      = M_PI + M_PI_2;
    boost.particlePositionRange = CGVectorMake(12.0f, 0.0);
    boost.numParticlesToEmit = 100;
    boost.particleBirthRate  = 200;
    boost.particleLifetime   = 1.0f;
    boost.particleColor      = [SKColor flatSTYellowColor];
    boost.particleSpeed      = 200.0f;
    boost.particleSpeedRange = 200.0f;
    boost.particleScale      = .1f;
    boost.particleScaleSpeed = -0.4f;
    boost.particleBlendMode  = SKBlendModeAlpha;
    boost.particleColorBlendFactor = 1.0f;
    boost.yAcceleration      = 0;
    boost.zPosition          = 0;
    return boost;
}

@end
