//
//  HDPointsManager.m
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDPointsManager.h"

NSString * const HDHighScoreKey = @"highScoreKey";
NSString * const HDCoinsKey = @"coinsKey";
NSString * const HDKeysKey = @"keyskey";
NSString * const HDDoubleCoinKey = @"doubleCoinKey";
@implementation HDPointsManager

+ (instancetype)sharedManager {
    static HDPointsManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        self.score = 0;
        self.coins = 0;
        self.highScore = 0;
        self.keys = 0;
        self.temporaryDoubleXP = NO;
        
        self.doubleCoins  = [[NSUserDefaults standardUserDefaults] boolForKey:HDDoubleCoinKey];
        self.keys         = [[NSUserDefaults standardUserDefaults] integerForKey:HDKeysKey];
        self.coins        = [[NSUserDefaults standardUserDefaults] integerForKey:HDCoinsKey];
        self.highScore    = [[NSUserDefaults standardUserDefaults] integerForKey:HDHighScoreKey];
  
    }
    return self;
}

- (void)saveState {
    
    self.highScore = MAX(self.score, self.highScore);
    [[NSUserDefaults standardUserDefaults] setInteger:self.highScore forKey:HDHighScoreKey];
    [[NSUserDefaults standardUserDefaults] setInteger:self.coins     forKey:HDCoinsKey];
    [[NSUserDefaults standardUserDefaults] setInteger:self.keys      forKey:HDKeysKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)clear {
    self.score = 0;
    self.coins = 0;
    self.keys = 0;
    self.highScore = 0;
}

@end
