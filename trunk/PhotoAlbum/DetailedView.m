//
//  DetailedView.m
//  PhotoAlbum
//
//  Created by 승필 백 on 12. 10. 22..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import "DetailedView.h"
#define twoLeftIndex 0
#define centerIndex 2
#define leftIndex 1
#define rightIndex 3
#define twoRightIndex 4
@interface NSMutableArray(ShiftArray)
- (void) shiftArrayWithCount:(NSInteger) shiftCount;
@end

@implementation NSMutableArray(ShiftArray)
- (void) shiftArrayWithCount:(NSInteger) shiftCount {
    if (shiftCount == 0 || [self count] == 0) {
        return;
    }
    if (shiftCount > 0) {
        for (int i =0 ; i < shiftCount; i++) {
            id object = [self lastObject];
            [self removeLastObject];
            [self insertObject:object atIndex:0];
        }
    } else {
        for (int i = shiftCount ; i < 0; i++) {
            id object = [self objectAtIndex:0];
            [self removeObjectAtIndex:0];
            [self addObject:object];
        }
    }
}
@end
@implementation DetailedView
- (CATransform3D) getViewTransForm3DIdentity {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = - 1.0f/ 2000.0f;
    //    transform = CATransform3DTranslate(transform, 0, 0, 200);
    return transform;
}

- (NSString*) getAlassetUrlStringWithBtnIndex:(NSInteger) index {
    return [[[_btnIndexList objectAtIndex:index] layer] name];
}

- (id)initWithFrame:(CGRect)frame withBtnIndexList:(NSArray*) btnIndexList currentIndex:(NSInteger) index
{
    self = [super initWithFrame:frame];
    if (self) {        
        currentIndex = index;
        _btnIndexList = btnIndexList;
        _layerList = [[NSMutableArray alloc] init];
        requestImageQueue = [[NSMutableArray alloc] init];

        mainLayer = [CALayer layer];
        mainLayer.frame = self.frame;
        [self.layer addSublayer:mainLayer];
        
        [_layerList addObject:[self makeLayer]];
        [_layerList addObject:[self makeLayer]];
        [_layerList addObject:[self makeLayer]];
        [_layerList addObject:[self makeLayer]];
        [_layerList addObject:[self makeLayer]];

        [mainLayer addSublayer:[_layerList objectAtIndex:twoLeftIndex]];
        [mainLayer addSublayer:[_layerList objectAtIndex:twoRightIndex]];
        [mainLayer addSublayer:[_layerList objectAtIndex:leftIndex]];
        [mainLayer addSublayer:[_layerList objectAtIndex:centerIndex]];
        [mainLayer addSublayer:[_layerList objectAtIndex:rightIndex]];
        
        leftPoint = CGPointMake(self.center.x - (self.frame.size.width * 0.85), self.center.y);
        centerPoint = CGPointMake(self.center.x, self.center.y);
        rightPoint = CGPointMake(self.center.x + (self.frame.size.width * 0.85), self.center.y);
        twoLeftPoint = CGPointMake(self.center.x - (self.frame.size.width * 0.85) * 2, self.center.y);
        twoRightPoint = CGPointMake(self.center.x + (self.frame.size.width * 0.85) * 2, self.center.y);
        
        NSNumber *leftNumber = [NSNumber numberWithInt:leftIndex];
        NSNumber *twoLeftNumber = [NSNumber numberWithInt:twoLeftIndex];
        NSNumber *centerNumber = [NSNumber numberWithInt:centerIndex];
        NSNumber *rightNumber = [NSNumber numberWithInt:rightIndex];
        NSNumber *twoRightNumber = [NSNumber numberWithInt:twoRightIndex];
        
        [requestImageQueue addObject:centerNumber];
        [requestImageQueue addObject:leftNumber];
        [requestImageQueue addObject:rightNumber];
        [requestImageQueue addObject:twoLeftNumber];
        [requestImageQueue addObject:twoRightNumber];
        
        [[_layerList objectAtIndex:twoLeftIndex] setPosition:twoLeftPoint];
        [[_layerList objectAtIndex:twoRightIndex] setPosition:twoRightPoint];
        [[_layerList objectAtIndex:leftIndex] setPosition:leftPoint];
        [[_layerList objectAtIndex:centerIndex] setPosition:centerPoint];
        [[_layerList objectAtIndex:rightIndex] setPosition:rightPoint];
        
        if (currentIndex == 0) {
            [[_layerList objectAtIndex:twoLeftIndex] setPosition:CGPointMake(twoLeftPoint.x, twoLeftPoint.y + 400)];
            [[_layerList objectAtIndex:leftIndex] setPosition:CGPointMake(twoLeftPoint.x, twoLeftPoint.y + 400)];
            [requestImageQueue removeObject:leftNumber];
            [requestImageQueue removeObject:twoLeftNumber];
        } else if (currentIndex == 1) {
            [[_layerList objectAtIndex:twoLeftIndex] setPosition:CGPointMake(twoLeftPoint.x, twoLeftPoint.y + 400)];
            [requestImageQueue removeObject:twoLeftNumber];
        }
        
        if (currentIndex == [_btnIndexList count] - 2) {
            [[_layerList objectAtIndex:twoRightIndex] setPosition:CGPointMake(twoRightPoint.x, twoRightPoint.y + 400)];
            [requestImageQueue removeObject:twoRightNumber];
        } else if (currentIndex == [_btnIndexList count] - 1) {
            [[_layerList objectAtIndex:twoRightIndex] setPosition:CGPointMake(twoRightPoint.x, twoRightPoint.y + 400)];
            [[_layerList objectAtIndex:rightIndex] setPosition:CGPointMake(twoRightPoint.x, twoRightPoint.y + 400)];
            [requestImageQueue removeObject:rightNumber];
            [requestImageQueue removeObject:twoRightNumber];
        }
        
        alAssetManager = [ALAssetsManager getSharedInstance];
        alAssetManager.delegate = self;
        isInit = YES;
        [self makeLayerList];
        
        UIView *topDimmedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 60)];
        topDimmedView.backgroundColor = [UIColor grayColor];
        topDimmedView.alpha = 0.5;
        [self addSubview:topDimmedView];
        
        UIView *bottomDimmedView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 40, self.frame.size.width, 40)];
        bottomDimmedView.backgroundColor = [UIColor grayColor];
        bottomDimmedView.alpha = 0.5;
        [self addSubview:bottomDimmedView];
        
        panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        panRecognizer.minimumNumberOfTouches = 1;
        [self addGestureRecognizer:panRecognizer];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tapRecognizer];
        
    }
    [CATransaction setDisableActions:NO];
    return self;
}

