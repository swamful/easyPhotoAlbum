//
//  IndexView.h
//  PhotoAlbum
//
//  Created by Seungpill Baik on 12. 10. 21..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol IndexViewDelegate;

@interface IndexView : UIView <UIScrollViewDelegate> {
    id<IndexViewDelegate> _delegate;
    NSMutableArray *_mainBoardList;
    CGFloat m34;
    
    UIView *_bottomView;
    CGPoint forePoint;
    UIScrollView *_mainScroll;
    
    CALayer *_slideLayer;
    BOOL isPanning;
    BOOL isSlideRegisterMode;
}
@property (nonatomic) id<IndexViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame withAllLayerList:(NSArray*) allLayerList;
- (void)changeSlideSetEnable:(BOOL) enable;
@end
@protocol IndexViewDelegate <NSObject>
- (void) changeToSlideView;
- (void) changeToRandomView;
- (void) changeSlideSelectMode;
@end