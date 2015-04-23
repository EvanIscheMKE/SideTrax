//
//  HDAbstractScene.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 3/25/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "SKNode+NodeAdditions.h"

@implementation SKNode (NodeAdditions)

- (BOOL)isEqual:(id)object {
    
    if (object == self) {
        return YES;
    }
    
    if (object == nil) {
        return NO;
    }
    
    if ([object class] != [self class]) {
        return NO;
    }
    
    if (![[object name] isEqualToString:[self name]]) {
        return NO;
    }
    
    if ([object parent] != [self parent]) {
        return NO;
    }
    
    if (![[object children] isEqualToArray:[self children]]) {
        return NO;
    }
    
    if (![[object scene]isEqual:[self scene]]) {
        return NO;
    }
    
    return [object hash] == [self hash];
}

@end
