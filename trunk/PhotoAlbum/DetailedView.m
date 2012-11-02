//
//  DetailedView.m
//  PhotoAlbum
//
//  Created by 승필 백 on 12. 10. 22..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import "DetailedView.h"
#import "JSON.h"

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
@synthesize currentIndex;
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
        isInit = YES;
        currentIndex = index;
        _btnIndexList = btnIndexList;
        indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        indicator.center = self.center;
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [self addSubview:indicator];

        
        _layerList = [[NSMutableArray alloc] init];
        requestImageQueue = [[NSMutableArray alloc] init];

        assetsLibrary = [[ALAssetsLibrary alloc] init];
        s = dispatch_semaphore_create(5);
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
        
        currentLayer = [_layerList objectAtIndex:centerIndex];
        [self imageIndexWithDQueue:index withLayer:currentLayer];
        
        leftPoint = CGPointMake(self.center.x - (self.frame.size.width * 0.85), self.center.y);
        centerPoint = CGPointMake(self.center.x, self.center.y);
        rightPoint = CGPointMake(self.center.x + (self.frame.size.width * 0.85), self.center.y);
        twoLeftPoint = CGPointMake(self.center.x - (self.frame.size.width * 0.85) * 2, self.center.y);
        twoRightPoint = CGPointMake(self.center.x + (self.frame.size.width * 0.85) * 2, self.center.y);
        
        NSNumber *leftNumber = [NSNumber numberWithInt:leftIndex];
        NSNumber *twoLeftNumber = [NSNumber numberWithInt:twoLeftIndex];
        NSNumber *rightNumber = [NSNumber numberWithInt:rightIndex];
        NSNumber *twoRightNumber = [NSNumber numberWithInt:twoRightIndex];
        
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

- (void) dealloc {
    NSLog(@"detail view dealloc");
    dispatch_release(s);
}

- (void) makeInitLayerList {
    for (NSNumber *index in requestImageQueue) {
        currentLayer = [_layerList objectAtIndex:[index intValue]];
        [self imageIndexWithDQueue:currentIndex + ([index intValue] -centerIndex) withLayer:currentLayer];
    }
    
    currentLayer = nil;
    return;
}

- (CALayer*) makeLayer {
    CALayer *boardLayer = [CALayer layer];
    boardLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    CALayer *layer = [CALayer layer];
    layer.transform = [self getViewTransForm3DIdentity];
    layer.transform = CATransform3DScale(layer.transform, 0.7, 0.7,0.7);
    layer.bounds = CGRectMake(0, 0, 320, 480);
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
    addressLayer.fontSize = 11.0f;

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
        } if ([layer.name isEqualToString:@"addressLayer"]) {
            if ([model hasGps]) {
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:model, @"model", layer,@"layer", nil];
                [self performSelectorInBackground:@selector(makeAddress:) withObject:dic];                
            }
        }
    }
    
}

- (void) makeAddress:(NSDictionary *) data{
    @autoreleasepool {
        CLLocationCoordinate2D gps = [[data objectForKey:@"model"] coordinate];
        CATextLayer *layer = [data objectForKey:@"layer"];
        NSString *json = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.co.kr/maps/geo?q=%f,%f", gps.latitude, gps.longitude]]
                                                  encoding:NSUTF8StringEncoding error:nil];
        NSDictionary *dic = [json JSONValue];
        //            NSLog(@"address : %@", [[[dic objectForKey:@"Placemark"] lastObject] objectForKey:@"address"]);
        NSString *address = [[[dic objectForKey:@"Placemark"] lastObject] objectForKey:@"address"];
        address = [address stringByReplacingOccurrencesOfString:@"대한민국" withString:@""];
        layer.string = address;
    }
}


- (void) drawImage:(PhotoModel *) model {
    [self drawLayerWithPhotoModel:model];
}

- (void) didFinishLoadPhotoModel:(PhotoModel *)model {
    if (isTap) {
        [self viewLargeImage:model];
    }
}

