//
//  MainViewContoller.m
//  PhotoAlbum
//
//  Created by Seungpill Baik on 12. 10. 13..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import "MainViewController.h"
#import "PhotoModel.h"
#import "PhotoGalleryView.h"
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>

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
BOOL isFinish = NO;
ALAssetsLibrary         *assetsLibrary;
NSMutableDictionary *_photoModelList;
NSMutableArray *_tempAddList;
NSInteger photoCount;
PhotoGalleryView *galleryView;

void(^loadPhotosBlock)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset * photo, NSUInteger index, BOOL * stop){
    if( photo ){
        NSDate *lastDate = [[_tempAddList lastObject] time];
        NSDate *parseDate = [photo valueForProperty:ALAssetPropertyDate];
        NSComparisonResult compareResult = [lastDate compare:parseDate];
        
        if (lastDate == nil) {
            _tempAddList = [[NSMutableArray alloc] init];
        } else if (compareResult != NSOrderedSame) {
            [_photoModelList setObject:_tempAddList forKey:[[[lastDate description] componentsSeparatedByString:@" "] objectAtIndex:0]];
            
            _tempAddList = [_photoModelList objectForKey:[[[parseDate description] componentsSeparatedByString:@" "] objectAtIndex:0]];
            if (!_tempAddList) {
               _tempAddList = [[NSMutableArray alloc] init]; 
            }
        }
            
        PhotoModel *model = [[PhotoModel alloc] init];
        [model setTime:[photo valueForProperty:ALAssetPropertyDate]];
        [model setThumbImage:[UIImage imageWithCGImage:[photo thumbnail]]];
//        [model setImage:[UIImage imageWithCGImage:[[photo defaultRepresentation] fullScreenImage]]];
        [model setAssetUrl:[[[photo defaultRepresentation] url] description]];
        [_tempAddList addObject:model];
    }
};

void(^loadGroupsSucceedBlock)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup * group, BOOL * stop){
    if( group ){
//        NSLog(@"[%@]", [group valueForProperty:ALAssetsGroupPropertyName]);
//        NSLog(@"- Type : %@", [group valueForProperty:ALAssetsGroupPropertyType]);
//        NSLog(@"- PersistentID : %@", [group valueForProperty:ALAssetsGroupPropertyPersistentID]);
//        NSLog(@"- URL : %@", [group valueForProperty:ALAssetsGroupPropertyURL]);
//        NSLog(@"- NumberOfAssets : %d", [group numberOfAssets]);

        photoCount = [group numberOfAssets] + photoCount;
//        NSLog(@"photoCount : %d", photoCount);
//        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, MIN([group numberOfAssets], 50))];
//        [group enumerateAssetsAtIndexes:indexSet options:NSEnumerationReverse usingBlock:loadPhotosBlock];
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:loadPhotosBlock];


    } else {
        NSArray *sortedKeys = [[_photoModelList allKeys] sortedArrayUsingSelector: @selector(compare:)];
        NSMutableArray *sortedValues = [NSMutableArray array];
        for (NSString *key in sortedKeys)
            [sortedValues insertObject:[_photoModelList objectForKey: key] atIndex:0];
        [galleryView initLayerwithImageDataList:sortedValues withCount:photoCount];
        isFinish = YES;

        
    }
};
void(^loadGroupsFailedBlock)(NSError *) = ^(NSError * error){
    NSLog(@"Failed to load groups");
    NSLog(@"%@", error);
};

ALAssetsLibraryAssetForURLResultBlock resultblock   = ^(ALAsset *photo)
{
    if( photo ){
        NSLog(@"%@", [photo valueForProperty:ALAssetPropertyURLs]);
        NSDictionary *myMetadata = [[photo defaultRepresentation] metadata];
        NSLog(@"meta : %@", myMetadata);
    }
};



- (void)viewDidLoad
{
    [super viewDidLoad];
    _photoModelList = [[NSMutableDictionary alloc] init];
    
    galleryView = [[PhotoGalleryView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:galleryView];
    
    
    [self performSelectorInBackground:@selector(getPhotos) withObject:nil];
    
//    [assetsLibrary assetForURL:[NSURL URLWithString:@"assets-library://asset/asset.JPG?id=BE08A7BC-DBC6-4596-8775-2C3530D822F2&ext=JPG"] resultBlock:resultblock failureBlock:loadGroupsFailedBlock];
    
}


- (void) getPhotos {
    @autoreleasepool {
        assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                     usingBlock:loadGroupsSucceedBlock
                                   failureBlock:loadGroupsFailedBlock];        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
