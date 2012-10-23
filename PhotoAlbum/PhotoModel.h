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
    NSString *address;
    NSDate *time;
    NSString *device;
    NSString *assetUrl;
    UIImage *thumbImage;
    UIImage *image;
}
@property (nonatomic, strong) NSString *group;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) NSString *device;
@property (nonatomic, strong) NSString *assetUrl;
@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) UIImage *image;

- (void) releaseImage;

@end