- (void) moveRight {
    
    if (currentIndex == 0) {
        return;
    }
//    isMoving = YES;
    [[_layerList objectAtIndex:rightIndex] setPosition:twoRightPoint];
    [[_layerList objectAtIndex:centerIndex] setPosition:rightPoint];
    [[_layerList objectAtIndex:leftIndex] setPosition:centerPoint];
    
    if (currentIndex != 1) {
        [[_layerList objectAtIndex:twoLeftIndex] setPosition:leftPoint];
    }
    [CATransaction setDisableActions:YES];
    currentLayer = [_layerList objectAtIndex:twoRightIndex];
    currentLayer.opacity = 0.0f;
    [_layerList removeObject:currentLayer];
    [_layerList insertObject:currentLayer atIndex:twoLeftIndex];
    
    currentIndex--;
//    NSLog(@"right currentIndex: %d", currentIndex);
    if (currentIndex <= 1) {
        currentLayer.position = CGPointMake(currentLayer.position.x, -400);
        return;
    }
    [currentLayer setPosition:twoLeftPoint];
    [self imageIndexWithDQueue:(currentIndex -2) withLayer:currentLayer];
}

- (void) imageIndexWithDQueue:(NSInteger) index withLayer:(CALayer *)curLayer{
    dqueue = dispatch_queue_create("getImage", NULL);
    dispatch_async(dqueue, ^{
        dispatch_semaphore_wait(s, DISPATCH_TIME_FOREVER);
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *assetUrl = [self getAlassetUrlStringWithBtnIndex:index];
                @autoreleasepool {
                    [assetsLibrary assetForURL:[NSURL URLWithString:assetUrl] resultBlock:^(ALAsset *photo){
                    if( photo ){
                        curLayer.opacity = 1.0f;
                        NSDate *timeStamp = [[[[photo defaultRepresentation] metadata] objectForKey:@"{Exif}"] objectForKey:@"DateTimeOriginal"];
                        if (!timeStamp) {
                            timeStamp = [photo valueForProperty:ALAssetPropertyDate];
                            timeStamp = [timeStamp dateByAddingTimeInterval:60*60*9];
                        }
                        CLLocation *location = [photo valueForProperty:ALAssetPropertyLocation];
                        NSString *address = @"";
                        if (location) {
                            CLLocationCoordinate2D gps = [location coordinate];
                            NSString *json = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.co.kr/maps/geo?q=%f,%f", gps.latitude, gps.longitude]]
                                                                  encoding:NSUTF8StringEncoding error:nil];
                            NSDictionary *dic = [json JSONValue];
                            address = [[[dic objectForKey:@"Placemark"] lastObject] objectForKey:@"address"];
                            address = [address stringByReplacingOccurrencesOfString:@"대한민국" withString:@""];
                        }
                        
                    
                        NSArray *timeList = [[timeStamp description] componentsSeparatedByString:@" "];
                        NSArray *dateList = [[timeList objectAtIndex:0] componentsSeparatedByString:@":"];
                        NSString *date = [dateList componentsJoinedByString:@"."];
                        curLayer.name = [[[photo defaultRepresentation] url] description];
                        NSArray *hourList = [[timeList objectAtIndex:1] componentsSeparatedByString:@":"];
                        NSString *time = [NSString stringWithFormat:@"%@ %@:%@",date,[hourList objectAtIndex:0],[hourList objectAtIndex:1]];
                        time = [time stringByReplacingOccurrencesOfString:@"-" withString:@"."];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            for (CATextLayer *layer in [curLayer sublayers]) {
                                if ([layer.name isEqualToString:@"dateLayer"]) {
                                    layer.string = time;
                                } else if ([layer.name isEqualToString:@"imageLayer"]) {
                                    UIImage *imageToDisplay =
                                    [UIImage imageWithCGImage:[[photo defaultRepresentation] fullScreenImage]
                                                        scale:1.0
                                                  orientation:[[photo defaultRepresentation] orientation]];
                                    layer.contents = (id) imageToDisplay.CGImage;
                                } if ([layer.name isEqualToString:@"addressLayer"]) {
                                    layer.string = address;
                                }
                            }
                            if (isInit) {
                                isInit = NO;
                                [self makeInitLayerList];
                            }
                        });
                        photo = nil;
                    }
                } failureBlock:^(NSError *error) {
                    NSLog(@"error : %@", error);
                }];
                }
            });
        }
        dispatch_semaphore_signal(s);
    });
    dispatch_release(dqueue);
}



