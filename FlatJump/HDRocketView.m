//
//  HDRocketView.m
//  FlatJump
//
//  Created by Evan Ische on 4/9/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDRocketView.h"

@implementation HDRocketImageView {
    UIImageView *_rocketShip;
}

+ (Class)layerClass {
    return [CAEmitterLayer class];
}

- (CAEmitterLayer *)emitterLayer {
    return (CAEmitterLayer *)self.layer;
}

- (instancetype)initWithImage:(UIImage *)image {
    
    if (self = [super initWithImage:image]) {
        
        self.emitterLayer.emitterCells = @[];
        self.emitterLayer.emitterPosition = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds));
        
    }
    return self;
}

- (void)turnUpTheFire {
    
}

@end
