//
//  SlideShowView.m
//  PhotoAlbum
//
//  Created by 승필 백 on 12. 10. 26..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import "SlideShowView.h"
#define zGap 8000
@implementation SlideShowView
- (CATransform3D) getTransForm3DIdentity {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1 / 3000.0f;
    return transform;
}
- (id)initWithFrame:(CGRect)frame slideList:(NSArray*) list
{
    self = [super initWithFrame:frame];
    if (self) {
        _showLayerList = [[NSMutableArray alloc] init];
        assetsLibrary = [[ALAssetsLibrary alloc] init];
        currentIndex = 0;
        [CATransaction setDisableActions:YES];
        for (int i = 0 ; i < 15 ; i++) {
            CALayer *selectedLayer = [[list objectAtIndex:i] layer];
            CALayer *showLayer = [CALayer layer];
            showLayer.name = selectedLayer.name;
            showLayer.transform = [self getTransForm3DIdentity];
            showLayer.bounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            showLayer.position = CGPointMake(self.center.x, self.center.y);
            showLayer.anchorPointZ = 1000.0f;
            [self.layer addSublayer:showLayer];
            [_showLayerList addObject:showLayer];
            if (i < 3) {
                [self imageIndexWithDQueueLayer:showLayer];
            }
            showLayer.opacity = 0.0f;
        }

        [CATransaction begin];
        CABasicAnimation *backgroundAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        backgroundAnimation.fromValue = (id)[UIColor clearColor].CGColor;
        backgroundAnimation.toValue = (id)[UIColor whiteColor].CGColor;
        backgroundAnimation.duration = 0.8f;
        backgroundAnimation.autoreverses = YES;
        backgroundAnimation.fillMode = kCAFillModeForwards;
        backgroundAnimation.removedOnCompletion = NO;
        [CATransaction setCompletionBlock:^() {
            [self beginShow];
            timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(beginShow) userInfo:nil repeats:YES];
        }];
        [self.layer addAnimation:backgroundAnimation forKey:@"backgroundColor"];
        [CATransaction commit];
        
    }
    return self;
}

- (void) showInvalidate {
    [timer invalidate];
}

- (void) dealloc {
    NSLog(@"slideshow view dealloc");
}

- (void) beginShow {
    if (currentIndex == 0) {
        for (int i = 1 ; i < [_showLayerList count] ; i++) {
            CALayer *showLayer = [_showLayerList objectAtIndex:i];
            showLayer.transform = CATransform3DTranslate(showLayer.transform, 0, 0, - i * zGap);
            showLayer.position = CGPointMake((arc4random() % ((NSInteger)self.frame.size.width)) , (arc4random() % ((NSInteger)self.frame.size.height)));
        }
    }
    
//    NSLog(@"curIndex : %d", currentIndex);
    CALayer *curLayer = [_showLayerList objectAtIndex:currentIndex];
    curLayer.opacity = 1.0f;
    CGFloat deltax = self.center.x - curLayer.position.x;
    CGFloat deltay = self.center.y - curLayer.position.y;

    for (int i =0 ; i < [_showLayerList count]; i ++) {
        CALayer *layer = [_showLayerList objectAtIndex:i];
        if (i != currentIndex) {
            layer.opacity = 0.5;
        }
        
        if (i < currentIndex - 5) {
            layer.contents = nil;
        } else if ( (i < currentIndex + 10 || ( currentIndex == [_showLayerList count] -1 && i ==0)) && layer.contents == nil){
            [CATransaction setDisableActions:YES];
            [self imageIndexWithDQueueLayer:layer];
        }
        
        [CATransaction setDisableActions:NO];
        [CATransaction setValue:[NSNumber numberWithFloat:2.0f] forKey:kCATransactionAnimationDuration];
        layer.position = CGPointMake(layer.position.x + deltax, layer.position.y + deltay);
        [layer setValue:[NSNumber numberWithFloat:(currentIndex - i) * zGap] forKeyPath:@"transform.translation.z"];
    }
    currentIndex = (currentIndex + 1) % [_showLayerList count];
    if (currentIndex == 0) {
        isInit = NO;
    }
}

- (void) imageIndexWithDQueueLayer:(CALayer *)layer {
    dqueue = dispatch_queue_create("getImage", NULL);
    dispatch_async(dqueue, ^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *assetUrl = layer.name;
                @autoreleasepool {
                    [assetsLibrary assetForURL:[NSURL URLWithString:assetUrl] resultBlock:^(ALAsset *photo){
                        if( photo ){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                layer.contents = (id) [UIImage imageWithCGImage:[[photo defaultRepresentation] fullScreenImage]].CGImage;
//                                NSLog(@"layer :%@", layer.name);
                            });
                            photo = nil;
                        }
                    } failureBlock:^(NSError *error) {
                        NSLog(@"error : %@", error);
                    }];
                }
            });

    });
    dispatch_release(dqueue);
}
@end
