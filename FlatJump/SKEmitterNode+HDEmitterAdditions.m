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
    boost.particleTexture = [SKTexture textureWithImageNamed:@"Particle"];
    boost.emissionAngle      = M_PI + M_PI_2;
    boost.particlePositionRange = CGVectorMake(9.0f, 0.0);
    boost.numParticlesToEmit = 0;
    boost.particleBirthRate  = 200;
    boost.particleLifetime   = 1.0f;
    boost.particleColor      = color;
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

+ (SKEmitterNode *)spaceshipThrustWithColor:(SKColor *)color {
    
    SKEmitterNode *boost = [SKEmitterNode node];
    boost.particleTexture = [SKTexture textureWithImageNamed:@"Particle"];
    boost.emissionAngle      = M_PI + M_PI_2;
    boost.particlePositionRange = CGVectorMake(40.0f, 0.0);
    boost.numParticlesToEmit = 0;
    boost.particleBirthRate  = 175;
    boost.particleLifetime   = 1.0f;
    boost.particleColor      = color;
    boost.particleSpeed      = 200.0f;
    boost.particleSpeedRange = 200.0f;
    boost.particleScale      = .3f;
    boost.particleScaleSpeed = -0.4f;
    boost.particleBlendMode  = SKBlendModeAlpha;
    boost.particleColorBlendFactor = 1.0f;
    boost.yAcceleration      = 0;
    boost.zPosition          = 0;
    return boost;
}


@end
