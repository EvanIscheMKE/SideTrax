//
//  HDGameCenterManager.h
//  SixTilesSquare
//
//  Created by Evan William Ische on 6/20/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import GameKit;

#import <Foundation/Foundation.h>

extern NSString * const HDNormalLeaderboardKey;
extern NSString * const HDFastLeaderboardKey;
extern NSString * const HDNormalReversedLeaderboardKey;
extern NSString * const HDFastReversedLeaderboardKey;
@interface HDGameCenterManager : NSObject
+ (HDGameCenterManager *)sharedManager;
- (void)authenticateGameCenter;
- (void)reportLevelsCompleted:(int64_t)level forKey:(NSString *)key;
- (void)submitAchievementWithIdenifier:(NSString *)identifier
                      completionBanner:(BOOL)banner;
@end

