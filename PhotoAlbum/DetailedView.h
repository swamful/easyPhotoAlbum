//
//  DetailedView.h
//  PhotoAlbum
//
//  Created by 승필 백 on 12. 10. 22..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALAssetsManager.h"
@interface DetailedView : UIView <ALAssetsMangerDelegate> {
    CALayer *currentLayer;
    NSInteger currentIndex;
    NSInteger makeIndex;
    CALayer *mainLayer;

    NSMutableArray *_layerList;
    ALAssetsManager *alAssetManager;
    NSArray *_btnIndexList;
    
    CGPoint leftPoint;
    CGPoint centerPoint;
    CGPoint rightPoint;
    CGPoint forePoint;
    BOOL isInit;
    BOOL isMoving;
}
- (id)initWithFrame:(CGRect)frame withBtnIndexList:(NSArray*) btnIndexList currentIndex:(NSInteger) index;
@end
