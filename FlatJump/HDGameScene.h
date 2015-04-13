//
//  HDGameScene.h
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import SpriteKit;
@import UIKit;

typedef NS_OPTIONS(int8_t, HDDirectionState) {
    HDDirectionStateRegular = 1,
    HDDirectionStateReversed = 2,
    HDDirectionStateNone
};

typedef NS_OPTIONS(int8_t, HDGameSpeed) {
    HDGameSpeedFast = 1,
    HDGameSpeedNormal = 2,
    HDGameSpeedNone
};

extern NSString * const HDLevelLayoutNotificationKey;
@class HDGridManager;
@interface HDGameScene : SKScene
@property (nonatomic, strong) HDGridManager *gridManager;
@property (nonatomic, assign) HDDirectionState direction;
@property (nonatomic, assign) HDGameSpeed gameSpeed;
- (void)layoutChildrenNode;
@end
