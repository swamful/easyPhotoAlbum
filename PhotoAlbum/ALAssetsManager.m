//
//  ALAssetsManager.m
//  PhotoAlbum
//
//  Created by Seungpill Baik on 12. 10. 21..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import "ALAssetsManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>
#import <ImageIO/ImageIO.h>
#import "JSON.h"
@implementation ALAssetsManager
@synthesize delegate = _delegate;
static ALAssetsManager *instance= nil;
ALAssetsLibrary     *assetsLibrary;
NSMutableDictionary *_photoModelList;
NSMutableArray *_tempAddList;
NSInteger photoCount;
id<ALAssetsMangerDelegate> delegateForBlock;
+ (id) getSharedInstance {
    if (!instance) {
        instance = [[ALAssetsManager alloc] init];
    }
    return instance;
}

- (id) init {
    self = [super init];
    if (self) {
        assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return self;
}

- (void) getPhotoLibrary {
    if (_photoModelList) {
        [_photoModelList removeAllObjects];
    } else {
        _photoModelList = [[NSMutableDictionary alloc] init];
    }
    photoCount = 0;
    delegateForBlock = self.delegate;
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                 usingBlock:loadGroupsSucceedBlock
                               failureBlock:loadGroupsFailedBlock];
}

- (void) getPhotoDataWithAssetURL:(NSURL*) url {
    delegateForBlock = self.delegate;
    [assetsLibrary assetForURL:url resultBlock:resultblock failureBlock:loadGroupsFailedBlock];
}

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
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:sortedValues forKey:@"data"];
        [dic setObject:[NSNumber numberWithInteger:photoCount] forKey:@"totalCount"];
        [delegateForBlock didFinishLoadFullLibrary:dic];
    }
};
void(^loadGroupsFailedBlock)(NSError *) = ^(NSError * error){
    NSLog(@"Failed to load groups");
    NSLog(@"%@", error);
};

ALAssetsLibraryAssetForURLResultBlock resultblock   = ^(ALAsset *photo)
{
    if( photo ){
//        NSLog(@"%@", [photo valueForProperty:ALAssetPropertyURLs]);
        NSDictionary *myMetadata = [[photo defaultRepresentation] metadata];
//        NSLog(@"metadata : %@", myMetadata);
        NSDictionary *tiffData = [myMetadata objectForKey:(NSString*)kCGImagePropertyTIFFDictionary];

//        NSLog(@"location :%@", [photo valueForProperty:ALAssetPropertyLocation]);
        CLLocation *location = [photo valueForProperty:ALAssetPropertyLocation];
        PhotoModel *model = [[PhotoModel alloc] init];
        NSDate *timeStamp = [[[[photo defaultRepresentation] metadata] objectForKey:@"{Exif}"] objectForKey:@"DateTimeOriginal"];
//        NSLog(@"timeStamp : %@", timeStamp);
        if (!timeStamp) {
            timeStamp = [photo valueForProperty:ALAssetPropertyDate];
        }
        if (location) {
            CLLocationCoordinate2D gps = [location coordinate];
            NSString *address = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.co.kr/maps/geo?q=%f,%f", gps.latitude,gps.longitude]]
                                                         encoding:NSUTF8StringEncoding error:nil];
            NSDictionary *dic = [address JSONValue];
//            NSLog(@"dic : %@", dic);
//            NSLog(@"address : %@", [[[dic objectForKey:@"Placemark"] lastObject] objectForKey:@"address"]);
            [model setAddress:[[[dic objectForKey:@"Placemark"] lastObject] objectForKey:@"address"]];
        } 
        NSLog(@"timeStamp : %@", timeStamp);
        [model setTime:timeStamp];
        [model setThumbImage:[UIImage imageWithCGImage:[photo thumbnail]]];
        [model setImage:[UIImage imageWithCGImage:[[photo defaultRepresentation] fullScreenImage]]];
        [model setAssetUrl:[[[photo defaultRepresentation] url] description]];
        [delegateForBlock didFinishLoadPhotoModel:model];
    }
};


@end
