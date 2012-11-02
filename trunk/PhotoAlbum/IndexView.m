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

- (id)initWithFrame:(CGRect)frame withAllLayerList:(NSArray*) allLayerList
{
    self = [super initWithFrame:frame];
    if (self) {
        _mainBoardList = [[NSMutableArray alloc] init];
        _mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 100)];
        _mainScroll.showsHorizontalScrollIndicator = NO;
        _mainScroll.showsVerticalScrollIndicator = NO;
        _mainScroll.alwaysBounceHorizontal = YES;
        _mainScroll.delegate = self;
        [self addSubview:_mainScroll];

        
        [self initLayerwithImageDataList:allLayerList];
        
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 100, self.frame.size.width, 100)];
        _bottomView.backgroundColor = [UIColor blackColor];
        [self addSubview:_bottomView];
        
        _slideLayer = [CALayer layer];
        _slideLayer.position = CGPointMake(0, 0);
        _slideLayer.backgroundColor = [UIColor whiteColor].CGColor;
        _slideLayer.bounds = CGRectMake(0, 0, 10, 20);
        _slideLayer.opacity = 0.3;
        [_bottomView.layer addSublayer:_slideLayer];
        
        [self makeMenuLayer];
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
        longPressRecognizer.minimumPressDuration = 0.3;
        [_bottomView addGestureRecognizer:longPressRecognizer];
        
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self  action:@selector(handleScale:)];
        [_bottomView addGestureRecognizer:pinchRecognizer];
        
        isPanning = NO;
    }
    return self;
}

- (void) makeMenuLayer {
    _menuLayer = [CALayer layer];
    _menuLayer.bounds = CGRectMake(0, 0, _bottomView.frame.size.width, _bottomView.frame.size.height);
    _menuLayer.position = CGPointMake(_bottomView.frame.size.width / 2, _bottomView.frame.size.height / 2);
    _menuLayer.backgroundColor = [UIColor whiteColor].CGColor;
//    _menuLayer.opacity = 0.5;
    [_bottomView.layer addSublayer:_menuLayer];
    
    CALayer *dTapLayer = [CALayer layer];
    dTapLayer.frame = CGRectMake(10, 10, 40, 40);
    dTapLayer.contents = (id)[UIImage imageNamed:@"Double_tap"].CGImage;
    [_menuLayer addSublayer:dTapLayer];
    
    CATextLayer *dTLayer = [CATextLayer layer];
    dTLayer.frame = CGRectMake(60, 20, 70, 30);
    dTLayer.string = @"Slide Show";
    dTLayer.foregroundColor = [UIColor redColor].CGColor;
    dTLayer.fontSize = 13.0f;
    dTLayer.alignmentMode = kCAAlignmentCenter;
    [_menuLayer addSublayer:dTLayer];
    
    CALayer *pinchLayer = [CALayer layer];
    pinchLayer.frame = CGRectMake(140, 50, 60, 40);
    pinchLayer.contents = (id)[UIImage imageNamed:@"Pinch"].CGImage;
    [_menuLayer addSublayer:pinchLayer];

    CATextLayer *pTLayer = [CATextLayer layer];
    pTLayer.frame = CGRectMake(200, 60, 100, 30);
    pTLayer.string = @"Closw View";
    pTLayer.foregroundColor = [UIColor redColor].CGColor;
    pTLayer.fontSize = 13.0f;
    pTLayer.alignmentMode = kCAAlignmentCenter;
    [_menuLayer addSublayer:pTLayer];

    CALayer *spreadLayer = [CALayer layer];
    spreadLayer.frame = CGRectMake(140, 10, 60, 40);
    spreadLayer.contents = (id)[UIImage imageNamed:@"Spread"].CGImage;
    [_menuLayer addSublayer:spreadLayer];

    CATextLayer *sTLayer = [CATextLayer layer];
    sTLayer.frame = CGRectMake(200, 20, 100, 30);
    sTLayer.string = @"Random Show";
    sTLayer.foregroundColor = [UIColor redColor].CGColor;
    sTLayer.fontSize = 13.0f;
    sTLayer.alignmentMode = kCAAlignmentCenter;
    [_menuLayer addSublayer:sTLayer];

    CALayer *pressLayer = [CALayer layer];
    pressLayer.frame = CGRectMake(10, 50, 40, 40);
    pressLayer.contents = (id)[UIImage imageNamed:@"Pressed"].CGImage;
    [_menuLayer addSublayer:pressLayer];
    
    CATextLayer *prTLayer = [CATextLayer layer];
    prTLayer.frame = CGRectMake(60, 60, 80, 30);
    prTLayer.string = @"Select Slide \nPhotos";
    prTLayer.foregroundColor = [UIColor redColor].CGColor;
    prTLayer.fontSize = 13.0f;
    prTLayer.alignmentMode = kCAAlignmentCenter;
    [_menuLayer addSublayer:prTLayer];
}

- (void) dealloc {
    NSLog(@"index view dealloc");
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    isPanning = NO;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    _slideLayer.position = CGPointMake(scrollView.contentOffset.x * (_bottomView.frame.size.width / (scrollView.contentSize.width)), _slideLayer.position.y);
}

