//
//  HDPointsManager.h
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const HDHighScoreKey;
extern NSString * const HDCoinsKey;
extern NSString * const HDKeysKey;
extern NSString * const HDDoubleCoinKey;
@interface HDPointsManager : NSObject
@property (nonatomic, assign) BOOL doubleCoins;
@property (nonatomic, assign) BOOL temporaryDoubleXP;
@property (nonatomic, assign) NSUInteger highScore;
@property (nonatomic, assign) NSUInteger score;
@property (nonatomic, assign) NSUInteger coins;
@property (nonatomic, assign) NSUInteger keys;
+ (instancetype)sharedManager;
- (void)saveState;
- (void)clear;
@end
