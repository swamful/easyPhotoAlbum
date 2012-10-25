//
//  IndexView.h
//  PhotoAlbum
//
//  Created by Seungpill Baik on 12. 10. 21..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IndexView : UIView <UIScrollViewDelegate> {
    NSMutableArray *_mainBoardList;
    CGFloat m34;
    
    UIView *_bottomView;
    CGPoint forePoint;
    UIScrollView *_mainScroll;
    
    CALayer *_slideLayer;
    BOOL isPanning;
}

- (id)initWithFrame:(CGRect)frame withAllLayerList:(NSArray*) allLayerList;
@end
