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

- (id)initWithFrame:(CGRect)frame withDataList:(NSArray *) dataList withTotalCount:(NSInteger) totalCount
{
    self = [super initWithFrame:frame];

    if (self) {
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        panRecognizer.minimumNumberOfTouches = 1;
        [self addGestureRecognizer:panRecognizer];
        
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLong:)];
        longPressRecognizer.minimumPressDuration = 0.3;
        [self addGestureRecognizer:longPressRecognizer];
        
        _mainBoardList = [[NSMutableArray alloc] init];

        columnCount = 36;
        heightMoveThreshold = 100;
        
        [self showTotalView:dataList withCount:totalCount];
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
    UIView *dimmedView = [[UIView alloc] initWithFrame:CGRectMake(0, -300, self.frame.size.width, self.frame.size.height + 300)];
    dimmedView.backgroundColor = [UIColor blackColor];
    dimmedView.alpha = 0.7;

    [self addSubview:dimmedView];
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

- (void) showTotalView:(NSArray*) allLayerList withCount:(NSInteger) count {
    NSInteger sidNum = count / 100;
    
    columnCount = columnCount + 4 * sidNum;
    m34 = -1.0f/ (3000.0f + 400 * sidNum);
    anchorPotinZ = 500.0f + 60 * sidNum;
    
    self.frame = CGRectMake(0, 0, self.frame.size.width, MAX(self.frame.size.height, ((count + [allLayerList count]) / columnCount + 2) * (thumbSize + thumbMargin)));
    rotateAngle = RADIANS_TO_DEGREE(2 * M_PI) / columnCount;
    NSLog(@"list count : %d", [allLayerList count]);
    NSLog(@"total count : %d", count);


    UIColor *colorList[10] = {[UIColor redColor],[UIColor blueColor],
        [UIColor greenColor],[UIColor yellowColor],
        [UIColor cyanColor],[UIColor grayColor],
        [UIColor purpleColor],[UIColor orangeColor],
        [UIColor brownColor],[UIColor whiteColor]};
    [self makeTotalMainBoardView];
    
    currentIndex = 0;
    
    NSInteger tcount = 0;
    for (NSDictionary *dic in allLayerList) {
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
    NSLog(@"self.frame : %@", NSStringFromCGRect(self.frame));
    [self makeDimmedLayer];
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

@end