- (void) makeLayerList {
    if ([requestImageQueue count] == 0) {
        [self makeTextToCurrentView];
        isInit = 0;
        currentLayer = nil;
        return;
    }
    NSInteger index = [[requestImageQueue objectAtIndex:0] intValue];
    currentLayer = [_layerList objectAtIndex:index];
    [self requestPhotoWithInt:currentIndex + (index -centerIndex)];
    [requestImageQueue removeObjectAtIndex:0];
}

- (CALayer*) makeLayer {
    CALayer *boardLayer = [CALayer layer];
    boardLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    CALayer *layer = [CALayer layer];
    layer.transform = [self getViewTransForm3DIdentity];
    layer.transform = CATransform3DScale(layer.transform, 0.7, 0.7,0.7);
    layer.bounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    layer.position = CGPointMake(boardLayer.position.x, boardLayer.position.y);
    layer.sublayerTransform = CATransform3DIdentity;
    layer.name = @"imageLayer";
    layer.borderWidth = 1.0f;
    layer.cornerRadius = 20.0f;
    layer.anchorPointZ = -300.f;
    layer.masksToBounds = YES;
    [boardLayer addSublayer:layer];
    
    CATextLayer *dateLayer = [CATextLayer layer];
    dateLayer.frame = CGRectMake(50, 10, self.frame.size.width - 100, 50);
    dateLayer.alignmentMode = kCAAlignmentCenter;
    dateLayer.name = @"dateLayer";
    dateLayer.font = (__bridge CFTypeRef)([UIFont fontWithName:@"GillSans-Italic" size:13].fontName);
    dateLayer.fontSize = 30.0f;
    [boardLayer addSublayer:dateLayer];
    
    CATextLayer *addressLayer = [CATextLayer layer];
    addressLayer.frame = CGRectMake(40, self.frame.size.height - 30, self.frame.size.width - 80, 30);
    addressLayer.alignmentMode = kCAAlignmentCenter;
    addressLayer.name = @"addressLayer";
    addressLayer.font = (__bridge CFTypeRef)([UIFont fontWithName:@"GillSans-Italic" size:13].fontName);
    addressLayer.fontSize = 15.0f;

    [boardLayer addSublayer:addressLayer];
    return boardLayer;
}

- (void) requestPhoto:(NSNumber*) index {
//    NSLog(@"request index : %d", [index integerValue]);
    @autoreleasepool {
        [alAssetManager getPhotoDataWithAssetURL:[NSURL URLWithString:[self getAlassetUrlStringWithBtnIndex:[index intValue]]]];
    }

}

