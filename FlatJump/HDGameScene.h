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
@property (nonatomic, strong) HDGridManager *gridManager;
@property (nonatomic, assign) HDDirectionState direction;
- (void)layoutChildrenNode;
@end
