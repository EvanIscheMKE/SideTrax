//
//  SKSpriteNode+HDSpriteNodeAdditions.h
//  FlatJump
//
//  Created by Evan Ische on 4/10/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKSpriteNode (HDSpriteNodeAdditions)
- (void)checkNodePositionForRemoval:(CGFloat)position;
@end
