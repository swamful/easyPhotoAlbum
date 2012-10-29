//
//  PhotoGalleryView.h
//  PhotoAlbum
//
//  Created by 승필 백 on 12. 10. 15..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIConstans.h"

@protocol PhotoGallertViewDelegate;

@interface PhotoGalleryView : UIView <UIGestureRecognizerDelegate>{
    id<PhotoGallertViewDelegate> _delegate;
    NSMutableArray *_mainBoardList;

    CALayer *_lastLayer;
    
    BOOL isAnimating;
    
    CGPoint forePoint;

    CGFloat rotateAngle;
    BOOL isDiresctionWidth;
    
    NSInteger currentIndex;
    NSInteger columnCount;
    CGFloat anchorPotinZ;
    CGFloat m34;
    
    CGFloat firstPointY;
    CGFloat heightMoveThreshold;
    
    BOOL isSliding;
    float currentScale;
}
@property (nonatomic) id<PhotoGallertViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame withDataList:(NSArray *) dataList withTotalCount:(NSInteger) totalCount;

@end

@protocol PhotoGallertViewDelegate <NSObject>
- (void) closeGalleryView;

@end