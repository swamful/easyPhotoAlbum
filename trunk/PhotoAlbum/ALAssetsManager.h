//
//  ALAssetsManager.h
//  PhotoAlbum
//
//  Created by Seungpill Baik on 12. 10. 21..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoModel.h"
@protocol ALAssetsMangerDelegate;

@interface ALAssetsManager : NSObject {
    id<ALAssetsMangerDelegate> _delegate;
}
@property (nonatomic) id<ALAssetsMangerDelegate> delegate;
+ (id) getSharedInstance;

- (void) getPhotoLibrary;

@end

@protocol ALAssetsMangerDelegate <NSObject>
- (void) didFinishLoadFullLibrary:(NSDictionary*) dataList;
- (void) didFinishLoadPhotoModel:(PhotoModel*) model;
@end