//
//  DetailedView.m
//  PhotoAlbum
//
//  Created by 승필 백 on 12. 10. 22..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import "DetailedView.h"
#define centerIndex 1
#define leftIndex 0
#define rightIndex 2

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

        mainLayer = [CALayer layer];
        mainLayer.frame = self.frame;
        [self.layer addSublayer:mainLayer];
        
        [_layerList addObject:[self makeLayer]];
        [_layerList addObject:[self makeLayer]];
        [_layerList addObject:[self makeLayer]];
        
        [mainLayer addSublayer:[_layerList objectAtIndex:leftIndex]];
        [mainLayer addSublayer:[_layerList objectAtIndex:centerIndex]];
        [mainLayer addSublayer:[_layerList objectAtIndex:rightIndex]];
        
        leftPoint = CGPointMake(self.center.x - (self.frame.size.width * 0.85), self.center.y);
        centerPoint = CGPointMake(self.center.x, self.center.y);
        rightPoint = CGPointMake(self.center.x + (self.frame.size.width * 0.85), self.center.y);
        
        [[_layerList objectAtIndex:leftIndex] setPosition:leftPoint];
        [[_layerList objectAtIndex:centerIndex] setPosition:centerPoint];
        [[_layerList objectAtIndex:rightIndex] setPosition:rightPoint];
        
        alAssetManager = [ALAssetsManager getSharedInstance];
        alAssetManager.delegate = self;
        isInit = YES;
        [self makeLayerList];
        
        UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        panRecognizer.minimumNumberOfTouches = 1;
        [self addGestureRecognizer:panRecognizer];
        
    }
    [CATransaction setDisableActions:NO];
    return self;
}

- (void) makeLayerList {
    if (currentLayer == [_layerList objectAtIndex:centerIndex]) {
        currentLayer = [_layerList objectAtIndex:leftIndex];
        
        [self requestPhotoWithInt:currentIndex-1];
    } else if (currentLayer == [_layerList objectAtIndex:leftIndex]) {
        currentLayer = [_layerList objectAtIndex:rightIndex];
        [self requestPhotoWithInt:currentIndex+1];
    } else if (currentLayer == [_layerList objectAtIndex:rightIndex]){
        isInit = NO;
        currentLayer = nil;
        return;
    } else {
        currentLayer = [_layerList objectAtIndex:centerIndex];
        [self requestPhotoWithInt:currentIndex];
    }
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
    @autoreleasepool {
        [alAssetManager getPhotoDataWithAssetURL:[NSURL URLWithString:[self getAlassetUrlStringWithBtnIndex:[index intValue]]]];
    }

}

- (void) requestPhotoWithInt:(NSInteger) index {
    [alAssetManager getPhotoDataWithAssetURL:[NSURL URLWithString:[self getAlassetUrlStringWithBtnIndex:index]]];
}

- (void) drawImage:(PhotoModel *) model {
    currentLayer.contents = (id) [model image].CGImage;
    currentLayer.name = [model assetUrl];
}

- (void) didFinishLoadPhotoModel:(PhotoModel *)model {
    if (isInit) {
        currentLayer.contents = (id) [model image].CGImage;
        currentLayer.name = [model assetUrl];
        [self makeLayerList];
    } else {
        [self performSelectorOnMainThread:@selector(drawImage:) withObject:model waitUntilDone:NO];
    }
}

- (void) moveRight {
    currentIndex--;
    currentLayer = [self makeLayer];
    [self performSelectorInBackground:@selector(requestPhoto:) withObject:[NSNumber numberWithInt:currentIndex]];
    [[_layerList objectAtIndex:centerIndex] setPosition:rightPoint];
    [[_layerList objectAtIndex:leftIndex] setPosition:centerPoint];
    CALayer *rightLayer = [_layerList objectAtIndex:rightIndex];
    rightLayer.position = CGPointMake(self.frame.size.width  *3, rightLayer.position.y);
    [rightLayer removeFromSuperlayer];
    [_layerList removeObject:rightLayer];
    
    [_layerList insertObject:currentLayer atIndex:0];
    [[_layerList objectAtIndex:leftIndex] setPosition:leftPoint];
    [mainLayer addSublayer:[_layerList objectAtIndex:leftIndex]];
}

- (void) moveLeft {
    currentIndex++;
    currentLayer = [self makeLayer];
    [self performSelectorInBackground:@selector(requestPhoto:) withObject:[NSNumber numberWithInt:currentIndex]];
    [[_layerList objectAtIndex:centerIndex] setPosition:leftPoint];
    [[_layerList objectAtIndex:rightIndex] setPosition:centerPoint];
    CALayer *leftLayer = [_layerList objectAtIndex:leftIndex];
    leftLayer.position = CGPointMake(-self.frame.size.width  *3, leftLayer.position.y);
    [leftLayer removeFromSuperlayer];
    [_layerList removeObject:leftLayer];
    
    [_layerList addObject:currentLayer];
    [[_layerList objectAtIndex:rightIndex] setPosition:rightPoint];
    [mainLayer addSublayer:[_layerList objectAtIndex:rightIndex]];
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
        if (fabs(delta.x) > [[UIScreen mainScreen] applicationFrame].size.width * 0.2) {
            if (delta.x > 0 && currentIndex !=0) {
                CGFloat duration = ([[UIScreen mainScreen] bounds].size.width - [[_layerList objectAtIndex:leftIndex] position].x) / fabs(velocity.x * 0.5);
                [CATransaction setValue:[NSNumber numberWithFloat:MIN(duration, 0.03)] forKey:kCATransactionAnimationDuration];
                [self moveRight];
            } else if(currentIndex != [_btnIndexList count] -1){
                CGFloat duration = ([[_layerList objectAtIndex:rightIndex] position].x ) / fabs(velocity.x * 0.5);
                [CATransaction setValue:[NSNumber numberWithFloat:MIN(duration, 0.03)] forKey:kCATransactionAnimationDuration];
                [self moveLeft];
            }
        }
        [[_layerList objectAtIndex:leftIndex] setPosition:leftPoint];
        [[_layerList objectAtIndex:centerIndex] setPosition:centerPoint];
        [[_layerList objectAtIndex:rightIndex] setPosition:rightPoint];
    }
    forePoint = delta;
    //    NSLog(@"forePoint : %@ delta : %@", NSStringFromCGPoint(forePoint), NSStringFromCGPoint(delta));
    

}

@end
