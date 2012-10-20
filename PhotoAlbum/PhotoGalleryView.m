//
//  PhotoGalleryView.m
//  PhotoAlbum
//
//  Created by 승필 백 on 12. 10. 15..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import "PhotoGalleryView.h"
#import "PhotoModel.h"

#define thumbMargin 8.0f
#define thumbSize 72.0f

@implementation PhotoGalleryView
- (CATransform3D) getTransForm3DIdentity {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = m34;
    transform = CATransform3DScale(transform, 0.8, 0.8, 0.8);
    return transform;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        panRecognizer.minimumNumberOfTouches = 1;
        [self addGestureRecognizer:panRecognizer];
        
        longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLong:)];
        longPressRecognizer.minimumPressDuration = 0.3;
        [self addGestureRecognizer:longPressRecognizer];
        
        UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self  action:@selector(handleScale:)];
        [pinchRecognizer setDelegate:self];
        [self addGestureRecognizer:pinchRecognizer];

        _mainBoardList = [[NSMutableArray alloc] init];
        _allLayerList = [[NSMutableArray alloc] init];
        
        _mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _mainScroll.showsHorizontalScrollIndicator = NO;
        _mainScroll.showsVerticalScrollIndicator = NO;
        _mainScroll.alwaysBounceHorizontal = YES;
        [self addSubview:_mainScroll];
        
        columnCount = 36;
        m34 = - 1.0f / 400.0f;
        anchorPotinZ = 500;
        heightMoveThreshold = 100;
    }
    return self;
}

- (void) makeTotalMainBoardView {
    for (int i = 0; i <columnCount; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(self.center.x - thumbMargin/2, 0, thumbSize + thumbMargin * 2, self.frame.size.height)];
        view.tag = i;
        [self addSubview:view];
        CALayer *layer = [view layer];
        layer.transform = [self getTransForm3DIdentity];
        layer.transform = CATransform3DRotate(layer.transform, DEGREES_TO_RADIANS(rotateAngle * ((i % columnCount))), 0, 1, 0);
        layer.anchorPointZ = -anchorPotinZ;
        [_mainBoardList addObject:layer];
    }
}

- (void) makeDimmedLayer {
    CALayer *dimmedLayer = [CALayer layer];
    dimmedLayer.backgroundColor = [UIColor blackColor].CGColor;
    dimmedLayer.opacity = 0.7;
    dimmedLayer.frame = CGRectMake(0, -300, self.frame.size.width, self.frame.size.height + 300);
    [self.layer addSublayer:dimmedLayer];
}

- (void) initLayerwithImageDataList:(NSArray *)dataList withCount:(NSInteger) count {
    showViewType = TOTALVIEW;
    NSInteger sidNum = count / 100;

    columnCount = columnCount + 4 * sidNum;
    m34 = -1.0f/ (3000.0f + 400 * sidNum);
    anchorPotinZ = 500.0f + 60 * sidNum;

    self.frame = CGRectMake(0, 0, self.frame.size.width, MAX(self.frame.size.height, ((count + [dataList count]) / columnCount + 2) * (thumbSize + thumbMargin)));
    initTotalViewSelfFrame = self.frame;
    
    if (_mainScroll) {
        [_mainScroll removeFromSuperview];
    }
    

    rotateAngle = RADIANS_TO_DEGREE(2 * M_PI) / columnCount;
    NSLog(@"list count : %d", [dataList count]);
    NSLog(@"total count : %d", count);
    
    [self makeTotalMainBoardView];
    
    currentIndex = 0;
    
    totalLayerCount = 0;
    makeDataCount = 0;
    
    [self performSelectorOnMainThread:@selector(makeDayLayer:) withObject:dataList waitUntilDone:NO];
}

