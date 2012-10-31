//
//  DetailImageView.h
//  PhotoAlbum
//
//  Created by 승필 백 on 12. 10. 25..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailImageView : UIView <UIScrollViewDelegate> {
    UIImageView *imageView;
}

- (id)initWithFrame:(CGRect)frame withImage:(UIImage *) image withOrientation:(UIImageOrientation) orientation;
@end
