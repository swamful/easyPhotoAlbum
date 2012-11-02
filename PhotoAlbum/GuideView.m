//
//  GuideView.m
//  PhotoAlbum
//
//  Created by Seungpill Baik on 12. 11. 2..
//  Copyright (c) 2012년 Seungpill Baik. All rights reserved.
//

#import "GuideView.h"

@implementation GuideView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIView *dimmedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 100)];
        dimmedView.backgroundColor = [UIColor blackColor];
        dimmedView.alpha = 0.7;
        [self addSubview:dimmedView];

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(270, 0, 50, 50);
        [btn setImage:[UIImage imageNamed:@"btn_close"] forState:UIControlStateNormal];
        [btn addTarget:nil action:@selector(closeGuideView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];

        [self makeMenuLayer];
        
        UIView *bottomDimmedView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 100, self.frame.size.width, self.frame.size.height)];
        bottomDimmedView.backgroundColor = [UIColor clearColor];
        bottomDimmedView.alpha = 0.5f;
        [self addSubview:bottomDimmedView];
        
        CATextLayer *controlPannelLayer = [CATextLayer layer];
        controlPannelLayer.frame = CGRectMake(0, 20, self.frame.size.width, 60);
        controlPannelLayer.font = (__bridge CFTypeRef)([UIFont fontWithName:@"GillSans-Italic" size:30].fontName);
        controlPannelLayer.foregroundColor = [UIColor colorWithRed:0.0f/255.0  green:126.0f/255.0f blue:255.0f/255.0f alpha:1.0f].CGColor;
        controlPannelLayer.string = @"Control Pannel";
        controlPannelLayer.alignmentMode = kCAAlignmentCenter;
        [bottomDimmedView.layer addSublayer:controlPannelLayer];
        
    }
    return self;
}


- (void) makeMenuLayer {
    UIView *_menuLayer = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height / 2 - 100, self.frame.size.width, 200)];
    _menuLayer.backgroundColor = [UIColor whiteColor];
    [self addSubview:_menuLayer];
    
    CATextLayer *textView = [CATextLayer layer];
    textView.string = @"하단 Control Pannel\n메뉴 조작 방법";
    textView.font = (__bridge CFTypeRef)([UIFont fontWithName:@"GillSans-Italic" size:20].fontName);
    textView.fontSize = 20.0f;
    textView.frame = CGRectMake(0, 20, 320, 80);
    textView.foregroundColor = [UIColor colorWithRed:0.0f/255.0  green:126.0f/255.0f blue:255.0f/255.0f alpha:1.0f].CGColor;
    textView.alignmentMode = kCAAlignmentCenter;
    [_menuLayer.layer addSublayer:textView];
    
    CALayer *dTapLayer = [CALayer layer];
    dTapLayer.frame = CGRectMake(10, 80, 40, 40);
    dTapLayer.contents = (id)[UIImage imageNamed:@"Double_tap"].CGImage;
    [_menuLayer.layer addSublayer:dTapLayer];
    
    CATextLayer *dTLayer = [CATextLayer layer];
    dTLayer.frame = CGRectMake(60, 90, 70, 30);
    dTLayer.string = @"슬라이드 쇼";
    dTLayer.foregroundColor = [UIColor redColor].CGColor;
    dTLayer.fontSize = 13.0f;
    dTLayer.alignmentMode = kCAAlignmentCenter;
    [_menuLayer.layer addSublayer:dTLayer];
    
    CALayer *pinchLayer = [CALayer layer];
    pinchLayer.frame = CGRectMake(140, 140, 60, 40);
    pinchLayer.contents = (id)[UIImage imageNamed:@"Pinch"].CGImage;
    [_menuLayer.layer addSublayer:pinchLayer];
    
    CATextLayer *pTLayer = [CATextLayer layer];
    pTLayer.frame = CGRectMake(200, 150, 100, 30);
    pTLayer.string = @"현재 보고 있는 \n창 닫기";
    pTLayer.foregroundColor = [UIColor redColor].CGColor;
    pTLayer.fontSize = 13.0f;
    pTLayer.alignmentMode = kCAAlignmentCenter;
    [_menuLayer.layer addSublayer:pTLayer];
    
    CALayer *spreadLayer = [CALayer layer];
    spreadLayer.frame = CGRectMake(140, 80, 60, 40);
    spreadLayer.contents = (id)[UIImage imageNamed:@"Spread"].CGImage;
    [_menuLayer.layer addSublayer:spreadLayer];
    
    CATextLayer *sTLayer = [CATextLayer layer];
    sTLayer.frame = CGRectMake(200, 90, 100, 30);
    sTLayer.string = @"랜덤 사진 보기";
    sTLayer.foregroundColor = [UIColor redColor].CGColor;
    sTLayer.fontSize = 13.0f;
    sTLayer.alignmentMode = kCAAlignmentCenter;
    [_menuLayer.layer addSublayer:sTLayer];
    
    CALayer *pressLayer = [CALayer layer];
    pressLayer.frame = CGRectMake(10, 140, 40, 40);
    pressLayer.contents = (id)[UIImage imageNamed:@"Pressed"].CGImage;
    [_menuLayer.layer addSublayer:pressLayer];
    
    CATextLayer *prTLayer = [CATextLayer layer];
    prTLayer.frame = CGRectMake(60, 150, 80, 30);
    prTLayer.string = @"슬라이드 쇼\n사진 선택";
    prTLayer.foregroundColor = [UIColor redColor].CGColor;
    prTLayer.fontSize = 13.0f;
    prTLayer.alignmentMode = kCAAlignmentCenter;
    [_menuLayer.layer addSublayer:prTLayer];
    
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