- (void) makeDayLayer:(NSArray *) dataList {
    if (makeDataCount == [dataList count]) {
        CGFloat diff =  [[_mainBoardList objectAtIndex:0] frame].origin.y;
        firstPointY = diff;
        self.frame = CGRectMake(0, -diff + thumbSize /2, self.frame.size.width, self.frame.size.height + diff - thumbSize /2);
        
        [self makeDimmedLayer];
        CABasicAnimation *beginAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        beginAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        beginAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        beginAnimation.duration = 2.0f;
        [self.layer addAnimation:beginAnimation forKey:@"intro"];
        return;
    }
    
    UIColor *colorList[10] = {[UIColor redColor],[UIColor blueColor],
        [UIColor greenColor],[UIColor yellowColor],
        [UIColor cyanColor],[UIColor grayColor],
        [UIColor purpleColor],[UIColor orangeColor],
        [UIColor brownColor],[UIColor whiteColor]};
    
    CALayer *boardLayer = [_mainBoardList objectAtIndex:(totalLayerCount % columnCount)];
    UIColor *backColor = colorList[arc4random()%10];
    
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.frame = CGRectMake(thumbMargin, (totalLayerCount / columnCount) * (thumbSize + thumbMargin) + ((thumbSize + thumbMargin) / columnCount) * (totalLayerCount % columnCount), thumbSize, thumbSize);
    textLayer.alignmentMode = kCAAlignmentLeft;
    textLayer.fontSize = 13.0f;
    textLayer.backgroundColor = backColor.CGColor;
    textLayer.alignmentMode = kCAAlignmentCenter;
    [boardLayer addSublayer:textLayer];
    totalLayerCount ++;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSMutableArray *eachLayerList = [NSMutableArray array];
    for (PhotoModel *model in [dataList objectAtIndex:makeDataCount ++]) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(thumbMargin, (totalLayerCount / columnCount) * (thumbSize + thumbMargin) + ((thumbSize + thumbMargin) / columnCount) * (totalLayerCount % columnCount), thumbSize, thumbSize);
        btn.tag = totalLayerCount;
        [btn addTarget:self action:@selector(selectThis:) forControlEvents:UIControlEventTouchUpInside];
        UIView *view = [[self subviews] objectAtIndex:(totalLayerCount % columnCount)];
        textLayer.string = [[[[model time] description] componentsSeparatedByString:@" "] objectAtIndex:0];
        CALayer *layer = [btn layer];
        layer.backgroundColor = [UIColor whiteColor].CGColor;
        layer.name = [model assetUrl];
        layer.contents = (id) model.thumbImage.CGImage;
        
        layer.borderColor = backColor.CGColor;
        layer.borderWidth = 1.5f;

        _lastLayer = layer;
        [eachLayerList addObject:btn];
        
        [view addSubview:btn];
        totalLayerCount ++;
    }
    [dic setObject:eachLayerList forKey:textLayer.string];
    [_allLayerList addObject:dic];
    
    [self performSelectorOnMainThread:@selector(makeDayLayer:) withObject:dataList waitUntilDone:NO];
}

- (void) selectThis:(id) control {
    NSLog(@"btn : %d layer name :%@ frame:%@ super :%d", [control tag], [[control layer] name], NSStringFromCGRect([control frame]), [[control superview] tag]);
}

- (void) initSelfView {
    for (UIView *view in [self subviews]) {
        [view removeFromSuperview];
    }
    for (CALayer *layer in [self.layer sublayers]) {
        [layer removeFromSuperlayer];
    }
    [_mainBoardList removeAllObjects];
    self.layer.transform = CATransform3DIdentity;
}

