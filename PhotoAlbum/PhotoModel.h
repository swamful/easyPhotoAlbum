//
//  PhotoModel.h
//  PhotoAlbum
//
//  Created by 승필 백 on 12. 10. 15..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoModel : NSObject {
    NSString *group;
    NSString *geoAltitude;
    NSString *geoLatitude;
    NSString *geoLongitude;
    NSDate *time;
    NSString *device;
    NSURL *assetUrl;
    UIImage *thumbImage;
    UIImage *image;
}
@property (nonatomic, strong) NSString *group;
@property (nonatomic, strong) NSString *geoAltitude;
@property (nonatomic, strong) NSString *geoLatitude;
@property (nonatomic, strong) NSString *geoLongitude;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) NSString *device;
@property (nonatomic, strong) NSURL *assetUrl;
@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) UIImage *image;

- (void) releaseImage;

@end
