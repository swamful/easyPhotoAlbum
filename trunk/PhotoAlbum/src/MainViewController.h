//
//  MainViewController.h
//  PhotoAlbum
//
//  Created by Seungpill Baik on 12. 10. 13..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALAssetsManager.h"
#import "PhotoGalleryView.h"
#import "IndexView.h"
#import "UIConstans.h"
#import "DetailedView.h"
#import "SlideShowView.h"
@interface MainViewController: UIViewController <ALAssetsMangerDelegate, UIGestureRecognizerDelegate, IndexViewDelegate ,PhotoGallertViewDelegate>{
    ALAssetsManager *alassetManager;
    PhotoGalleryView *galleryView;
    DetailedView *detailedView;
    IndexView *indexView;
    SlideShowView *slideShowView;
    NSMutableArray *_allLayerList;
    NSMutableArray *_btnIndexList;
    NSMutableArray *_slideShowIndexList;
    VIEWTYPE showingViewType;
    
    NSInteger totalCount;
    
    NSInteger selectedIndex;
    BOOL isSlideRegisterMode;
}

@end