- (void) showTotalView {    
    showViewType = TOTALVIEW;
    [self addGestureRecognizer:panRecognizer];
    [self addGestureRecognizer:longPressRecognizer];
    [self initSelfView];
    UIColor *colorList[10] = {[UIColor redColor],[UIColor blueColor],
        [UIColor greenColor],[UIColor yellowColor],
        [UIColor cyanColor],[UIColor grayColor],
        [UIColor purpleColor],[UIColor orangeColor],
        [UIColor brownColor],[UIColor whiteColor]};
    self.frame = initTotalViewSelfFrame;
    [self makeTotalMainBoardView];
    
    currentIndex = 0;
    
    NSInteger tcount = 0;
    for (NSDictionary *dic in _allLayerList) {
        NSString *key = [[dic allKeys] objectAtIndex:0];
        CALayer *boardLayer = [_mainBoardList objectAtIndex:(tcount % columnCount)];
        UIColor *backColor = colorList[arc4random()%10];
        
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.frame = CGRectMake(thumbMargin, (tcount / columnCount) * (thumbSize + thumbMargin) + ((thumbSize + thumbMargin) / columnCount) * (tcount % columnCount), thumbSize, thumbSize);
        textLayer.alignmentMode = kCAAlignmentLeft;
        textLayer.fontSize = 13.0f;
        textLayer.backgroundColor = backColor.CGColor;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.string = key;
        [boardLayer addSublayer:textLayer];
        tcount ++;
        
        for (int j = 0 ; j < [[dic objectForKey:key] count] ; j ++) {
            UIView *view = [[self subviews] objectAtIndex:(tcount % columnCount)];
            UIButton *btn = [(NSArray*)[dic objectForKey:key] objectAtIndex:j];
            btn.frame = CGRectMake(thumbMargin, (tcount / columnCount) * (thumbSize + thumbMargin) + ((thumbSize + thumbMargin) / columnCount) * (tcount % columnCount), thumbSize, thumbSize);

            CALayer *layer = [btn layer];
            layer.borderColor = backColor.CGColor;
            layer.borderWidth = 1.5f;
            layer.cornerRadius = 0.0f;
            [view addSubview:btn];
            
            _lastLayer = layer;
            tcount ++;
        }
        
    }
    
    CGFloat diff =  [[_mainBoardList objectAtIndex:0] frame].origin.y;
    firstPointY = diff;
    self.frame = CGRectMake(0, -diff + thumbSize /2, self.frame.size.width, self.frame.size.height + diff - thumbSize /2);
    
    [self makeDimmedLayer];
}

- (void) showIndexView {
    showViewType = INDEXVIEW;
    [self removeGestureRecognizer:panRecognizer];
    [self removeGestureRecognizer:longPressRecognizer];
    [self initSelfView];
    
    self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 20);
    self.layer.opacity = 1.0f;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:scrollView];
    
    
    CGFloat btnMargin = 2.0f;
    CGFloat btnWidth = ([[UIScreen mainScreen] applicationFrame].size.width - btnMargin *3) / 2 ;
    CGFloat btnHeight = 110;
    
    CGFloat layerMargin = 3.0f;
    CGFloat layerSize = (btnWidth - layerMargin*4) / 4;
    
    int i = 0;
    for (NSDictionary *dic in _allLayerList) {
        NSString *key = [[dic allKeys] objectAtIndex:0];
        //            NSLog(@"key : %@", key);
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor grayColor];
        btn.frame = CGRectMake((i % 2) * (btnWidth + btnMargin) + btnMargin, (i++ /2 ) * (btnHeight + btnMargin) + btnMargin, btnWidth, btnHeight);
        [scrollView addSubview:btn];
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, btn.frame.origin.y + btn.frame.size.height);
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, btnWidth, 10)];
        titleLabel.backgroundColor =[UIColor clearColor];
        titleLabel.text = key;
        titleLabel.font = [UIFont systemFontOfSize:12.0f];
        [titleLabel setTextAlignment:UITextAlignmentLeft];
        [btn addSubview:titleLabel];
        
        
        for (int j = 0 ; j < MIN(6, [[dic objectForKey:key] count]) ; j ++) {
            CALayer *layer = [[(NSArray*)[dic objectForKey:key] objectAtIndex:j] layer];
            layer.borderWidth = 1.5f;
            layer.borderColor = [UIColor whiteColor].CGColor;
            layer.frame = CGRectMake(btnWidth / 2 - layerSize*1.2  + (layerSize + layerMargin) * (j % 3), btnHeight / 2 - layerSize * 0.8 + (layerSize + layerMargin) * (j / 3), layerSize, layerSize);
            [btn.layer addSublayer:layer];
        }
    }
}

