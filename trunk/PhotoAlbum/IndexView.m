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
        [self initLayerwithImageDataList:allLayerList];
    }
    return self;
}

- (void) initLayerwithImageDataList:(NSArray *)allLayerList {

    NSInteger thumbSize = 40;
    NSInteger thumbMargin = 2;

    UIScrollView *_mainScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _mainScroll.showsHorizontalScrollIndicator = NO;
    _mainScroll.showsVerticalScrollIndicator = NO;
    _mainScroll.alwaysBounceHorizontal = YES;
    [self addSubview:_mainScroll];
    

    NSLog(@"list count : %d", [allLayerList count]);
    CGFloat lastWidth = 0;

    
    
    for (NSDictionary *dic in allLayerList) {
        NSString *key = [[dic allKeys] objectAtIndex:0];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(lastWidth, 50, (([[dic objectForKey:key] count] -1) / 8) * (thumbMargin + thumbSize + 5) + (thumbMargin + thumbSize + 5), (thumbMargin + thumbSize) *7)];
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
        
        UIGraphicsBeginImageContext(view.layer.bounds.size);
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *oldImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [[UIScreen mainScreen] scale] > 1) {
            CALayer *reflectionLayer = [CALayer layer];
            reflectionLayer.contents = (id)oldImage.CGImage;
            reflectionLayer.frame = CGRectMake(15, view.frame.size.height+25, view.frame.size.width, view.frame.size.height);
            reflectionLayer.opacity = 0.7;
            // Transform X by 180 degrees
            [reflectionLayer setValue:[NSNumber numberWithFloat:DEGREES_TO_RADIANS(215)] forKeyPath:@"transform.rotation.x"];
            [reflectionLayer setValue:[NSNumber numberWithFloat:DEGREES_TO_RADIANS(10)] forKeyPath:@"transform.rotation.y"];
            [view.layer addSublayer:reflectionLayer];
    
            
            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
            gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor],(id)[[UIColor whiteColor] CGColor], nil];
            gradientLayer.startPoint = CGPointMake(0.5, 0.0);
            gradientLayer.endPoint = CGPointMake(0.5, 0.7);
            gradientLayer.bounds = reflectionLayer.bounds;
            gradientLayer.position = CGPointMake(reflectionLayer.bounds.size.width / 2 , reflectionLayer.bounds.size.height * 0.65);
            // Add gradient layer as a mask
            reflectionLayer.mask = gradientLayer;
        }
        
        lastWidth = (([[dic objectForKey:key] count] -1) / 7) * (thumbMargin + thumbSize) + (thumbMargin + thumbSize + 5) + lastWidth;
        _mainScroll.contentSize = CGSizeMake(lastWidth + thumbMargin, self.frame.size.height);
    }
    CALayer *lineLayer = [CALayer layer];
    lineLayer.backgroundColor = [UIColor darkGrayColor].CGColor;
    lineLayer.opacity = 0.5;
    lineLayer.frame = CGRectMake(0, (thumbMargin + thumbSize) *7 + 103, _mainScroll.contentSize.width, 1);
    [_mainScroll.layer addSublayer:lineLayer];
}


@end
