//
//  IndexView.m
//  PhotoAlbum
//
//  Created by Seungpill Baik on 12. 10. 21..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import "IndexView.h"

@implementation IndexView
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
        _slideLayer.position = CGPointMake(20, _bottomView.frame.size.height / 2);
        _slideLayer.backgroundColor = [UIColor whiteColor].CGColor;
        _slideLayer.bounds = CGRectMake(0, 0, 40, 40);
        _slideLayer.opacity = 0.3;
        _slideLayer.cornerRadius = 20.0f;
        [_bottomView.layer addSublayer:_slideLayer];
        
        
        UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        panRecognizer.minimumNumberOfTouches = 1;
        [_bottomView addGestureRecognizer:panRecognizer];
        [CATransaction setDisableActions:NO];
        
        isPanning = NO;
    }
    return self;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    isPanning = NO;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!isPanning) {
        _slideLayer.position = CGPointMake(scrollView.contentOffset.x * ((_bottomView.frame.size.width - 40.0f)/ (scrollView.contentSize.width)) + 20.0f, _slideLayer.position.y);
    }
    
}

- (void) initLayerwithImageDataList:(NSArray *)allLayerList {

    NSInteger thumbSize = 40;
    NSInteger thumbMargin = 2;

    NSLog(@"list count : %d", [allLayerList count]);
    CGFloat lastWidth = 0;
 
    for (NSDictionary *dic in allLayerList) {
        NSString *key = [[dic allKeys] objectAtIndex:0];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(lastWidth, 50, (([[dic objectForKey:key] count] -1) / 8) * (thumbMargin + thumbSize + 5) + (thumbMargin + thumbSize + 5), _mainScroll.frame.size.height - 50)];
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
//            btn.frame = CGRectMake(lastWidth + thumbMargin + (thumbSize + thumbMargin) * (j/7), 50 + thumbMargin + (thumbSize + thumbMargin) * (j%7), thumbSize, thumbSize);
            btn.frame = CGRectMake(thumbMargin + (thumbSize + thumbMargin) * (j/7), thumbMargin + (thumbSize + thumbMargin) * (j%7), thumbSize, thumbSize);
            btn.layer.borderColor = [UIColor grayColor].CGColor;
            btn.layer.borderWidth = 0.5f;

//            [layer setShadowPath:[UIBezierPath bezierPathWithRect:layer.bounds].CGPath];
//            layer.shadowColor = [UIColor whiteColor].CGColor;
//            layer.shadowOpacity = 2.0f;
//            layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
//            layer.shouldRasterize = YES;
//            layer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS(imgAngle[arc4random()%3]), 0, 0, 1);
            [view addSubview:btn];

        }
        
//        UIGraphicsBeginImageContext(view.layer.bounds.size);
//        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
//        UIImage *oldImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//
//        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] scale] > 1) {
//            CALayer *reflectionLayer = [CALayer layer];
//            reflectionLayer.contents = (id)oldImage.CGImage;
//            reflectionLayer.frame = CGRectMake(15, view.frame.size.height+25, view.frame.size.width, view.frame.size.height);
//            reflectionLayer.opacity = 0.7;
//            // Transform X by 180 degrees
//            [reflectionLayer setValue:[NSNumber numberWithFloat:DEGREES_TO_RADIANS(215)] forKeyPath:@"transform.rotation.x"];
//            [reflectionLayer setValue:[NSNumber numberWithFloat:DEGREES_TO_RADIANS(10)] forKeyPath:@"transform.rotation.y"];
//            [view.layer addSublayer:reflectionLayer];
//    
//            
//            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//            gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor],(id)[[UIColor whiteColor] CGColor], nil];
//            gradientLayer.startPoint = CGPointMake(0.5, 0.0);
//            gradientLayer.endPoint = CGPointMake(0.5, 0.7);
//            gradientLayer.bounds = reflectionLayer.bounds;
//            gradientLayer.position = CGPointMake(reflectionLayer.bounds.size.width / 2 , reflectionLayer.bounds.size.height * 0.65);
//            // Add gradient layer as a mask
//            reflectionLayer.mask = gradientLayer;
//        }
        
        lastWidth = (([[dic objectForKey:key] count] -1) / 7) * (thumbMargin + thumbSize) + (thumbMargin + thumbSize + 5) + lastWidth;
        _mainScroll.contentSize = CGSizeMake(lastWidth + thumbMargin, _mainScroll.frame.size.height);
    }
    CALayer *lineLayer = [CALayer layer];
    lineLayer.backgroundColor = [UIColor darkGrayColor].CGColor;
    lineLayer.opacity = 0.5;
    lineLayer.frame = CGRectMake(0, self.frame.size.height - 101, _mainScroll.contentSize.width, 1);
    [_mainScroll.layer addSublayer:lineLayer];
}

