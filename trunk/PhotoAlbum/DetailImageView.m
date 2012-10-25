//
//  DetailImageView.m
//  PhotoAlbum
//
//  Created by 승필 백 on 12. 10. 25..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import "DetailImageView.h"

@implementation DetailImageView

- (id)initWithFrame:(CGRect)frame withImage:(UIImage *) image
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:scrollView];
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.userInteractionEnabled = YES;
        [scrollView addSubview:imageView];
        
        CGSize imageSize = image.size;
        CGFloat widhRatio = self.frame.size.width / imageSize.width;
        CGFloat heightRatio = self.frame.size.height / imageSize.height;
        CGFloat initialRatio = (widhRatio >heightRatio) ? widhRatio: heightRatio;
        scrollView.delegate = self;
        
        scrollView.minimumZoomScale = initialRatio;
        scrollView.maximumZoomScale = 1.0f;
        scrollView.contentSize = imageSize;
        scrollView.zoomScale = initialRatio;
    }
    return self;
}

- (UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
