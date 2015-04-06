//
//  HDPointsManager.h
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const HDHighScoreKey;
extern NSString * const HDKeysKey;
@interface HDPointsManager : NSObject
@property (nonatomic, assign) NSUInteger highScore;
@property (nonatomic, assign) NSUInteger score;
@property (nonatomic, assign) NSUInteger keys;
+ (instancetype)sharedManager;
- (void)saveState;
@end
