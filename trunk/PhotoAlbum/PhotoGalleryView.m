//
//  PhotoGalleryView.m
//  PhotoAlbum
//
//  Created by 승필 백 on 12. 10. 15..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import "PhotoGalleryView.h"
#import "PhotoModel.h"

#define thumbMargin 1.0f
#define thumbSize 72.0f

@implementation PhotoGalleryView
- (CATransform3D) getTransForm3DIdentity {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = m34;
    transform = CATransform3DScale(transform, 0.5, 0.5, 0.5);
    return transform;
}

- (id)initWithFrame:(CGRect)frame withDataList:(NSArray *) dataList withTotalCount:(NSInteger) totalCount
{
    NSLog(@"self frame : %@", NSStringFromCGRect(frame));
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

- (void) makeTotalMainBoardView:(NSInteger) heightCount {
    for (int i = 0; i <columnCount; i++) {
        UIView *view = [[UIView alloc] init];
        view.userInteractionEnabled = NO;
        view.tag = i;
        [self addSubview:view];
        CALayer *layer = [view layer];
        layer.transform = [self getTransForm3DIdentity];
        layer.transform = CATransform3DRotate(layer.transform, DEGREES_TO_RADIANS(rotateAngle * ((i % columnCount))), 0, 1, 0);
        layer.anchorPointZ = -anchorPotinZ;
        layer.position = CGPointMake(self.center.x, 15 *MIN(heightCount,3) + i * 9);
        layer.bounds = CGRectMake(0, 0, self.frame.size.width, MIN(heightCount,3) * (thumbSize + thumbMargin));
        [_mainBoardList addObject:layer];
        
    }
}

- (void) makeDimmedLayer {
    CALayer *dimmedLayer = [CALayer layer];
    dimmedLayer.frame = CGRectMake(0, -20, self.frame.size.width, self.frame.size.height);
    dimmedLayer.backgroundColor = [UIColor blackColor].CGColor;
    dimmedLayer.opacity = 0.7;

    [self.layer addSublayer:dimmedLayer];
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

- (void) showTotalView:(NSArray*) btnIndexList withCount:(NSInteger) count {
    NSInteger sidNum = 1;
    
    columnCount = columnCount + 4 * sidNum;
    m34 = -1.0f/ (3000.0f + 400 * sidNum);
    anchorPotinZ = 300.0f + 60 * sidNum;
    
//    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    rotateAngle = RADIANS_TO_DEGREE(4*M_PI) / columnCount;
    NSLog(@"list count : %d", [btnIndexList count]);
    NSLog(@"total count : %d", count);
    NSMutableArray *selectedList = [NSMutableArray array];
    for (UIButton *btn in btnIndexList) {
        [selectedList addObject:btn];
    }
    currentIndex = 0;
    NSInteger selectedCount = [selectedList count] / columnCount;
    [self makeTotalMainBoardView:selectedCount];

    for (int i = -2 ; i <  4; i++) {
        UIView *view =[[self subviews] objectAtIndex:((currentIndex + i + columnCount) % columnCount)];
        view.userInteractionEnabled = YES;
        view =[[self subviews] objectAtIndex:((currentIndex + i + columnCount + 10) % columnCount)];
        view.userInteractionEnabled = YES;
        view =[[self subviews] objectAtIndex:((currentIndex + i + columnCount + 20) % columnCount)];
        view.userInteractionEnabled = YES;
        
    }
    

    for (int i = 0 ; i < MIN(120, selectedCount * columnCount) ; i++) {
        UIView *view = [[self subviews] objectAtIndex:(i % columnCount)];
        UIButton *btn = [selectedList objectAtIndex:arc4random() % [selectedList count]];
        [selectedList removeObject:btn];
        btn.frame = CGRectMake(thumbMargin, (i / columnCount) * (thumbSize + thumbMargin), thumbSize, thumbSize);

        CALayer *layer = [btn layer];
        layer.borderColor = [UIColor whiteColor].CGColor;
        layer.borderWidth = 1.5f;
        layer.cornerRadius = 0.0f;
        [view addSubview:btn];

        _lastLayer = layer;
    }
    CGFloat diff =  [[_mainBoardList objectAtIndex:0] frame].origin.y;
    firstPointY = diff;
//    self.frame = CGRectMake(0, -diff + thumbSize /2, self.frame.size.width, self.frame.size.height + diff - thumbSize /2);
    [self makeDimmedLayer];
}

- (void) dealloc {
    NSLog(@"gallery view dealloc");
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
        moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(layer.position.x, self.center.y - fabs(columnCount/2 - (i -currentIndex)) *5)];
    } else {
        moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(layer.position.x, self.center.y - fabs(columnCount/2 - (i -currentIndex)) *5)];
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

    [animationGroup setAnimations:[NSArray arrayWithObjects:rotationAnimation, nil]];

    
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
            isAnimating = NO;
            return;
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
        for (int i = -2 ; i <  4; i++) {
            UIView *view =[[self subviews] objectAtIndex:((currentIndex + i + columnCount) % columnCount)];
            view.userInteractionEnabled = YES;
            view =[[self subviews] objectAtIndex:((currentIndex + i + columnCount + 10) % columnCount)];
            view.userInteractionEnabled = YES;
            view =[[self subviews] objectAtIndex:((currentIndex + i + columnCount + 20) % columnCount)];
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
