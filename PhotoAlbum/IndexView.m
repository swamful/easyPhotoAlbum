//
//  IndexView.m
//  PhotoAlbum
//
//  Created by Seungpill Baik on 12. 10. 21..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import "IndexView.h"

@implementation IndexView

- (id)initWithFrame:(CGRect)frame withAllLayerList:(NSArray*) allLayerList
{
    self = [super initWithFrame:frame];
    if (self) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:scrollView];
        
        
        CGFloat btnMargin = 2.0f;
        CGFloat btnWidth = ([[UIScreen mainScreen] applicationFrame].size.width - btnMargin *3) / 2 ;
        CGFloat btnHeight = 110;
        
        CGFloat layerMargin = 3.0f;
        CGFloat layerSize = (btnWidth - layerMargin*4) / 4;
        
        int i = 0;
        for (NSDictionary *dic in allLayerList) {
            NSString *key = [[dic allKeys] objectAtIndex:0];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = [UIColor grayColor];
            btn.frame = CGRectMake((i % 2) * (btnWidth + btnMargin) + btnMargin, (i++ /2 ) * (btnHeight + btnMargin) + btnMargin, btnWidth, btnHeight);
            [scrollView addSubview:btn];
            scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, btn.frame.origin.y + btn.frame.size.height);
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, btnWidth, 10)];
            titleLabel.backgroundColor =[UIColor clearColor];
            titleLabel.text = key;
            titleLabel.font = [UIFont systemFontOfSize:12.0f];
            [titleLabel setTextAlignment:UITextAlignmentLeft];
            [btn addSubview:titleLabel];
            
            
            for (int j = 0 ; j < MIN(6, [[dic objectForKey:key] count]) ; j ++) {
                CALayer *layer = [[(NSArray*)[dic objectForKey:key] objectAtIndex:j] layer];
                layer.borderWidth = 1.5f;
                layer.borderColor = [UIColor whiteColor].CGColor;
                layer.frame = CGRectMake(btnWidth / 2 - layerSize*1.2  + (layerSize + layerMargin) * (j % 3), btnHeight / 2 - layerSize * 0.8 + (layerSize + layerMargin) * (j / 3), layerSize, layerSize);
                [btn.layer addSublayer:layer];
            }
        }

    }
    return self;
}

@end
