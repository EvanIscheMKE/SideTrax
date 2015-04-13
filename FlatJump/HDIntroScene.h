//
//  HDIntroScene.h
//  FlatJump
//
//  Created by Evan Ische on 4/9/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface HDIntroScene : SKScene
- (void)takeOffWithCompletion:(dispatch_block_t)completion;
- (void)landTheShip;
@end
