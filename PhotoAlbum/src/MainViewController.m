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
    indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    indicator.center = self.view.center;
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self.view addSubview:indicator];
    [indicator startAnimating];
    _allLayerList = [[NSMutableArray alloc] init];
    _btnIndexList = [[NSMutableArray alloc] init];
    _slideShowIndexList = [[NSMutableArray alloc] init];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self  action:@selector(handleScale:)];
    [pinchRecognizer setDelegate:self];
    [self.view addGestureRecognizer:pinchRecognizer];

    showingViewType = INDEXVIEW;

    alassetManager = [ALAssetsManager getSharedInstance];
    alassetManager.delegate = self;

    [alassetManager getPhotoLibrary];
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"isNoGuide"] boolValue]) {
        guideView = [[GuideView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:guideView];
    }
}

- (void) gudieViewShowAni {
    [UIView transitionWithView:guideView duration:0.6 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        guideView.hidden = NO;
    } completion:^(BOOL finish){}];
}

- (void) guideViewCloseAni {
    [UIView transitionWithView:guideView duration:0.6 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        guideView.hidden = YES;
    } completion:^(BOOL finish){
        [guideView removeFromSuperview];
        guideView = nil;
    }];
}

- (void) showGuideView {
    guideView = [[GuideView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    guideView.hidden = YES;
    [self.view addSubview:guideView];
    [self performSelector:@selector(gudieViewShowAni) withObject:nil afterDelay:0.0];
    
}

- (void) closeGuideView {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isNoGuide"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self performSelector:@selector(guideViewCloseAni) withObject:nil afterDelay:0.0];
}


- (void) closeGalleryView {
    [self changeToIndexView];
}

- (void) changeToSlideView {
    if ([_slideShowIndexList count] == 0 ) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"슬라이드 쇼 사진을 선택해 주세요" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [self.view addSubview:alertView];
        [alertView show];
        return;
    } else if (showingViewType == SLIDESHOWVIEW) {
        return;
    }
    showingViewType = SLIDESHOWVIEW;
    [CATransaction begin];
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.0f];
    opacityAnimation.duration = 0.5;
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.removedOnCompletion = NO;
    [CATransaction setCompletionBlock:^() {
        
        [self changeShowingView];
    }];
    [self.view.layer addAnimation:opacityAnimation forKey:@"opacity"];
    [CATransaction commit];
    
}

- (void) changeToIndexView {
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
}