- (BOOL) isTopLimit {
    CALayer *firstLayer = [_mainBoardList objectAtIndex:0];
    if (firstLayer.frame.origin.y >= firstPointY) {
        return YES;
    }
    return NO;
}

- (BOOL) isBottomLimit {
    if ([_lastLayer superlayer].frame.origin.y + _lastLayer.frame.origin.y < [[UIScreen mainScreen] applicationFrame].size.height) {
        return YES;
    }
    return NO;
}



- (void) rotateMovingAnimation:(NSInteger) moveStep toLayer:(CALayer*)layer index:(NSInteger) i duration:(CGFloat) duration{
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    if (moveStep > 0) {
        moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(layer.position.x, layer.position.y + ((thumbSize + thumbMargin) / columnCount) * (moveStep % columnCount))];
    } else {
        moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(layer.position.x, layer.position.y - ((thumbSize + thumbMargin) / columnCount) * ((-moveStep) % columnCount))];
    }
    moveAnimation.duration = duration;
    moveAnimation.fillMode = kCAFillModeForwards;
    moveAnimation.removedOnCompletion = NO;
    moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotationAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DRotate([(CALayer*)[layer presentationLayer] transform], DEGREES_TO_RADIANS(rotateAngle * moveStep), 0, 1, 0)];
    rotationAnimation.duration = duration;
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = duration;
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.delegate = self;
    [animationGroup setValue:[NSString stringWithFormat:@"rotating%d",i] forKey:@"animation"];
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    if ((moveStep > 0 && [self isTopLimit]) || (moveStep <0 && [self isBottomLimit])) {
        [animationGroup setAnimations:[NSArray arrayWithObjects:rotationAnimation, nil]];
    } else {
        [animationGroup setAnimations:[NSArray arrayWithObjects:moveAnimation, rotationAnimation, nil]];
    }
    
    [layer addAnimation:animationGroup forKey:@"animationGroup"];
}

- (void) handleLong:(UILongPressGestureRecognizer *) recognizer {

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (isSliding) {
            isSliding = NO;
        } else {
            if (isAnimating) {
                return;
            }
            isAnimating = YES;
            isSliding = YES;
            NSInteger moveStep = -1;
            currentIndex = (currentIndex - moveStep + columnCount) % columnCount;
            for (int i=0; i < [_mainBoardList count]; i++) {
                [self rotateMovingAnimation:moveStep toLayer:[_mainBoardList objectAtIndex:i] index:i duration:0.8];
            }
            
        }        
    }
}

- (void) handlePan:(UIPanGestureRecognizer *) recognizer {

    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *) recognizer;

    CGPoint velocity = [pan velocityInView:pan.view];
    CGPoint delta = CGPointMake(velocity.x * 0.5, velocity.y * 0.5);
//    delta = [pan translationInView:pan.view];
    if (pan.state == UIGestureRecognizerStateBegan) {
        forePoint = CGPointZero;
        isDiresctionWidth = fabs(delta.x) > fabs(delta.y);
    }

    NSInteger moveStep = 0;
    if (!isDiresctionWidth) {
        moveStep = delta.y / heightMoveThreshold;
    } else {
        moveStep = delta.x / 80;
    }

