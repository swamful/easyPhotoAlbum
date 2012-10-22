//
//  IndexView.h
//  PhotoAlbum
//
//  Created by Seungpill Baik on 12. 10. 21..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IndexView : UIView {
    NSMutableArray *_mainBoardList;
    CGFloat m34;
}

- (id)initWithFrame:(CGRect)frame withAllLayerList:(NSArray*) allLayerList;
@end