- (void) requestPhotoWithInt:(NSInteger) index {
    [alAssetManager getPhotoDataWithAssetURL:[NSURL URLWithString:[self getAlassetUrlStringWithBtnIndex:index]]];
}

- (void) drawLayerWithPhotoModel:(PhotoModel*)model {
    NSArray *timeList = [[[model time] description] componentsSeparatedByString:@" "];
    NSArray *dateList = [[timeList objectAtIndex:0] componentsSeparatedByString:@":"];
    NSString *date = [dateList componentsJoinedByString:@"."];
    
    NSArray *hourList = [[timeList objectAtIndex:1] componentsSeparatedByString:@":"];
    NSString *time = [NSString stringWithFormat:@"%@ %@:%@",date,[hourList objectAtIndex:0],[hourList objectAtIndex:1]];
    time = [time stringByReplacingOccurrencesOfString:@"-" withString:@"."];
    currentLayer.name = [model assetUrl];
    for (CATextLayer *layer in [currentLayer sublayers]) {
        if ([layer.name isEqualToString:@"dateLayer"]) {
            layer.string = time;
        } else if ([layer.name isEqualToString:@"imageLayer"]) {
            layer.contents = (id) [model image].CGImage;
        } else if ([layer.name isEqualToString:@"addressLayer"]) {
            layer.string = [model address];
        }
    }
}

- (void) drawImage:(PhotoModel *) model {
    [self drawLayerWithPhotoModel:model];
    isMoving = NO;
}

- (void) didFinishLoadPhotoModel:(PhotoModel *)model {
    if (isTap) {
        [self performSelectorOnMainThread:@selector(viewLargeImage:) withObject:model waitUntilDone:NO];
    } else if (isInit) {
        [self drawLayerWithPhotoModel:model];
        [self makeLayerList];
    } else {
        [self performSelectorOnMainThread:@selector(drawImage:) withObject:model waitUntilDone:NO];
    }
}

- (void) makeTextToCurrentView {
//    NSLog(@"currentIndex : %d name : %@",currentIndex, [[_layerList objectAtIndex:centerIndex] name]);
//    [_titleLabel setText:[[_layerList objectAtIndex:centerIndex] name]];
}

- (void) moveRight {
    if (currentIndex == 0 || isMoving) {
        return;
    }
    isMoving = YES;
    [[_layerList objectAtIndex:rightIndex] setPosition:twoRightPoint];
    [[_layerList objectAtIndex:centerIndex] setPosition:rightPoint];
    [[_layerList objectAtIndex:leftIndex] setPosition:centerPoint];
    
    if (currentIndex != 1) {
        [[_layerList objectAtIndex:twoLeftIndex] setPosition:leftPoint];
    }
    
    CALayer *twoRightLayer = [_layerList objectAtIndex:twoRightIndex];
    [twoRightLayer removeFromSuperlayer];
    [_layerList removeObject:twoRightLayer];
    
    currentLayer = [self makeLayer];
    [_layerList insertObject:currentLayer atIndex:twoLeftIndex];
    [mainLayer addSublayer:[_layerList objectAtIndex:twoLeftIndex]];
    currentIndex--;
    [self makeTextToCurrentView];
//    NSLog(@"right currentIndex: %d", currentIndex);
    if (currentIndex <= 1) {
        isMoving = NO;
        currentLayer.position = CGPointMake(currentLayer.position.x, -400);
        return;
    }
    [self performSelectorInBackground:@selector(requestPhoto:) withObject:[NSNumber numberWithInt:currentIndex-2]];
    [[_layerList objectAtIndex:twoLeftIndex] setPosition:twoLeftPoint];

}



- (void) moveLeft {
    if (currentIndex == [_btnIndexList count] -1 || isMoving) {
        return;
    }
    isMoving = YES;
    [[_layerList objectAtIndex:leftIndex] setPosition:twoLeftPoint];
    [[_layerList objectAtIndex:centerIndex] setPosition:leftPoint];
    [[_layerList objectAtIndex:rightIndex] setPosition:centerPoint];
    
    if (currentIndex != [_btnIndexList count] -2) {
        [[_layerList objectAtIndex:twoRightIndex] setPosition:rightPoint];
    }
    
    CALayer *towLeftLayer = [_layerList objectAtIndex:twoLeftIndex];
    [towLeftLayer removeFromSuperlayer];
    [_layerList removeObject:towLeftLayer];
    
    
    currentLayer = [self makeLayer];
    [_layerList addObject:currentLayer];
    [mainLayer addSublayer:[_layerList objectAtIndex:twoRightIndex]];
    currentIndex++;
    [self makeTextToCurrentView];
    
    
    if (currentIndex >= [_btnIndexList count] -2) {
        isMoving = NO;
        currentLayer.position = CGPointMake(currentLayer.position.x, -400);
        return;
    }
    
    [self performSelectorInBackground:@selector(requestPhoto:) withObject:[NSNumber numberWithInt:currentIndex+2]];
    [[_layerList objectAtIndex:twoRightIndex] setPosition:twoRightPoint];    
}