- (void) changeToRandomView {
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


- (void) handleScale:(UIPinchGestureRecognizer *) recognizer {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if (showingViewType == SLIDESHOWVIEW) {
        [slideShowView showInvalidate];
    } else if (showingViewType == DETAILEDVIEW) {
        currentIndex = detailedView.currentIndex;
    }
    
    if (recognizer.scale < 1) {
        [self changeToIndexView];
    }
}

- (void) changeShowingView {
    for (NSDictionary *dataDic in _allLayerList) {
        for (UIButton *btn in [[dataDic allValues] objectAtIndex:0]) {
            [btn removeFromSuperview];
        }
    }
    for (UIView *view in [self.view subviews]) {
        if ([view isKindOfClass:[GuideView class]]) {
            continue;
        }
        [view removeFromSuperview];
    }
    [self.view.layer removeAllAnimations];
    galleryView.delegate = nil;
    galleryView = nil;
    indexView.delegate = nil;
    indexView = nil;
    detailedView = nil;
    slideShowView = nil;

    [UIApplication sharedApplication].idleTimerDisabled = NO;
    switch (showingViewType) {
        case TOTALVIEW:
            galleryView = [[PhotoGalleryView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height) withDataList:_btnIndexList withTotalCount:totalCount];
            galleryView.delegate = self;
            [self.view addSubview:galleryView];
            break;
        case INDEXVIEW:
            indexView = [[IndexView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withAllLayerList:_allLayerList currentIndex:currentIndex];
            indexView.delegate = self;
            if (!isOverFirstLoad) {
                [indexView beginAnimation];
                isOverFirstLoad = YES;
            }
            [self.view insertSubview:indexView atIndex:0];
            break;
        case DETAILEDVIEW:
            detailedView = [[DetailedView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withBtnIndexList:_btnIndexList currentIndex:selectedIndex];
            [self.view addSubview:detailedView];
            break;
        case SLIDESHOWVIEW:
            [UIApplication sharedApplication].idleTimerDisabled = YES;
            slideShowView = [[SlideShowView alloc] initWithFrame:CGRectMake(0, -10, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height) slideList:_slideShowIndexList];
            [self.view addSubview:slideShowView];
            break;
        default:
            break;
    }
}

- (void) selectThis:(id) control {
    if (isSlideRegisterMode) {
        if ([_slideShowIndexList containsObject:control]) {
            [_slideShowIndexList removeObject:control];
            [[(UIButton *) control layer] setBorderColor:[UIColor whiteColor].CGColor];
            NSArray *list = [[NSUserDefaults standardUserDefaults] objectForKey:kSlideShowList];
            NSMutableArray *newList = [NSMutableArray array];
            for (NSString *assetUrl in list) {
                if (![[[(UIButton *) control layer] name] isEqualToString:assetUrl]) {
                    [newList addObject:[[(UIButton *) control layer] name]];
                }
            }            
            [[NSUserDefaults standardUserDefaults] setObject:newList forKey:kSlideShowList];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            [_slideShowIndexList addObject:control];
            [[(UIButton *) control layer] setBorderColor:[UIColor magentaColor].CGColor];
            NSArray *list = (NSMutableArray *)[[NSUserDefaults standardUserDefaults] objectForKey:kSlideShowList];
            NSMutableArray *newList = [NSMutableArray array];
            NSString *asset = [NSString stringWithString:[[(UIButton *) control layer] name]];
            [newList addObject:asset];
            for (NSString *assetUrl in list) {
                if (![[[(UIButton *) control layer] name] isEqualToString:assetUrl]) {
                    [newList addObject:assetUrl];
                }
            }
            [[NSUserDefaults standardUserDefaults] setObject:newList forKey:kSlideShowList];
            [[NSUserDefaults standardUserDefaults] synchronize];            
        }
    } else {
        showingViewType = DETAILEDVIEW;
        selectedIndex = [control tag];
        [self changeShowingView];
    }
}

- (void) didFinishLoadFullLibrary:(NSDictionary *)dataList {
    [self makeAllLayerList:dataList];
    [indicator stopAnimating];
    [indicator removeFromSuperview];
    indicator = nil;
    [self changeShowingView];
}


- (void) makeAllLayerList:(NSDictionary*) dataList {
    [_allLayerList removeAllObjects];
    [_btnIndexList removeAllObjects];
    NSArray *data = [dataList objectForKey:@"data"];
    NSInteger tCount = 0;
    NSString *title = @"";
    NSArray *list = [[NSUserDefaults standardUserDefaults] objectForKey:kSlideShowList];
    NSMutableArray *assetUrlList = [NSMutableArray array];
    for (NSDictionary *dic in data) {
        [assetUrlList removeAllObjects];
        NSMutableDictionary *dicData = [NSMutableDictionary dictionary];
        NSMutableArray *eachLayerList = [NSMutableArray array];
        BOOL isExist = NO;
        for (PhotoModel *model in dic) {
            for (NSString *assetUrl in assetUrlList) {
                if ([assetUrl isEqualToString:[model assetUrl]]) {
                    isExist = YES;
                    break;
                }
            }
            if (isExist) {
                continue;
            } else {
                [assetUrlList addObject:[model assetUrl]];
            }
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn addTarget:self action:@selector(selectThis:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = tCount++;
            title = [[[[model time] description] componentsSeparatedByString:@" "] objectAtIndex:0];
            CALayer *layer = [btn layer];
            layer.name = [model assetUrl];
            layer.contents = (id) model.thumbImage.CGImage;
            layer.borderWidth = 2.0f;
            layer.borderColor = [UIColor whiteColor].CGColor;
            for (NSString *assetUrl in list) {
                if ([assetUrl isEqualToString:layer.name]) {
                    layer.borderColor = [UIColor magentaColor].CGColor;
                    [_slideShowIndexList addObject:btn];
                }
            }
            [eachLayerList addObject:btn];
            [_btnIndexList addObject:btn];
        }
        [dicData setObject:eachLayerList forKey:title];
        [_allLayerList addObject:dicData];
    }
    totalCount = tCount;
}

- (void) changeSlideSelectMode:(BOOL) isSlide {
    isSlideRegisterMode = isSlide;
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
