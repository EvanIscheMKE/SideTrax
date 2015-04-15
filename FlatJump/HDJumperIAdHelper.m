//
//  HDHexusIAdHelper.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/6/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDJumperIAdHelper.h"

NSString *const IAPremoveAdsProductIdentifier = @"com.EvanIsche.SideTrax.RemoveAds";
@implementation HDJumperIAdHelper

+ (HDJumperIAdHelper *)sharedHelper {
    static HDJumperIAdHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:IAPremoveAdsProductIdentifier, nil];
        helper = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return helper;
}

@end
