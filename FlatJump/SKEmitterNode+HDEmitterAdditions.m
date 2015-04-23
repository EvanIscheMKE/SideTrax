//
//  SKEmitterNode+HDEmitterAdditions.m
//  FlatJump
//
//  Created by Evan Ische on 3/28/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "UIColor+FlatColors.h"
#import "SKEmitterNode+HDEmitterAdditions.h"

CGFloat SCALED_FLOAT(CGFloat num) {
    return num * TRANSFORM_SCALE_X;
}

@implementation SKEmitterNode (EmitterAdditions)

+ (SKEmitterNode *)playerBoostWithColor:(SKColor *)color {
    
    SKEmitterNode *boost = [SKEmitterNode node];
    boost.particleTexture = [SKTexture textureWithImageNamed:@"ParticleSmall"];
    boost.emissionAngle      = M_PI + M_PI_2;
    boost.particlePositionRange = CGVectorMake(SCALED_FLOAT(8.0f), 0.0);
    boost.numParticlesToEmit = 0;
    boost.particleBirthRate  = SCALED_FLOAT(200.0f);
    boost.particleLifetime   = SCALED_FLOAT(.5f);
    boost.particleColor      = color;
    boost.particleSpeed      = 200.0f;
    boost.particleSpeedRange = 100.0f;
    boost.particleScale      = .3f;
    boost.particleScaleSpeed = -0.5f;
    boost.particleColorBlendFactor = 1.0f;
    boost.yAcceleration      = 0;
    
    return boost;
}

+ (SKEmitterNode *)explosionNode {
   
    SKEmitterNode *explosion = [[SKEmitterNode alloc] init];
    explosion.particleTexture    = [SKTexture textureWithImageNamed:@"Particle"];
    explosion.particleColor      = [UIColor whiteColor];
    explosion.numParticlesToEmit = SCALED_FLOAT(90.0f);
    explosion.particleBirthRate  = SCALED_FLOAT(90.0f);
    explosion.particleLifetime   = SCALED_FLOAT(1.3f);
    explosion.emissionAngleRange = 360;
    explosion.particleSpeed      = SCALED_FLOAT(100.0f);
    explosion.particleSpeedRange = SCALED_FLOAT(50.0f);
    explosion.particleAlpha      = 0.8f;
    explosion.particleAlphaRange = 0.2f;
    explosion.particleScale      = 0.6f;
    explosion.particleScaleSpeed = -0.6f;
    [explosion advanceSimulationTime:.925f];
    explosion.particleColorBlendFactor = 1;

    return explosion;
}


@end
