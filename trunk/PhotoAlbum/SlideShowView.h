//
//  SlideShowView.h
//  PhotoAlbum
//
//  Created by 승필 백 on 12. 10. 26..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface SlideShowView : UIView {
    NSMutableArray *_showLayerList;
    NSInteger currentIndex;
    ALAssetsLibrary *assetsLibrary;
    dispatch_queue_t dqueue;
    

    UIView *dimmedView;
    BOOL isInit;
    
    NSTimer *timer;
}
- (id)initWithFrame:(CGRect)frame slideList:(NSArray*) list;
- (void) showInvalidate;
@end
