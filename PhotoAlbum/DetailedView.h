//
//  DetailedView.h
//  PhotoAlbum
//
//  Created by 승필 백 on 12. 10. 22..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALAssetsManager.h"
#import "DetailImageView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>

@interface DetailedView : UIView <ALAssetsMangerDelegate> {
    CALayer *currentLayer;
    NSInteger currentIndex;
    NSInteger makeIndex;
    CALayer *mainLayer;
    
    DetailImageView *imageView;
    
    NSMutableArray *_layerList;
    ALAssetsManager *alAssetManager;
    NSArray *_btnIndexList;
    
    CGPoint leftPoint;
    CGPoint centerPoint;
    CGPoint rightPoint;
    CGPoint twoRightPoint;
    CGPoint twoLeftPoint;
    
    CGPoint forePoint;
    BOOL isTap;
    
    UIPanGestureRecognizer* panRecognizer;
    NSMutableArray *requestImageQueue;
    
    UIImage *centerImage;
    
    ALAssetsLibrary *assetsLibrary;
    dispatch_queue_t dqueue;
    dispatch_semaphore_t s;
}
- (id)initWithFrame:(CGRect)frame withBtnIndexList:(NSArray*) btnIndexList currentIndex:(NSInteger) index;
@end
