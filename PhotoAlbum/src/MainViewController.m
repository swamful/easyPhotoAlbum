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

- (void)viewDidLoad
{
    [super viewDidLoad];
    _allLayerList = [[NSMutableArray alloc] init];
    _btnIndexList = [[NSMutableArray alloc] init];
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self  action:@selector(handleScale:)];
    [pinchRecognizer setDelegate:self];
    [self.view addGestureRecognizer:pinchRecognizer];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecognizer.delegate = self;
    tapRecognizer.numberOfTapsRequired = 2;
    tapRecognizer.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:tapRecognizer];
    
    
    showingViewType = INDEXVIEW;

    alassetManager = [ALAssetsManager getSharedInstance];
    alassetManager.delegate = self;

    [alassetManager getPhotoLibrary];
}

- (void) handleTap:(UITapGestureRecognizer *) recognizer {
    if (showingViewType == SLIDESHOWVIEW) {
        return;
    }
    showingViewType = SLIDESHOWVIEW;
    [self changeShowingView];
}

- (void) handleScale:(UIPinchGestureRecognizer *) recognizer {
    if (showingViewType == SLIDESHOWVIEW) {
        [slideShowView showInvalidate];
    }
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
}

- (void) changeShowingView {
    for (NSDictionary *dataDic in _allLayerList) {
        for (UIButton *btn in [[dataDic allValues] objectAtIndex:0]) {
            [btn removeFromSuperview];
        }
    }
    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
    galleryView = nil;
    indexView = nil;
    detailedView = nil;
    slideShowView = nil;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    switch (showingViewType) {
        case TOTALVIEW:
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            galleryView = [[PhotoGalleryView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height) withDataList:_btnIndexList withTotalCount:totalCount];
            [self.view addSubview:galleryView];
            break;
        case INDEXVIEW:
            indexView = [[IndexView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withAllLayerList:_allLayerList];
            [self.view addSubview:indexView];
            break;
        case DETAILEDVIEW:
            detailedView = [[DetailedView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withBtnIndexList:_btnIndexList currentIndex:selectedIndex];
            [self.view addSubview:detailedView];
            break;
        case SLIDESHOWVIEW:
            [UIApplication sharedApplication].idleTimerDisabled = YES; 
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            slideShowView = [[SlideShowView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height) slideList:_btnIndexList];
            [self.view addSubview:slideShowView];
            break;
        default:
            break;
    }
}

- (void) selectThis:(id) control {
    showingViewType = DETAILEDVIEW;
    selectedIndex = [control tag];
    [self changeShowingView];
}

- (void) didFinishLoadFullLibrary:(NSDictionary *)dataList {
    [self makeAllLayerList:dataList];
    [self changeShowingView];
}


- (void) makeAllLayerList:(NSDictionary*) dataList {
    [_allLayerList removeAllObjects];
    [_btnIndexList removeAllObjects];
    NSArray *data = [dataList objectForKey:@"data"];
    NSInteger tCount = 0;
    NSString *title = @"";
    for (NSDictionary *dic in data) {
        NSMutableDictionary *dicData = [NSMutableDictionary dictionary];
        NSMutableArray *eachLayerList = [NSMutableArray array];
        for (PhotoModel *model in dic) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn addTarget:self action:@selector(selectThis:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = tCount++;
            title = [[[[model time] description] componentsSeparatedByString:@" "] objectAtIndex:0];
            CALayer *layer = [btn layer];
            layer.name = [model assetUrl];
            layer.contents = (id) model.thumbImage.CGImage;
            
            [eachLayerList addObject:btn];
            [_btnIndexList addObject:btn];
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
    NSLog(@"shouldAutorotateToInterfaceOrientation showView : %d", showingViewType);
    if (showingViewType == TOTALVIEW) {
        return interfaceOrientation == UIInterfaceOrientationLandscapeRight;
    } 
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//for 6.0+
- (BOOL)shouldAutorotate{
    NSLog(@"shouldAutorotate showView : %d", showingViewType);
    if (showingViewType == TOTALVIEW) {
        return [UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeRight;
    }
    return ([UIDevice currentDevice].orientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations{
    NSLog(@"supportedInterfaceOrientations showView : %d", showingViewType);
    if (showingViewType == TOTALVIEW) {
        return UIInterfaceOrientationMaskLandscapeRight;
    }
    return UIInterfaceOrientationMaskPortrait;
}
 */

@end
