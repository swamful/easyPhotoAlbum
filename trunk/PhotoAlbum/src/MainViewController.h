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
@interface MainViewController: UIViewController <ALAssetsMangerDelegate, UIGestureRecognizerDelegate>{
    ALAssetsManager *alassetManager;
    PhotoGalleryView *galleryView;
    IndexView *indexView;
    NSMutableArray *_allLayerList;
    VIEWTYPE showingViewType;
    
    NSInteger totalCount;
    
}

@end
