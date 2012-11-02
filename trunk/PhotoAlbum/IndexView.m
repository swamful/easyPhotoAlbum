//
//  IndexView.m
//  PhotoAlbum
//
//  Created by Seungpill Baik on 12. 10. 21..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import "IndexView.h"
#import <AudioToolbox/AudioToolbox.h>
@implementation IndexView
@synthesize delegate = _delegate;
- (CATransform3D) getTransForm3DIdentity {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = m34;
    transform = CATransform3DScale(transform, 0.8, 0.8, 0.8);
    return transform;
}

- (id)initWithFrame:(CGRect)frame withAllLayerList:(NSArray*) allLayerList currentIndex:(NSInteger) currentIndex
{
    self = [super initWithFrame:frame];
    if (self) {
        _mainBoardList = [[NSMutableArray alloc] init];
        _mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 100)];
        _mainScroll.showsHorizontalScrollIndicator = NO;
        _mainScroll.showsVerticalScrollIndicator = NO;
        _mainScroll.alwaysBounceHorizontal = YES;
        _mainScroll.delegate = self;
        _mainScroll.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        [self addSubview:_mainScroll];

        
        [self initLayerwithImageDataList:allLayerList currentIndex:currentIndex];
        
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 100, self.frame.size.width, 100)];
        _bottomView.layer.contents = (id) [UIImage imageNamed:@"controllPannel"].CGImage;
        [self addSubview:_bottomView];
        
        _slideLayer = [CALayer layer];
        _slideLayer.position = CGPointMake(0, 0);
        _slideLayer.backgroundColor = [UIColor whiteColor].CGColor;
        _slideLayer.bounds = CGRectMake(0, 0, 10, 20);
        _slideLayer.opacity = 0.3;
        [_bottomView.layer addSublayer:_slideLayer];
        
//        [self makeMenuLayer];
        bevelLayer = [CALayer layer];
        [bevelLayer setBounds:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
        bevelLayer.opacity = 0.0f;
        
        [bevelLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
        [bevelLayer setShadowOpacity:1.0];
        [bevelLayer setShadowRadius:7.0f];
        [bevelLayer setShadowColor:[[UIColor colorWithRed:0.0f/255.0  green:126.0f/255.0f blue:255.0f/255.0f alpha:1.0f] CGColor]];
        [bevelLayer setShadowPath:[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(-15.0f, -15.0f, 80.0f, 80.0f) cornerRadius:40.0f] CGPath]];
        [_bottomView.layer addSublayer:bevelLayer];
        
        UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        panRecognizer.minimumNumberOfTouches = 1;
        [_bottomView addGestureRecognizer:panRecognizer];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tapRecognizer.numberOfTapsRequired = 2;
        [_bottomView addGestureRecognizer:tapRecognizer];
        [CATransaction setDisableActions:NO];
        
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLong:)];
        longPressRecognizer.minimumPressDuration = 0.4;
        [_bottomView addGestureRecognizer:longPressRecognizer];
        
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self  action:@selector(handleScale:)];
        [_bottomView addGestureRecognizer:pinchRecognizer];
        
        _selectModeLayer = [CATextLayer layer];
        _selectModeLayer.string = @"Select Slide Photos";
        _selectModeLayer.font = (__bridge CFTypeRef)([UIFont fontWithName:@"GillSans-Italic" size:30].fontName);
        _selectModeLayer.frame = CGRectMake(0, 25, 320, 50);
        _selectModeLayer.foregroundColor = [UIColor whiteColor].CGColor;
        _selectModeLayer.alignmentMode = kCAAlignmentCenter;
        _selectModeLayer.opacity = 0.0f;
        [_bottomView.layer addSublayer:_selectModeLayer];

        UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
        infoBtn.frame = CGRectMake(-5, -5, 40, 40);
        [infoBtn addTarget:nil action:@selector(showGuideView) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:infoBtn];
        
        isPanning = NO;
    }
    return self;
}

- (void) dealloc {
    NSLog(@"index view dealloc");
}

- (void) beginAnimation {
    for (CALayer *layer in [_mainScroll.layer sublayers]) {
        if ([layer.name isEqualToString:@"textLayer"]) {
            layer.opacity = 0.0f;
            layer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS(40), 0, 0, 1);
        }
    }


    [CATransaction begin];
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    moveAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x + self.frame.size.width * 1.5, _mainScroll.center.y)];
    moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.center.x, _mainScroll.center.y)];
    moveAnimation.duration = 0.7f;
    moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [CATransaction setCompletionBlock:^(){
        for (CALayer *layer in [_mainScroll.layer sublayers]) {
            if ([layer.name isEqualToString:@"textLayer"]) {
                layer.opacity = 1.0f;
                layer.transform = CATransform3DRotate(layer.transform, DEGREES_TO_RADIANS(-70), 0, 0, 1);
            }
        }
    }];
    [_mainScroll.layer addAnimation:moveAnimation forKey:@"moveAnimation"];
    [CATransaction commit];
    
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    isPanning = NO;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    _slideLayer.position = CGPointMake(scrollView.contentOffset.x * (_bottomView.frame.size.width / (scrollView.contentSize.width - scrollView.frame.size.width)), _slideLayer.position.y);
}

