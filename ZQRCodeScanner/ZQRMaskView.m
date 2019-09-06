//
//  ZQRMaskView.m
//  ZQRCodeScanner
//
//  Created by 郑宇恒 on 2019/9/6.
//

#import "ZQRMaskView.h"

@interface ZQRMaskView ()
{
    CGRect _clearRect;
}

@property (nonatomic, strong) UIView *scanLineView;

@end

@implementation ZQRMaskView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame clearRect:(CGRect)clearRect {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        _clearRect = clearRect;
        
        [self addSubview:self.scanLineView];
        
        self.scanLineView.hidden = NO;
        CABasicAnimation *animationMove = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        animationMove.fromValue = [NSNumber numberWithFloat:(10)];
        animationMove.toValue = [NSNumber numberWithFloat:(_clearRect.size.height - 10)];
        animationMove.duration = 2;
        animationMove.repeatCount = HUGE_VALF;
        animationMove.fillMode = kCAFillModeForwards;
        animationMove.removedOnCompletion = NO;
        animationMove.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.scanLineView.layer addAnimation:animationMove forKey:@"scanLineMoveAnimation"];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self addClearRect:self.frame];
    [self addFourBorder:self.frame];
}

- (void)addClearRect:(CGRect)mainRect {
    CGFloat mainRectWidth = mainRect.size.width;
    CGFloat mainRectHeight = mainRect.size.height;
    [[UIColor colorWithWhite:0 alpha:0.5] setFill];
    UIRectFill(mainRect);
    if (CGRectIsEmpty(_clearRect)) {
        _clearRect = CGRectMake(mainRectWidth/6, mainRectHeight/5*2 - mainRectWidth/3, 2*mainRectWidth/3, 2*mainRectWidth/3);
    }
    CGRect clearIntersection = CGRectIntersection(_clearRect, mainRect);
    [[UIColor clearColor] setFill];
    UIRectFill(clearIntersection);
}

- (void)addFourBorder:(CGRect)mainRect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat angleLineWidth = 3;
    CGContextSetLineWidth(ctx, angleLineWidth);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1].CGColor);
    CGContextSetLineCap(ctx, kCGLineCapSquare);
    
    CGFloat x = _clearRect.origin.x;
    CGFloat y = _clearRect.origin.y;
    CGFloat width = _clearRect.size.width;
    CGFloat height = _clearRect.size.height;
    CGFloat angleWidth = height*0.1;
    CGPoint upLeftPoints[] = {
        CGPointMake(x+angleLineWidth/2, y+angleWidth+angleLineWidth/2),
        CGPointMake(x+angleLineWidth/2, y+angleLineWidth/2),
        CGPointMake(x+angleLineWidth/2, y+angleLineWidth/2),
        CGPointMake(x+angleWidth+angleLineWidth/2, y+angleLineWidth/2)
    };
    CGPoint upRightPoints[] = {
        CGPointMake(x+width-angleWidth-angleLineWidth/2, y+angleLineWidth/2),
        CGPointMake(x+width-angleLineWidth/2, y+angleLineWidth/2),
        CGPointMake(x+width-angleLineWidth/2, y+angleLineWidth/2),
        CGPointMake(x+width-angleLineWidth/2, y+angleWidth+angleLineWidth/2)
    };
    CGPoint belowLeftPoints[] = {
        CGPointMake(x+angleLineWidth/2, y+height-angleWidth-angleLineWidth/2),
        CGPointMake(x+angleLineWidth/2, y+height-angleLineWidth/2),
        CGPointMake(x+angleLineWidth/2, y+height-angleLineWidth/2),
        CGPointMake(x+angleWidth+angleLineWidth/2, y+height-angleLineWidth/2),
    };
    CGPoint belowRightPoints[] = {
        CGPointMake(x+width-angleWidth-angleLineWidth/2, y+height-angleLineWidth/2),
        CGPointMake(x+width-angleLineWidth/2, y+height-angleLineWidth/2),
        CGPointMake(x+width-angleLineWidth/2, y+height-angleLineWidth/2),
        CGPointMake(x+width-angleLineWidth/2, y+height-angleWidth-angleLineWidth/2),
    };
    CGContextStrokeLineSegments(ctx, upLeftPoints, 4);
    CGContextStrokeLineSegments(ctx, upRightPoints, 4);
    CGContextStrokeLineSegments(ctx, belowLeftPoints, 4);
    CGContextStrokeLineSegments(ctx, belowRightPoints, 4);
    
    CGContextSetLineWidth(ctx, 1);
    CGContextStrokeRect(ctx, _clearRect);
    CGContextDrawPath(ctx, kCGPathFillStroke);
}

#pragma mark - Getter
- (UIView *)scanLineView {
    if (!_scanLineView) {
        _scanLineView = [[UIView alloc] initWithFrame:CGRectMake(_clearRect.origin.x+5, _clearRect.origin.y, _clearRect.size.width - 10, 1)];
        _scanLineView.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1];
        _scanLineView.hidden = YES;
    }
    return _scanLineView;
}

@end