- (void) handlePan:(UIPanGestureRecognizer *) recognizer {
    if (isInit) {
        return;
    }
    [CATransaction setDisableActions:NO];
    [CATransaction setValue:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear] forKey:kCATransactionAnimationTimingFunction];
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *) recognizer;
    CGPoint delta = [pan translationInView:pan.view];
    CGPoint velocity = [pan velocityInView:pan.view];

    if (pan.state == UIGestureRecognizerStateBegan) {
        forePoint = CGPointZero;
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        [CATransaction setValue:[NSNumber numberWithFloat:0.01] forKey:kCATransactionAnimationDuration];
        for (CALayer *layer in _layerList) {
            layer.position = CGPointMake(layer.position.x + delta.x - forePoint.x, layer.position.y);
        }
    } else {
        if ((fabs(delta.x) > [[UIScreen mainScreen] applicationFrame].size.width * 0.2 || fabs(velocity.x) > 500 ) && !isMoving) {
            if ((delta.x > 0 || velocity.x > 0) && currentIndex !=0) {
                CGFloat duration = ([[UIScreen mainScreen] bounds].size.width - [[_layerList objectAtIndex:leftIndex] position].x) / fabs(velocity.x * 0.5);
                [CATransaction setValue:[NSNumber numberWithFloat:MIN(duration, 0.05)] forKey:kCATransactionAnimationDuration];
                [self moveRight];
            } else if((delta.x < 0 || velocity.x < 0) && currentIndex != [_btnIndexList count] -1){
                CGFloat duration = ([[_layerList objectAtIndex:rightIndex] position].x ) / fabs(velocity.x * 0.5);
                [CATransaction setValue:[NSNumber numberWithFloat:MIN(duration, 0.05)] forKey:kCATransactionAnimationDuration];
                [self moveLeft];
            } else {
                [[_layerList objectAtIndex:leftIndex] setPosition:leftPoint];
                [[_layerList objectAtIndex:centerIndex] setPosition:centerPoint];
                [[_layerList objectAtIndex:rightIndex] setPosition:rightPoint];                
            }
        } else {
            [[_layerList objectAtIndex:leftIndex] setPosition:leftPoint];
            [[_layerList objectAtIndex:centerIndex] setPosition:centerPoint];
            [[_layerList objectAtIndex:rightIndex] setPosition:rightPoint];
        }
    }
    forePoint = delta;
}

- (void) viewLargeImage:(PhotoModel *) model {
    imageView = [[DetailImageView alloc] initWithFrame:self.frame withImage:[model fullImage]];
    [self addSubview:imageView];
}
- (void) initPan {
    isTap = NO;
    [self addGestureRecognizer:panRecognizer];
}

- (void) handleTap:(UITapGestureRecognizer *)recognizer {
    if (isInit) {
        return;
    }
    if (isTap) {
        if (imageView) {
            [imageView removeFromSuperview];
            imageView =nil;
            [self performSelector:@selector(initPan) withObject:nil afterDelay:0.1];
        }
        return;
    }
    [self removeGestureRecognizer:panRecognizer];
    isTap = YES;
    [self performSelectorInBackground:@selector(requestPhoto:) withObject:[NSNumber numberWithInt:currentIndex]];
    
//    [mainLayer addSublayer:[_layerList objectAtIndex:centerIndex]];
//    
//    CALayer *aniLayer = nil;
//    for (CATextLayer *layer in [[_layerList objectAtIndex:centerIndex] sublayers]) {
//        if ([layer.name isEqualToString:@"imageLayer"]) {
//            aniLayer = layer;
//        }
//    }
//    
//    [CATransaction begin];
//    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//    scaleAnimation.toValue = [NSNumber numberWithFloat:0.8f];
//    scaleAnimation.duration = 0.1;
//    scaleAnimation.removedOnCompletion = NO;
//    scaleAnimation.fillMode = kCAFillModeForwards;
//    [CATransaction setCompletionBlock:^(){
//        [aniLayer removeAllAnimations];
//    }];
//    [aniLayer addAnimation:scaleAnimation forKey:@"scale"];
//    [CATransaction commit];
    
}

@end
