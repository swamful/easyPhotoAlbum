//
//  MainViewContoller.m
//  PhotoAlbum
//
//  Created by Seungpill Baik on 12. 10. 13..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import "MainViewController.h"
#import "PhotoModel.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    galleryView = [[PhotoGalleryView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:galleryView];
    
    alassetManager = [ALAssetsManager getSharedInstance];
    alassetManager.delegate = self;
    [self performSelectorInBackground:@selector(getFullPhotosLibrary) withObject:nil];
    
//    [assetsLibrary assetForURL:[NSURL URLWithString:@"assets-library://asset/asset.JPG?id=BE08A7BC-DBC6-4596-8775-2C3530D822F2&ext=JPG"] resultBlock:resultblock failureBlock:loadGroupsFailedBlock];
}


- (void) getFullPhotosLibrary {
    @autoreleasepool {
        [alassetManager getPhotoLibrary];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) didFinishLoadFullLibrary:(NSDictionary *)dataList {
    [galleryView initLayerwithImageDataList:[dataList objectForKey:@"data"] withCount:[[dataList objectForKey:@"totalCount"] integerValue]];
}
- (void) didFinishLoadPhotoModel:(PhotoModel *)model {
    
}

/*
#pragma mark - System Rotation Methods
//for any version before 6.0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //only allow landscape
    return (interfaceOrientation != UIInterfaceOrientationMaskPortraitUpsideDown);
}

//for 6.0+
- (BOOL)shouldAutorotate{
    return [UIDevice currentDevice].orientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
*/
@end
