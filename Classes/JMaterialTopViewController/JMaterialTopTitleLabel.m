//
//  JMaterialTopTitleLabel.m
//  
//
//  Created by jun on 2019/6/15.
//  Copyright © 2019 jun. All rights reserved.
//

#import "JMaterialTopTitleLabel.h"

@implementation JMaterialTopTitleLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.userInteractionEnabled = YES;
        
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [_fillColor set];
    
    rect.size.width = rect.size.width * _progress;
    
    UIRectFillUsingBlendMode(rect, kCGBlendModeSourceIn);
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    [self setNeedsDisplay];
}

@end
