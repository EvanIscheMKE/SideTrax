//
//  HDTextureManager.m
//  FlatJump
//
//  Created by Evan Ische on 4/23/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import SpriteKit;

#import "HDHelper.h"
#import "HDTextureManager.h"
#import "UIImage+ImageAdditions.h"

NSString * const HDRightArrowKey = @"RightArrow";
NSString * const HDLeftArrowKey  = @"leftArrow";
NSString * const HDEndPieceKey   = @"endPiece";
NSString * const HDVerticalKey   = @"vertical";
NSString * const HDHorizontalKey = @"horizontal";
NSString * const HDPlayerTextureKey = @"player";

@interface HDTextureManager ()
@property (nonatomic, strong) NSDictionary *textures;
@end

@implementation HDTextureManager

- (instancetype)init {
    if (self = [super init]) {
        _textures = [NSDictionary dictionary];
    }
    return self;
}

+ (HDTextureManager *)sharedManager {
    static HDTextureManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HDTextureManager alloc] init];
    });
    return manager;
}

- (void)preloadTexturesWithCompletion:(dispatch_block_t)completion {
    
    if ([_textures allKeys].count) {
        return;
    }
    
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Assets"];
    
    CGSize barrierSizeV = [HDHelper verticalBarrierSize];
    CGSize barrierSizeH = CGSizeMake([HDHelper universalColumnWidth], [HDHelper universalBarrierWidth]);
    CGSize barrierSizeE = CGSizeMake([HDHelper verticalBarrierWidth], [HDHelper universalBarrierWidth]);
    CGSize playerSize   = CGSizeMake(roundf(20.0f * TRANSFORM_SCALE_Y), roundf(20.0f * TRANSFORM_SCALE_Y));
    
    UIImage *barrierV = [UIImage shadowedBarrier:barrierSizeV];
    UIImage *barrierH = [UIImage shadowedBarrier:barrierSizeH];
    UIImage *barrierE = [UIImage shadowedBarrier:barrierSizeE];
    UIImage *player   = [UIImage playerWithSize:playerSize];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[HDRightArrowKey]    = [atlas textureNamed:HDRightArrowKey];
    dictionary[HDLeftArrowKey]     = [atlas textureNamed:HDLeftArrowKey];
    dictionary[HDVerticalKey]      = [SKTexture textureWithImage:barrierV];
    dictionary[HDHorizontalKey]    = [SKTexture textureWithImage:barrierH];
    dictionary[HDEndPieceKey]      = [SKTexture textureWithImage:barrierE];
    dictionary[HDPlayerTextureKey] = [SKTexture textureWithImage:player];
    
     _textures = dictionary;
    [SKTexture preloadTextures:[dictionary allValues] withCompletionHandler:^{
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }];
}

- (SKTexture *)textureWithName:(NSString *)name {
    return self.textures[name];
}

@end
