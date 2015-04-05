//
//  HDGameCenterManager.m
//  SixTilesSquare
//
//  Created by Evan William Ische on 6/20/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDGameCenterManager.h"

NSString * const HDLeaderboardKey = @"LevelLeaderboard";

@implementation HDGameCenterManager

+ (HDGameCenterManager *)sharedManager {
    static HDGameCenterManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[HDGameCenterManager alloc] init];
    });
    return _manager;
}

- (void)authenticateGameCenter {
    
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        return;
    };
  
    [[NSNotificationCenter defaultCenter] addObserverForName:GKPlayerAuthenticationDidChangeNotificationName
                                                      object:[GKLocalPlayer localPlayer]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      NSLog(@"%@",note);
                                                  }];
    
    [GKLocalPlayer localPlayer].authenticateHandler = ^(UIViewController* viewController, NSError *error) {
        NSLog(@"%@",error);
    };
}

- (void)reportLevelCompletion:(int64_t)level {
    
    if (![GKLocalPlayer localPlayer].isAuthenticated) {
        return;
    }
    
    GKScore *completedLevel = [[GKScore alloc] initWithLeaderboardIdentifier:HDLeaderboardKey];
    completedLevel.value = level;
    [GKScore reportScores:@[completedLevel] withCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"%@ : %@",error,NSStringFromSelector(_cmd));
        }
    }];
}

- (void)submitAchievementWithIdenifier:(NSString *)identifier completionBanner:(BOOL)banner {
    
    if (![GKLocalPlayer localPlayer].isAuthenticated) {
        return;
    }
    
    GKAchievement *scoreAchievement = [[GKAchievement alloc] initWithIdentifier:identifier];
    scoreAchievement.showsCompletionBanner = banner;
    [GKAchievement reportAchievements:@[scoreAchievement] withCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"%@",[error localizedDescription]);
        }
    }];
}

@end
