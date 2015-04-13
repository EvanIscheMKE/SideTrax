//
//  HDPlatformNode.m
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDBarrierNode.h"

@implementation HDBarrierNode

- (void)collisionWithPlayer:(SKNode *)player completion:(CompletionBlock)completion {
    
    [player removeAllChildren];
    [player removeAllActions];
    
    //instantiate explosion emitter
    SKEmitterNode *explosion = [[SKEmitterNode alloc] init];
    [explosion setParticleTexture:[SKTexture textureWithImageNamed:@"Particle"]];
    [explosion setParticleColor:[UIColor whiteColor]];
    [explosion setNumParticlesToEmit:90];
    [explosion setParticleBirthRate:90];
    [explosion setParticleLifetime:1.3f];
    [explosion setEmissionAngleRange:360];
    [explosion setParticleSpeed:180];
    [explosion setParticleSpeedRange:50];
    [explosion setXAcceleration:0];
    [explosion setYAcceleration:0];
    [explosion setParticleAlpha:0.8];
    [explosion setParticleAlphaRange:0.2];
    [explosion setParticleScale:0.5f];
    [explosion setParticleScaleSpeed:-0.6];
    [explosion setParticleRotation:0];
    [explosion setParticleRotationRange:0];
    [explosion setParticleRotationSpeed:0];
    [explosion advanceSimulationTime:.925f];
    
    [explosion setParticleColorBlendFactor:1];
    [explosion setParticleColorBlendFactorRange:0];
    [explosion setParticleColorBlendFactorSpeed:0];
    [explosion setParticleBlendMode:SKBlendModeAdd];
    
    //add this node to parent node
    [player addChild:explosion];
    
    
    if (completion) {
        completion(YES, HDObjectTypePlatform);
    };
}

@end
