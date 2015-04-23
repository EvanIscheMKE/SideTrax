//
//  HDPageControl.m
//  FlatJump
//
//  Created by Evan Ische on 4/20/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import QuartzCore;

#import "HDPageControl.h"
#import "HDAppDelegate.h"
#import "UIColor+FlatColors.h"

@implementation HDPageControl {
    CGFloat _dotSpacing;
    CGSize _dotSize;
}

- (instancetype)initWithFrame:(CGRect)frame {
    CGRect bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame));
    if (self = [super initWithFrame:bounds]) {
        
        _dotSize = CGSizeMake(12.0f, 12.0f);
        
        self.currentPageIndicatorTintColor = [UIColor flatSTEmeraldColor];
        
        self.pageIndicatorTintColor = [[UIColor grayColor] colorWithAlphaComponent:.3f];
        
        self.backgroundColor = [UIColor flatSTBackgroundColor];
    }
    return self;
}

- (void)_setup {
    
    _dotSpacing = _dotSize.width*1.4f;
    if (self.numberOfPages == 0) {
        return;
    }
    
    const CGFloat kStartOriginX = ceilf(CGRectGetMidX(self.bounds) - ((self.numberOfPages - 1)/2.0f) * _dotSpacing);
    for (NSInteger page = 0; page < self.numberOfPages; page++) {
        
        CGPoint point = CGPointMake(kStartOriginX + (page * _dotSpacing), CGRectGetMidY(self.bounds));
        
        CGRect dotBounds = CGRectMake(0.0f, 0.0f, _dotSize.width, _dotSize.height);
        UIView *dot = [[UIView alloc] initWithFrame:dotBounds];
        dot.layer.cornerRadius = CGRectGetMidY(dotBounds);
        dot.center = point;
        [self addSubview:dot];
    }
}

- (void)_update {
    
    NSUInteger index = 0;
    for (UIView *dot in self.subviews) {
        dot.backgroundColor = (index == self.currentPage) ? self.currentPageIndicatorTintColor : self.pageIndicatorTintColor;
        index++;
    }
}

- (void)setCurrentPage:(NSUInteger)currentPage {
    _currentPage = MIN(currentPage, self.numberOfPages - 1);
    [self _update];
}

- (void)setNumberOfPages:(NSUInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    [self _setup];
    [self setCurrentPage:MIN(self.currentPage, numberOfPages - 1)];
}

@end
