//
//  HDPointsManager.m
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDPointsManager.h"
#import "HDSettingsManager.h"

NSString * const HDHighScoreKey = @"highScoreKey";
NSString * const HDReversedHighScoreKey = @"reversedKey";
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
        self.score             = 0;
        self.highScore         = [[NSUserDefaults standardUserDefaults] integerForKey:HDHighScoreKey];
        self.reversedHighScore = [[NSUserDefaults standardUserDefaults] integerForKey:HDReversedHighScoreKey];
    }
    return self;
}

- (void)saveState {
    
    BOOL reversed = [HDSettingsManager sharedManager].reversed;
    if (reversed) {
        self.reversedHighScore = MAX(self.score, self.reversedHighScore);
        [[NSUserDefaults standardUserDefaults] setInteger:self.reversedHighScore
                                                   forKey:HDReversedHighScoreKey];
    } else {
        self.highScore = MAX(self.score, self.highScore);
        [[NSUserDefaults standardUserDefaults] setInteger:self.highScore
                                                   forKey:HDHighScoreKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
