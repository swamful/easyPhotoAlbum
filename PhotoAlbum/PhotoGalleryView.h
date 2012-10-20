//
//  PhotoGalleryView.h
//  PhotoAlbum
//
//  Created by 승필 백 on 12. 10. 15..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TOTALVIEW = 0,
    INDEXVIEW
} VIEWTYPE;


@interface PhotoGalleryView : UIView <UIGestureRecognizerDelegate>{
    UIPanGestureRecognizer* panRecognizer;
    NSMutableArray *_mainBoardList;
    NSMutableArray *_allLayerList;
    CALayer *_lastLayer;
    
    BOOL isAnimating;
    CGFloat lastWidth;
    
    CGPoint forePoint;
    UIScrollView *_mainScroll;
    NSInteger groupCount;
    
    
    CGFloat rotateAngle;
    BOOL isDiresctionWidth;
    
    NSInteger currentIndex;
    NSInteger columnCount;
    CGFloat anchorPotinZ;
    CGFloat m34;
    
    CGFloat firstPointY;
    CGFloat heightMoveThreshold;
    
    VIEWTYPE showViewType;
    CGRect initTotalViewSelfFrame;
}

- (void) initLayerwithImageDataList:(NSArray*) dataList withCount:(NSInteger) count;


@end
