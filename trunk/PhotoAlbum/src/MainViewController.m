//
//  MainViewContoller.m
//  PhotoAlbum
//
//  Created by Seungpill Baik on 12. 10. 13..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import "MainViewController.h"
#import "PhotoModel.h"

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
    _allLayerList = [[NSMutableArray alloc] init];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self  action:@selector(handleScale:)];
    [pinchRecognizer setDelegate:self];
    [self.view addGestureRecognizer:pinchRecognizer];

    showingViewType = INDEXVIEW;

    alassetManager = [ALAssetsManager getSharedInstance];
    alassetManager.delegate = self;

    [alassetManager getPhotoLibrary];
//    [assetsLibrary assetForURL:[NSURL URLWithString:@"assets-library://asset/asset.JPG?id=BE08A7BC-DBC6-4596-8775-2C3530D822F2&ext=JPG"] resultBlock:resultblock failureBlock:loadGroupsFailedBlock];
}


- (void) handleScale:(UIPinchGestureRecognizer *) recognizer {
    if (recognizer.scale < 1) {
        if (showingViewType == INDEXVIEW) {
            return;
        }
        showingViewType = INDEXVIEW;
        [CATransaction begin];
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.toValue = [NSNumber numberWithFloat:0.0f];
        opacityAnimation.duration = 0.5;
        opacityAnimation.fillMode = kCAFillModeForwards;
        opacityAnimation.removedOnCompletion = NO;
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
        scaleAnimation.toValue = [NSNumber numberWithFloat:0.0f];
        scaleAnimation.duration = 0.5;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.duration = 0.49;
        animationGroup.removedOnCompletion = NO;
        animationGroup.fillMode = kCAFillModeForwards;
        animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [animationGroup setAnimations:[NSArray arrayWithObjects:opacityAnimation,scaleAnimation, nil]];
        
        [CATransaction setCompletionBlock:^(){
            [self.view.layer removeAllAnimations];
            [self changeShowingView];
        }];
        [self.view.layer addAnimation:animationGroup forKey:@"animationGroup"];
        
        [CATransaction commit];
    } else {
        if (showingViewType == TOTALVIEW) {
            return;
        }
        showingViewType = TOTALVIEW;
        [CATransaction begin];
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.toValue = [NSNumber numberWithFloat:0.0f];
        opacityAnimation.duration = 0.5;
        opacityAnimation.fillMode = kCAFillModeForwards;
        opacityAnimation.removedOnCompletion = NO;
        
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.toValue = [NSNumber numberWithFloat:4.0f];
        scaleAnimation.duration = 0.5;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.duration = 0.49;
        animationGroup.removedOnCompletion = NO;
        animationGroup.fillMode = kCAFillModeForwards;
        animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [animationGroup setAnimations:[NSArray arrayWithObjects:opacityAnimation,scaleAnimation, nil]];
        
        [CATransaction setCompletionBlock:^(){
            [self.view.layer removeAllAnimations];
            [self changeShowingView];
        }];
        [self.view.layer addAnimation:animationGroup forKey:@"animationGroup"];
        
        [CATransaction commit];
    }
    NSLog(@"scale: %f", recognizer.scale);
}

- (void) changeShowingView {
    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
    switch (showingViewType) {
        case TOTALVIEW:
            galleryView = [[PhotoGalleryView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withDataList:_allLayerList withTotalCount:totalCount];
            [self.view addSubview:galleryView];
            break;
        case INDEXVIEW:
            indexView = [[IndexView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withAllLayerList:_allLayerList];
            [self.view addSubview:indexView];
            break;

        default:
            break;
    }
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
    [self makeAllLayerList:dataList];
    [self changeShowingView];
}
- (void) didFinishLoadPhotoModel:(PhotoModel *)model {
    
}


- (void) makeAllLayerList:(NSDictionary*) dataList {
    [_allLayerList removeAllObjects];
    NSArray *data = [dataList objectForKey:@"data"];
    NSInteger tCount = 0;
    NSString *title = @"";
    for (NSDictionary *dic in data) {
        NSMutableDictionary *dicData = [NSMutableDictionary dictionary];
        NSMutableArray *eachLayerList = [NSMutableArray array];
        for (PhotoModel *model in dic) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = tCount++;
            title = [[[[model time] description] componentsSeparatedByString:@" "] objectAtIndex:0];
            CALayer *layer = [btn layer];
            layer.name = [model assetUrl];
            layer.contents = (id) model.thumbImage.CGImage;
            
            [eachLayerList addObject:btn];
        }
        [dicData setObject:eachLayerList forKey:title];
        [_allLayerList addObject:dicData];
    }
    totalCount = tCount;
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
