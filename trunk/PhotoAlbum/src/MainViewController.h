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
@interface MainViewController: UIViewController <ALAssetsMangerDelegate>{
    ALAssetsManager *alassetManager;
    PhotoGalleryView *galleryView;
}

@end
