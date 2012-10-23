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
        
        [[_layerList objectAtIndex:twoLeftIndex] setPosition:leftPoint];
        [[_layerList objectAtIndex:twoRightIndex] setPosition:leftPoint];
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
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 60)];
        _titleLabel.backgroundColor = [UIColor grayColor];
        _titleLabel.alpha = 0.5;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = UITextAlignmentCenter;
        _titleLabel.font = [UIFont fontWithName:@"GillSans-Italic" size:30];
        [self addSubview:_titleLabel];
        
        
        UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        panRecognizer.minimumNumberOfTouches = 1;
        [self addGestureRecognizer:panRecognizer];
        
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
    CALayer *layer = [CALayer layer];
    layer.transform = [self getViewTransForm3DIdentity];
    layer.transform = CATransform3DScale(layer.transform, 0.7, 0.7,0.7);
    layer.bounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    layer.borderWidth = 1.0f;
    layer.cornerRadius = 20.0f;
    layer.anchorPointZ = -300.f;
    layer.masksToBounds = YES;
    return layer;
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

- (void) drawImage:(PhotoModel *) model {
    currentLayer.contents = (id) [model image].CGImage;
    NSArray *timeList = [[[model time] description] componentsSeparatedByString:@" "];
    NSArray *dateList = [[timeList objectAtIndex:0] componentsSeparatedByString:@":"];
    NSString *date = [dateList componentsJoinedByString:@"."];
    
    NSArray *hourList = [[timeList objectAtIndex:1] componentsSeparatedByString:@":"];
    NSString *time = [NSString stringWithFormat:@"%@ %@:%@",date,[hourList objectAtIndex:0],[hourList objectAtIndex:1]];
    currentLayer.name = time;
    isMoving = NO;
}

- (void) didFinishLoadPhotoModel:(PhotoModel *)model {
    if (isInit) {
        currentLayer.contents = (id) [model image].CGImage;
        NSArray *timeList = [[[model time] description] componentsSeparatedByString:@" "];
        NSArray *dateList = [[timeList objectAtIndex:0] componentsSeparatedByString:@":"];
        NSString *date = [dateList componentsJoinedByString:@"."];
        
        NSArray *hourList = [[timeList objectAtIndex:1] componentsSeparatedByString:@":"];
        NSString *time = [NSString stringWithFormat:@"%@ %@:%@",date,[hourList objectAtIndex:0],[hourList objectAtIndex:1]];
        currentLayer.name = time;
        [self makeLayerList];
    } else {
        [self performSelectorOnMainThread:@selector(drawImage:) withObject:model waitUntilDone:NO];
    }
}

- (void) makeTextToCurrentView {
//    NSLog(@"currentIndex : %d name : %@",currentIndex, [[_layerList objectAtIndex:centerIndex] name]);
    [_titleLabel setText:[[_layerList objectAtIndex:centerIndex] name]];
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
        if (fabs(delta.x) > [[UIScreen mainScreen] applicationFrame].size.width * 0.2 && !isMoving) {
            if (delta.x > 0 && currentIndex !=0) {
                CGFloat duration = ([[UIScreen mainScreen] bounds].size.width - [[_layerList objectAtIndex:leftIndex] position].x) / fabs(velocity.x * 0.5);
                [CATransaction setValue:[NSNumber numberWithFloat:MIN(duration, 0.03)] forKey:kCATransactionAnimationDuration];
                [self moveRight];
            } else if(delta.x < 0 && currentIndex != [_btnIndexList count] -1){
                CGFloat duration = ([[_layerList objectAtIndex:rightIndex] position].x ) / fabs(velocity.x * 0.5);
                [CATransaction setValue:[NSNumber numberWithFloat:MIN(duration, 0.03)] forKey:kCATransactionAnimationDuration];
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

@end