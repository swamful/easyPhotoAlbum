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
        
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.frame = CGRectMake(lastWidth + 5, 15, 80, 40);
        textLayer.alignmentMode = kCAAlignmentLeft;
        textLayer.fontSize = 14.0f;
        textLayer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS(- 30), 0, 0, 1);
        textLayer.string = [NSString stringWithFormat:@"%@\n\t(%d)", key,[[dic objectForKey:key] count]];
        [_mainScroll.layer addSublayer:textLayer];
        for (int j = 0 ; j < [[dic objectForKey:key] count] ; j ++) {

            UIButton *btn = [(NSArray*)[dic objectForKey:key] objectAtIndex:j];
            btn.frame = CGRectMake(lastWidth + thumbMargin + (thumbSize + thumbMargin) * (j%2), 50 + thumbMargin + (thumbSize + thumbMargin) * (j/2), thumbSize, thumbSize);
            btn.layer.borderColor = [UIColor grayColor].CGColor;
            btn.layer.borderWidth = 0.5f;

//            [layer setShadowPath:[UIBezierPath bezierPathWithRect:layer.bounds].CGPath];
//            layer.shadowColor = [UIColor whiteColor].CGColor;
//            layer.shadowOpacity = 2.0f;
//            layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
//            layer.shouldRasterize = YES;
//            layer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS(imgAngle[arc4random()%3]), 0, 0, 1);
            [_mainScroll addSubview:btn];



        }

        lastWidth = 10 + thumbSize * 2 + _mainScroll.contentSize.width;
        _mainScroll.contentSize = CGSizeMake(lastWidth, self.frame.size.height);
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _mainScroll.contentSize.width, _mainScroll.contentSize.height)];
        view.backgroundColor = [UIColor blackColor];
        [_mainScroll insertSubview:view atIndex:0];
    }

}


//- (void) initLayerwithImageDataList:(NSArray *)allLayerList {
//    NSInteger sidNum = [allLayerList count] / 10;
//    
//    NSInteger columnCount = [allLayerList count];
//    m34 = -1.0f/ (3000.0f + 400 * sidNum);
//    CGFloat anchorPotinZ = 1000.0f + 100 * sidNum;
//    
//
//    CGFloat rotateAngle = RADIANS_TO_DEGREE(2 * M_PI) / columnCount;
//    NSLog(@"r Angle :%f", rotateAngle);
//    NSInteger thumbSize = 40;
//    NSInteger thumbMargin = 2;
//        
//    NSLog(@"list count : %d", [allLayerList count]);
//    CGFloat lastWidth = 0;
//    
//    for (int i = 0; i <columnCount; i++) {
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(self.center.x - thumbMargin/2, 0, (thumbSize + thumbMargin * 2) * 2, self.frame.size.height)];
//        view.tag = i+1;
//        [self addSubview:view];
//        CALayer *layer = [view layer];
//        layer.transform = [self getTransForm3DIdentity];
//        layer.transform = CATransform3DRotate(layer.transform, DEGREES_TO_RADIANS(rotateAngle * i), 0, 1, 0);
//        layer.anchorPointZ = -anchorPotinZ;
//        [_mainBoardList addObject:layer];
//    }
//    
//    
//    int i=1;
//    for (NSDictionary *dic in allLayerList) {
//        UIView *boardView = [self viewWithTag:i++];
//        
//        NSString *key = [[dic allKeys] objectAtIndex:0];
//        
//        CATextLayer *textLayer = [CATextLayer layer];
//        textLayer.frame = CGRectMake(lastWidth + 5, 15, 80, 40);
//        textLayer.alignmentMode = kCAAlignmentLeft;
//        textLayer.fontSize = 14.0f;
//        textLayer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS(- 30), 0, 0, 1);
//        textLayer.string = [NSString stringWithFormat:@"%@\n\t(%d)", key,[[dic objectForKey:key] count]];
//        [boardView.layer addSublayer:textLayer];
//        for (int j = 0 ; j < [[dic objectForKey:key] count] ; j ++) {
//            
//            UIButton *btn = [(NSArray*)[dic objectForKey:key] objectAtIndex:j];
//            btn.frame = CGRectMake(thumbMargin + (thumbSize + thumbMargin) * (j%2), 50 + thumbMargin + (thumbSize + thumbMargin) * (j/2), thumbSize, thumbSize);
//            btn.layer.borderColor = [UIColor grayColor].CGColor;
//            btn.layer.borderWidth = 0.5f;
//            
//            //            [layer setShadowPath:[UIBezierPath bezierPathWithRect:layer.bounds].CGPath];
//            //            layer.shadowColor = [UIColor whiteColor].CGColor;
//            //            layer.shadowOpacity = 2.0f;
//            //            layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
//            //            layer.shouldRasterize = YES;
//            //            layer.transform = CATransform3DMakeRotation(DEGREES_TO_RADIANS(imgAngle[arc4random()%3]), 0, 0, 1);
//            [boardView addSubview:btn];
//        }
//        
//    }
//    
//}

@end
