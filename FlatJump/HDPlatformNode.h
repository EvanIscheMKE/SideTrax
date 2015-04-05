//
//  HDPlatformNode.h
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import SpriteKit;
#import "HDObjectNode.h"

typedef NS_ENUM(NSUInteger, HDPlatformType) {
    HDPlatformTypeMedium = 1,
    HDPlatformTypeLarge  = 2,
    HDPlatformTypeSmall  = 3,
    HDPlatformTypeBreak  = 4
};

@interface HDPlatformNode : HDObjectNode
@property (nonatomic, assign) HDPlatformType platformType;
@end
