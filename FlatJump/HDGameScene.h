//
//  HDGameScene.h
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import SpriteKit;
@import UIKit;

@class HDGridManager;
@interface HDGameScene : SKScene
@property (nonatomic, strong) HDGridManager *gridManager;
- (void)layoutChildrenNode;
@end
