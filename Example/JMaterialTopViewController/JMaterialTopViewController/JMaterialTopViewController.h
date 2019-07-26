//
//  JMaterialTopViewController.h
//  
//
//  Created by jun on 2019/6/15.
//  Copyright © 2019 jun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JMaterialTopViewController : UIViewController

/**
 * 注意: 此数组里面的控制器的View会被修改frame
 * 所以此数组里面控制器的View的frame在 viewDidLoad 方法里面获取的是不准确的
 * 在 viewWillAppear 方法里面获取的frame才是准确的
 */
/** 控制器数组*/
@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;
/** 标题数组*/
@property (nonatomic, strong) NSArray<NSString *> *titles;

/** 当前选中控制器*/
@property (nonatomic, assign) NSInteger selectIndex;
/** 标题正常颜色*/
@property (nonatomic, strong) UIColor *normalColor;
/** 标题选中颜色*/
@property (nonatomic, strong) UIColor *selectColor;
/** 下标线颜色*/
@property (nonatomic, strong) UIColor *underLineColor;
/** 标题宽度*/
@property (nonatomic, assign) CGFloat titleLabelWidth;

/** 是否作为导航栏标题*/
@property (nonatomic) BOOL ifAsNavBarTitle;

@end

NS_ASSUME_NONNULL_END
