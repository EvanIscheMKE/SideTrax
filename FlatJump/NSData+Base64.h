//
//  NSData+Base64.h
//  base64
//
//  Created by Matt Gallagher on 2009/06/03.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Altered to work, Evan Ische 03/2015

#import <Foundation/Foundation.h>

void *NewBase64Decode(const char *inputBuffer, size_t length, size_t *outputLength);
char *NewBase64Encode(const void *inputBuffer, size_t length, bool separateLines, size_t *outputLength);
@interface NSData (Base64)
+ (NSData *)dataFromBase64String:(NSString *)aString;
- (NSString *)base64EncodedString;
@end
