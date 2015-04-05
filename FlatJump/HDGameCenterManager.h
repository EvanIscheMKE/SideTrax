//
//  HDGameCenterManager.h
//  SixTilesSquare
//
//  Created by Evan William Ische on 6/20/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import GameKit;

#import <Foundation/Foundation.h>

@interface HDGameCenterManager : NSObject
+ (HDGameCenterManager *)sharedManager;
- (void)authenticateGameCenter;
- (void)reportLevelCompletion:(int64_t)level;
- (void)submitAchievementWithIdenifier:(NSString *)identifier
                      completionBanner:(BOOL)banner;
@end

