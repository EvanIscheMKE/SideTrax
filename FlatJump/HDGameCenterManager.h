//
//  HDGameCenterManager.h
//  SixTilesSquare
//
//  Created by Evan William Ische on 6/20/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import GameKit;

#import "HDAppDelegate.h"
#import <Foundation/Foundation.h>

extern NSString * const HDNormalLeaderboardKey;
extern NSString * const HDNormalReversedLeaderboardKey;
@interface HDGameCenterManager : NSObject
+ (HDGameCenterManager *)sharedManager;
+ (NSString *)leaderboardIdentifierFromState:(HDDirectionState)direction;
- (void)authenticateGameCenter;
- (void)reportLevelsCompleted:(int64_t)level forKey:(NSString *)key;
- (void)submitAchievementWithIdenifier:(NSString *)identifier
                      completionBanner:(BOOL)banner;
@end