- (void) moveLeft {
    if (currentIndex == [_btnIndexList count] -1) {
        return;
    }
    [[_layerList objectAtIndex:leftIndex] setPosition:twoLeftPoint];
    [[_layerList objectAtIndex:centerIndex] setPosition:leftPoint];
    [[_layerList objectAtIndex:rightIndex] setPosition:centerPoint];
    
    if (currentIndex != [_btnIndexList count] -2) {
        [[_layerList objectAtIndex:twoRightIndex] setPosition:rightPoint];
    }
    [CATransaction setDisableActions:YES];
    currentLayer = [_layerList objectAtIndex:twoLeftIndex];
    currentLayer.opacity = 0.0f;

    [_layerList removeObject:currentLayer];
    [_layerList addObject:currentLayer];

    currentIndex++;    
    
    if (currentIndex >= [_btnIndexList count] -2) {

        currentLayer.position = CGPointMake(currentLayer.position.x, -400);
        return;
    }
//    NSLog(@"left currentIndex:%d", currentIndex);
    [self imageIndexWithDQueue:(currentIndex +2) withLayer:currentLayer];
    [currentLayer setPosition:twoRightPoint];    
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
        [CATransaction setDisableActions:YES];
        for (CALayer *layer in _layerList) {
            layer.position = CGPointMake(layer.position.x + delta.x - forePoint.x, layer.position.y);
        }
    } else {

        if ((fabs(delta.x) > [[UIScreen mainScreen] applicationFrame].size.width * 0.2 || fabs(velocity.x) > 500 )) {
//            [CATransaction setDisableActions:YES];
            if ((delta.x > 0 || velocity.x > 0) && currentIndex !=0) {
                CGFloat duration = ([[UIScreen mainScreen] bounds].size.width - [[_layerList objectAtIndex:leftIndex] position].x) / fabs(velocity.x);
                [CATransaction setValue:[NSNumber numberWithFloat:MIN(duration, 0.25)] forKey:kCATransactionAnimationDuration];
                [self moveRight];
            } else if((delta.x < 0 || velocity.x < 0) && currentIndex != [_btnIndexList count] -1){
                CGFloat duration = ([[_layerList objectAtIndex:rightIndex] position].x ) / fabs(velocity.x);
                [CATransaction setValue:[NSNumber numberWithFloat:MIN(duration, 0.25)] forKey:kCATransactionAnimationDuration];
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
    [indicator stopAnimating];
    UIImageOrientation orientation = (UIImageOrientation)[model orientation];
    imageView = [[DetailImageView alloc] initWithFrame:self.frame withImage:[model fullImage] withOrientation:orientation];
    [self addSubview:imageView];
    isTap = NO;
}

- (void) handleTap:(UITapGestureRecognizer *)recognizer {
    if (isTap) {
        return;
    }

    if (imageView) {
        [imageView removeFromSuperview];
        imageView =nil;
        [self addGestureRecognizer:panRecognizer];
        return;
    }
    [self bringSubviewToFront:indicator];
    [indicator startAnimating];
    
    [self removeGestureRecognizer:panRecognizer];
    isTap = YES;
//    NSLog(@"currentIndex : %d", currentIndex);
    [self requestPhotoWithInt:currentIndex];
}

@end