- (void) handlePan:(UIPanGestureRecognizer *) recognizer {
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *) recognizer;
    CGPoint location = [pan locationInView:pan.view];
    
    if (!CGRectContainsPoint(_slideLayer.frame, location)) {
        return;
    }
    
    CGRect gestureBound = CGRectMake(20, 0, _bottomView.frame.size.width - 40, _bottomView.frame.size.height);
    if (!CGRectContainsPoint(gestureBound, location)) {
        [CATransaction setDisableActions:NO];
        _slideLayer.opacity = 0.3;
        _slideLayer.bounds = CGRectMake(0, 0, 40, 40);
        _slideLayer.position = CGPointMake(15, _slideLayer.position.y);
        _slideLayer.cornerRadius = 20.0f;
        _slideLayer.shadowOpacity = 0.0f;
        if (location.x < 20) {
            _slideLayer.position = CGPointMake(20, _slideLayer.position.y);
           [_mainScroll setContentOffset:CGPointMake(0, _mainScroll.contentOffset.y) animated:NO];
        } else {
            _slideLayer.position = CGPointMake(_bottomView.frame.size.width - 20, _slideLayer.position.y);
           [_mainScroll setContentOffset:CGPointMake(_mainScroll.contentSize.width - _mainScroll.frame.size.width, _mainScroll.contentOffset.y) animated:NO];
        }
        if (pan.state >= UIGestureRecognizerStateEnded) {
            isPanning = NO;            
        }

        return;
    }
    
    [CATransaction setDisableActions:YES];
    CGFloat positionX = location.x * (_bottomView.frame.size.width - 40) / _bottomView.frame.size.width;
    _slideLayer.position = CGPointMake(positionX + 20, _slideLayer.position.y);
    location = CGPointMake(positionX * ((_mainScroll.contentSize.width - _mainScroll.frame.size.width)/ (_bottomView.frame.size.width - 40)) , location.y);
    if (pan.state == UIGestureRecognizerStateBegan) {
        [CATransaction setDisableActions:NO];
        _slideLayer.bounds = CGRectMake(0, 0, 80, 80);
        _slideLayer.cornerRadius = 40.0f;
        _slideLayer.shadowColor = [UIColor grayColor].CGColor;
        _slideLayer.shadowOpacity = 5.0f;
        _slideLayer.shadowOffset = CGSizeMake(-10.0f, -10.0f);
        isPanning = YES;
        [_mainScroll setContentOffset:CGPointMake(location.x, _mainScroll.contentOffset.y) animated:NO];
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        [_mainScroll setContentOffset:CGPointMake(location.x, _mainScroll.contentOffset.y) animated:NO];
    } else {
        [CATransaction setDisableActions:NO];
        _slideLayer.opacity = 0.3;
        _slideLayer.bounds = CGRectMake(0, 0, 40, 40);
        _slideLayer.cornerRadius = 20.0f;
        _slideLayer.shadowOpacity = 0.0f;
        [_mainScroll setContentOffset:CGPointMake(location.x, _mainScroll.contentOffset.y) animated:NO];
        isPanning = NO;
    }
    


}
@end
