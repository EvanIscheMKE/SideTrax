//
//  HDPointsManager.m
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDPointsManager.h"

NSString * const HDHighScoreKey = @"highScoreKey";
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
        self.highScore = [[NSUserDefaults standardUserDefaults] integerForKey:HDHighScoreKey];
    }
    return self;
}

- (void)saveState {
    
    self.highScore = MAX(self.score, self.highScore);
    [[NSUserDefaults standardUserDefaults] setInteger:self.highScore forKey:HDHighScoreKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
