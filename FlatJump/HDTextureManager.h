//
//  HDTextureManager.h
//  FlatJump
//
//  Created by Evan Ische on 4/23/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString * const HDRightArrowKey;
NSString * const HDLeftArrowKey;
NSString * const HDEndPieceKey;
NSString * const HDVerticalKey;
NSString * const HDHorizontalKey;
NSString * const HDPlayerTextureKey;
@interface HDTextureManager : NSObject
+ (HDTextureManager *)sharedManager;
- (SKTexture *)textureWithName:(NSString *)name;
- (void)preloadTexturesWithCompletion:(dispatch_block_t)completion;
@end