//    NSLog(@"moveStep = %d  isANimating :%d", moveStep, isAnimating);
    if (moveStep == 0) {
        return;
    }
    
    if (isAnimating) {
        return;
    }
    
    isAnimating = YES;
    if (isDiresctionWidth) {
        currentIndex = (currentIndex - moveStep + columnCount) % columnCount;        
    }
    
    int i = 0;
    for (CALayer *layer in _mainBoardList) {
        if (isDiresctionWidth) {
            [self rotateMovingAnimation:moveStep toLayer:layer index:i++ duration:0.5];
        } else {
            if ((moveStep > 0 && [self isTopLimit]) || (moveStep <0 && [self isBottomLimit])) {
                isAnimating = NO;
                return;
            }
            CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
            if (moveStep > 0) {
                moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(layer.position.x, layer.position.y + ((thumbSize + thumbMargin) * moveStep))];
            } else {
                moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(layer.position.x, layer.position.y - ((thumbSize + thumbMargin) * (- moveStep)))];
            }
            moveAnimation.duration = 0.5;
            moveAnimation.fillMode = kCAFillModeForwards;
            moveAnimation.removedOnCompletion = NO;
            moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

            CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
            animationGroup.duration = 0.5;
            animationGroup.removedOnCompletion = NO;
            animationGroup.fillMode = kCAFillModeForwards;
            animationGroup.delegate = self;
            [animationGroup setValue:[NSString stringWithFormat:@"rotating%d",i++] forKey:@"animation"];
            animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            [animationGroup setAnimations:[NSArray arrayWithObjects:moveAnimation, nil]];
            [layer addAnimation:animationGroup forKey:@"animationGroup"];
        }


    }
    forePoint = delta;    
}

- (void) handleScale:(UIPinchGestureRecognizer *) recognizer {
    if (isAnimating) {
        return;
    }
    if (recognizer.scale < 1) {
        if (showViewType == INDEXVIEW) {
            return;
        }
        showViewType = INDEXVIEW;
        [CATransaction begin];
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.toValue = [NSNumber numberWithFloat:0.0f];
        opacityAnimation.duration = 0.5;
        opacityAnimation.fillMode = kCAFillModeForwards;
        opacityAnimation.removedOnCompletion = NO;

        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
        scaleAnimation.toValue = [NSNumber numberWithFloat:0.0f];
        scaleAnimation.duration = 0.5;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;

        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.duration = 0.49;
        animationGroup.removedOnCompletion = NO;
        animationGroup.fillMode = kCAFillModeForwards;
        animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [animationGroup setAnimations:[NSArray arrayWithObjects:opacityAnimation,scaleAnimation, nil]];
        
        [CATransaction setCompletionBlock:^(){
            [self.layer removeAllAnimations];
            [self showIndexView];
        }];
        [self.layer addAnimation:animationGroup forKey:@"animationGroup"];
        
        [CATransaction commit];
    } else {
        if (showViewType == TOTALVIEW) {
            return;
        }
        showViewType = TOTALVIEW;
        [CATransaction begin];
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.toValue = [NSNumber numberWithFloat:0.0f];
        opacityAnimation.duration = 0.5;
        opacityAnimation.fillMode = kCAFillModeForwards;
        opacityAnimation.removedOnCompletion = NO;
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.toValue = [NSNumber numberWithFloat:4.0f];
        scaleAnimation.duration = 0.5;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.duration = 0.49;
        animationGroup.removedOnCompletion = NO;
        animationGroup.fillMode = kCAFillModeForwards;
        animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [animationGroup setAnimations:[NSArray arrayWithObjects:opacityAnimation,scaleAnimation, nil]];
        
        [CATransaction setCompletionBlock:^(){
            [self.layer removeAllAnimations];
            [self showTotalView];
        }];
        [self.layer addAnimation:animationGroup forKey:@"animationGroup"];
        
        [CATransaction commit];
    }
    NSLog(@"scale: %f", recognizer.scale);
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSString *value = [anim valueForKey:@"animation"];
    if ([value isEqualToString:[NSString stringWithFormat:@"rotating%d",columnCount - 1]] || [value isEqualToString:[NSString stringWithFormat:@"scale%d",columnCount - 1]]){
        for (UIView *view in [self subviews]) {
            view.userInteractionEnabled = NO;
            view.layer.position = [(CALayer*)[view.layer presentationLayer] position];
            view.layer.transform = [(CALayer*)[view.layer presentationLayer] transform];
        }
        
        for (int i = -5 ; i <  5; i++) {
            UIView *view =[[self subviews] objectAtIndex:((currentIndex + i + columnCount) % columnCount)];
            view.userInteractionEnabled = YES;
        }
        isAnimating = NO;        
        if (isSliding) {
            NSInteger moveStep = -1;
            currentIndex = (currentIndex - moveStep + columnCount) % columnCount;
            isAnimating = YES;
            for (int i=0; i < [_mainBoardList count]; i++) {
                [self rotateMovingAnimation:moveStep toLayer:[_mainBoardList objectAtIndex:i] index:i duration:0.8];
            }
        }

    }
}

