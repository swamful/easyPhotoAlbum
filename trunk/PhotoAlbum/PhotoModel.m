//
//  PhotoModel.m
//  PhotoAlbum
//
//  Created by 승필 백 on 12. 10. 15..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import "PhotoModel.h"

@implementation PhotoModel
@synthesize group, geoAltitude, geoLatitude, geoLongitude;
@synthesize time, assetUrl, thumbImage;
@synthesize device, image;

- (void) releaseImage {
    self.thumbImage = nil;
}

@end