- (void) initLayerwithImageDataList:(NSArray *)allLayerList currentIndex:(NSInteger) currentIndex {
    CGFloat currentOffset;
    NSInteger thumbSize = 45;
    NSInteger thumbMargin = 3;

//    NSLog(@"list count : %d", [allLayerList count]);
    CGFloat lastWidth = 0;
 
    for (NSDictionary *dic in allLayerList) {
        NSString *key = [[dic allKeys] objectAtIndex:0];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(lastWidth, 50, (([[dic objectForKey:key] count] -1) / 6) * (thumbMargin + thumbSize) + (thumbMargin + thumbSize + 5) , _mainScroll.frame.size.height - 50)];
        view.backgroundColor = [UIColor blackColor];
        [_mainScroll addSubview:view];
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.frame = CGRectMake(lastWidth - 20, 50, 80, 40);
        textLayer.alignmentMode = kCAAlignmentLeft;
        textLayer.anchorPoint = CGPointMake(0.0f, 1.0f);
        textLayer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS(-30), 0, 0, 1);
        textLayer.fontSize = 14.0f;

        textLayer.name = @"textLayer";
        textLayer.string = [key stringByReplacingOccurrencesOfString:@"-" withString:@"."];
        textLayer.font = (__bridge CFTypeRef)([UIFont fontWithName:@"GillSans-Italic" size:13].fontName);
        [_mainScroll.layer addSublayer:textLayer];
        for (int j = 0 ; j < [[dic objectForKey:key] count] ; j ++) {

            UIButton *btn = [(NSArray*)[dic objectForKey:key] objectAtIndex:j];
            btn.frame = CGRectMake(thumbMargin + (thumbSize + thumbMargin) * (j/6), thumbMargin + (thumbSize + thumbMargin) * (j%6), thumbSize, thumbSize);
//            btn.layer.shouldRasterize = YES;
            [view addSubview:btn];
            if (btn.tag == currentIndex) {
                currentOffset = view.frame.origin.x;
            }

        }
        
        lastWidth = (([[dic objectForKey:key] count] -1) / 6) * (thumbMargin + thumbSize) + (thumbMargin + thumbSize + 5) + lastWidth;
        _mainScroll.contentSize = CGSizeMake(lastWidth + thumbMargin, _mainScroll.frame.size.height);
    }
    CALayer *lineLayer = [CALayer layer];
    lineLayer.backgroundColor = [UIColor darkGrayColor].CGColor;
    lineLayer.opacity = 0.5;
    lineLayer.frame = CGRectMake(0, self.frame.size.height - 101, _mainScroll.contentSize.width, 1);
    [_mainScroll.layer addSublayer:lineLayer];
    [_mainScroll setContentOffset:CGPointMake(MIN(currentOffset, _mainScroll.contentSize.width - _mainScroll.frame.size.width), _mainScroll.contentOffset.y) animated:YES];
}

- (void) handleTap:(UITapGestureRecognizer *) recognizer {
    if (isSlideRegisterMode) {
        return;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(changeToSlideView)]) {
        [_delegate changeToSlideView];
    }
}

- (void) handlePan:(UIPanGestureRecognizer *) recognizer {
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *) recognizer;
    CGPoint location = [pan locationInView:pan.view];
    CGPoint delta = [pan translationInView:pan.view];
    CGFloat widthRatio = (_mainScroll.contentSize.width - _mainScroll.frame.size.width) / _mainScroll.frame.size.width;
    CGFloat movingGap = (delta.x - forePoint.x) * widthRatio;

    if (_mainScroll.contentOffset.x <= 0) {
        movingGap *= _mainScroll.frame.size.width / _mainScroll.contentSize.width;
    } else if (_mainScroll.contentOffset.x >= _mainScroll.contentSize.width - _mainScroll.frame.size.width) {
        movingGap *= _mainScroll.frame.size.width / _mainScroll.contentSize.width;
    }
    if (pan.state == UIGestureRecognizerStateBegan) {
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        bevelLayer.opacity = 1.0f;
        [CATransaction setDisableActions:YES];
        bevelLayer.position = location;
        [_mainScroll setContentOffset:CGPointMake(_mainScroll.contentOffset.x + movingGap, _mainScroll.contentOffset.y) animated:NO];
    } else {
        [CATransaction setDisableActions:NO];
        bevelLayer.opacity = 0.0f;
        if (_mainScroll.contentOffset.x < 0) {
            [_mainScroll setContentOffset:CGPointMake(0, _mainScroll.contentOffset.y) animated:YES];
        } else if (_mainScroll.contentOffset.x > _mainScroll.contentSize.width - _mainScroll.frame.size.width) {
            [_mainScroll setContentOffset:CGPointMake(_mainScroll.contentSize.width - _mainScroll.frame.size.width, _mainScroll.contentOffset.y) animated:YES];
        }
    }
    _slideLayer.position = CGPointMake(_mainScroll.contentOffset.x * (_bottomView.frame.size.width / (_mainScroll.contentSize.width - _mainScroll.frame.size.width)), 0);
    forePoint = delta;
}

- (void) changeSlideSetEnable:(BOOL) enable {
    if (enable) {
        isSlideRegisterMode = YES;
        _selectModeLayer.opacity = 1.0f;
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    } else {
        isSlideRegisterMode = NO;
        _bottomView.layer.contents = (id) [UIImage imageNamed:@"controllPannel"].CGImage;
        _selectModeLayer.opacity = 0.0f;
    }
}

- (void) handleLong:(UILongPressGestureRecognizer *) recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (isSlideRegisterMode) {
            [self changeSlideSetEnable:NO];
            if (_delegate && [_delegate respondsToSelector:@selector(changeSlideSelectMode:)]) {
                [_delegate changeSlideSelectMode:NO];
            }
            return;
        }
        
        [self changeSlideSetEnable:YES];
        if (_delegate && [_delegate respondsToSelector:@selector(changeSlideSelectMode:)]) {
            [_delegate changeSlideSelectMode:YES];
        }        
    }
}

- (void) handleScale:(UIPinchGestureRecognizer *) recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (recognizer.scale > 1.0f) {
            if (_delegate && [_delegate respondsToSelector:@selector(changeToRandomView)]) {
                [_delegate changeToRandomView];
            }
        }
    }
}


@end
