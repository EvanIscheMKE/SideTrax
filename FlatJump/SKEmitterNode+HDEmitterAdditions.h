//
//  SKEmitterNode+HDEmitterAdditions.h
//  FlatJump
//
//  Created by Evan Ische on 3/28/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKEmitterNode (HDEmitterAdditions)
+ (SKEmitterNode *)playerBoostWithColor:(SKColor *)color;
+ (SKEmitterNode *)explosionNode;
@end
