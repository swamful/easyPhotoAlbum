//
//  PhotoGalleryView.h
//  PhotoAlbum
//
//  Created by 승필 백 on 12. 10. 15..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIConstans.h"



@interface PhotoGalleryView : UIView <UIGestureRecognizerDelegate>{
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
}

- (id)initWithFrame:(CGRect)frame withDataList:(NSArray *) dataList withTotalCount:(NSInteger) totalCount;

@end