- (void) initLayerwithImageDataList:(NSArray *)allLayerList {

    NSInteger thumbSize = 45;
    NSInteger thumbMargin = 3;

    NSLog(@"list count : %d", [allLayerList count]);
    CGFloat lastWidth = 0;
 
    for (NSDictionary *dic in allLayerList) {
        NSString *key = [[dic allKeys] objectAtIndex:0];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(lastWidth, 50, (([[dic objectForKey:key] count] -1) / 6) * (thumbMargin + thumbSize) + (thumbMargin + thumbSize + 5) , _mainScroll.frame.size.height - 50)];
        view.backgroundColor = [UIColor blackColor];
        [_mainScroll addSubview:view];
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.frame = CGRectMake(lastWidth + 5, 15, 80, 40);
        textLayer.alignmentMode = kCAAlignmentLeft;
        textLayer.fontSize = 14.0f;
        textLayer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS(- 30), 0, 0, 1);
        textLayer.string = [key stringByReplacingOccurrencesOfString:@"-" withString:@"."];
        textLayer.font = (__bridge CFTypeRef)([UIFont fontWithName:@"GillSans-Italic" size:13].fontName);
        [_mainScroll.layer addSublayer:textLayer];
        for (int j = 0 ; j < [[dic objectForKey:key] count] ; j ++) {

            UIButton *btn = [(NSArray*)[dic objectForKey:key] objectAtIndex:j];
            btn.frame = CGRectMake(thumbMargin + (thumbSize + thumbMargin) * (j/6), thumbMargin + (thumbSize + thumbMargin) * (j%6), thumbSize, thumbSize);
//            btn.layer.shouldRasterize = YES;
            [view addSubview:btn];

        }
        
        lastWidth = (([[dic objectForKey:key] count] -1) / 6) * (thumbMargin + thumbSize) + (thumbMargin + thumbSize + 5) + lastWidth;
        _mainScroll.contentSize = CGSizeMake(lastWidth + thumbMargin, _mainScroll.frame.size.height);
    }
    CALayer *lineLayer = [CALayer layer];
    lineLayer.backgroundColor = [UIColor darkGrayColor].CGColor;
    lineLayer.opacity = 0.5;
    lineLayer.frame = CGRectMake(0, self.frame.size.height - 101, _mainScroll.contentSize.width, 1);
    [_mainScroll.layer addSublayer:lineLayer];
}

- (void) handleTap:(UITapGestureRecognizer *) recognizer {
    if (isSlideRegisterMode) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(changeToSlideView)]) {
        [_delegate changeToSlideView];
    }
}

- (void) handlePan:(UIPanGestureRecognizer *) recognizer {
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *) recognizer;
    CGPoint location = [pan locationInView:pan.view];
    CGPoint delta = [pan translationInView:pan.view];
    CGFloat widthRatio = _mainScroll.contentSize.width / _mainScroll.frame.size.width * 0.5;
    CGFloat movingGap = (delta.x - forePoint.x) * widthRatio;

    if (_mainScroll.contentOffset.x <= 0) {
        movingGap *= 0.01;
    } else if (_mainScroll.contentOffset.x >= _mainScroll.contentSize.width - _mainScroll.frame.size.width) {
        movingGap *= 0.01;
    }

    if (pan.state == UIGestureRecognizerStateBegan) {
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        _bottomView.layer.contents = nil;
        bevelLayer.opacity = 1.0f;
        [CATransaction setDisableActions:YES];
        bevelLayer.position = location;
        [_mainScroll setContentOffset:CGPointMake(_mainScroll.contentOffset.x + movingGap, _mainScroll.contentOffset.y) animated:NO];
    } else {
        [CATransaction setDisableActions:NO];
        if (isSlideRegisterMode) {
            _bottomView.layer.contents = (id)[UIImage imageNamed:@"selectMode"].CGImage;
        } else {
            _bottomView.layer.contents = (id)[UIImage imageNamed:@"menu"].CGImage;
        }

        bevelLayer.opacity = 0.0f;
        if (_mainScroll.contentOffset.x < 0) {
            [_mainScroll setContentOffset:CGPointMake(0, _mainScroll.contentOffset.y) animated:YES];
        } else if (_mainScroll.contentOffset.x > _mainScroll.contentSize.width - _mainScroll.frame.size.width) {
            [_mainScroll setContentOffset:CGPointMake(_mainScroll.contentSize.width - _mainScroll.frame.size.width, _mainScroll.contentOffset.y) animated:YES];
        }
    }
    _slideLayer.position = CGPointMake(_mainScroll.contentOffset.x * (_bottomView.frame.size.width / (_mainScroll.contentSize.width)), 0);
    forePoint = delta;
}

- (void) changeSlideSetEnable:(BOOL) enable {
    if (enable) {
        isSlideRegisterMode = YES;
        _bottomView.layer.contents = (id)[UIImage imageNamed:@"selectMode"].CGImage;
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    } else {
        isSlideRegisterMode = NO;
        _bottomView.layer.contents = (id)[UIImage imageNamed:@"menu"].CGImage;
    }
}

- (void) handleLong:(UILongPressGestureRecognizer *) recognizer {
    if (isSlideRegisterMode) {
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self changeSlideSetEnable:YES];
        if (_delegate && [_delegate respondsToSelector:@selector(changeSlideSelectMode)]) {
            [_delegate changeSlideSelectMode];
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