//- (void) initLayerwithImageDataList:(NSArray *)dataList {
//
//    if (_mainScroll) {
//        [_mainScroll removeFromSuperview];
//        _mainBoardList = [[NSMutableArray alloc] init];
//        _mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//        _mainScroll.showsHorizontalScrollIndicator = NO;
//        _mainScroll.showsVerticalScrollIndicator = NO;
//        _mainScroll.alwaysBounceHorizontal = YES;
//        [self addSubview:_mainScroll];
//    }
//    NSLog(@"list count : %d", [dataList count]);
//    lastWidth = 0;
//    NSInteger imgAngle[3] = {-3, 0, 3};
//    NSInteger count = 0;
//
//    for (int i = 0; i < [dataList count]; i++) {
////        CALayer *boardLayer = [CALayer layer];
////        boardLayer.frame = CGRectMake(lastWidth, 5, 10 + ceil([[dataList objectAtIndex:i] count] / 4.0f) * (thumbSize + thumbMargin), self.frame.size.height);
////        [_mainScroll.layer addSublayer:boardLayer];
//        
//        CATextLayer *textLayer = [CATextLayer layer];
//        textLayer.frame = CGRectMake(lastWidth + 5, 15, 80, 20);
//        textLayer.alignmentMode = kCAAlignmentLeft;
//        textLayer.fontSize = 14.0f;
//        textLayer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS(- 30), 0, 0, 1);
//        
//        [_mainScroll.layer addSublayer:textLayer];
//        int j = 0;
//        for (PhotoModel *model in [dataList objectAtIndex:i]) {
//            textLayer.string = [[[[model time] description] componentsSeparatedByString:@" "] objectAtIndex:0];
////            boardLayer.name = [[[[model time] description] componentsSeparatedByString:@" "] objectAtIndex:0];
//            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//            btn.frame = CGRectMake(lastWidth + thumbMargin + (thumbSize + thumbMargin) * (j/4), 50 + thumbMargin + (thumbSize + thumbMargin) * (j++%4), thumbSize, thumbSize);
//            CALayer *layer = [btn layer];
//            layer.borderColor = [UIColor grayColor].CGColor;
//            layer.borderWidth = 0.5f;
//            
//            [layer setShadowPath:[UIBezierPath bezierPathWithRect:layer.bounds].CGPath];
//            layer.shadowColor = [UIColor whiteColor].CGColor;
//            layer.shadowOpacity = 2.0f;
//            layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
////            layer.shouldRasterize = YES;
////            layer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS(imgAngle[arc4random()%3]), 0, 0, 1);
//            [_mainScroll addSubview:btn];
//            
//            layer.contents = (id) model.thumbImage.CGImage;
//            
//            
//            count ++;
//                        
//        }
//        lastWidth = 10 + ceil([[dataList objectAtIndex:i] count] / 4.0f) * (thumbSize + thumbMargin) + _mainScroll.contentSize.width;
//        _mainScroll.contentSize = CGSizeMake(lastWidth, self.frame.size.height);
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _mainScroll.contentSize.width, _mainScroll.contentSize.height)];
//        view.backgroundColor = [UIColor blackColor];
//        [_mainScroll insertSubview:view atIndex:0];
//    }
//    NSLog(@"total count : %d", count);
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
