//
//  HDGameScene.h
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import SpriteKit;
@import UIKit;

#import "HDAppDelegate.h"

extern NSString * const HDLevelLayoutNotificationKey;
@class HDGridManager;
@interface HDGameScene : SKScene
@property (nonatomic, weak) HDGridManager *gridManager;
@property (nonatomic, assign) HDDirectionState direction;
@property (nonatomic, copy) dispatch_block_t updateDatabase;
- (void)layoutChildrenNode;
- (void)moveLeft;
- (void)moveRight;
@end
