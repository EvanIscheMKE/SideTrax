//
//  HDIAdHelper.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 2/6/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import StoreKit;
#import <Foundation/Foundation.h>

extern NSString * const IAPHelperProductPurchasedNotification;
typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);
@interface HDIAdHelper : NSObject
- (instancetype)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;
@end
