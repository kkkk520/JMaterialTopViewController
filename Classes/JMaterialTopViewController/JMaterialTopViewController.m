//
//  JMaterialTopViewController.m
//  
//
//  Created by jun on 2019/6/15.
//  Copyright © 2019 jun. All rights reserved.
//

#import "JMaterialTopViewController.h"
#import "JMaterialTopTitleLabel.h"
#import "JMaterialTopFlowLayout.h"

//状态栏高度
#define JStatusBarH UIApplication.sharedApplication.statusBarFrame.size.height

//导航栏高度
#define JNavBarH 44.0

#define JSCREENW [UIScreen mainScreen].bounds.size.width
#define JSCREENH [UIScreen mainScreen].bounds.size.height

// 默认标题字体
#define JTitleFont [UIFont systemFontOfSize:15]

// 标题滚动视图的高度
static CGFloat const JTitleScrollViewH = 44;

// 下标线默认高度
static CGFloat const JUnderLineH = 2;

// 默认标题间距
static CGFloat const JTitleMargin = 20;

static NSString * const idty = @"CollectionCell";

@interface JMaterialTopViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

/** 整体内容视图, 包含标题滚动视图和内容滚动视图 */
@property (nonatomic, strong) UIView *contentView;
/** 标题滚动视图 */
@property (nonatomic, strong) UIScrollView *titleScrollView;
/** 内容滚动视图 */
@property (nonatomic, strong) UICollectionView *contentScrollView;
/** 下标线 */
@property (nonatomic, strong) UIView *underLine;

/** 标题间距 */
@property (nonatomic, assign) CGFloat titleMargin;
/** 存放所有标题label数组 */
@property (nonatomic, strong) NSMutableArray *titleLabels;
/** 存放所有标题label宽度数组 */
@property (nonatomic, strong) NSMutableArray *titleWidths;
/** 是否初始化过 */
@property (nonatomic, assign) BOOL isInitial;

/** 记录内容滚动视图上一次的偏移量 */
@property (nonatomic, assign) CGFloat lastOffsetX;

@end

@implementation JMaterialTopViewController

#pragma mark - init

- (instancetype)init {
    if (self = [super init]) {
        [self initial];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initial];
}

- (void)initial {
    _normalColor = UIColor.lightGrayColor;
    _selectColor = UIColor.blackColor;
    _selectIndex = 0;
    _underLineColor = UIColor.redColor;
    
    _ifAsNavBarTitle = NO;
}

#pragma mark -

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.isInitial == YES) return; // 如果已经初始化过, 则不需要再次创建子视图
    
    if (self.viewControllers.count != self.titles.count) {
        // 抛异常
        NSException *excp = [NSException exceptionWithName:@"JMaterialTopViewController" reason:@"viewControllers 配置数量与 titls 配置数量不相等" userInfo:nil];
        [excp raise];
    }
    if (_selectIndex > self.viewControllers.count - 1) {
        NSException *excp = [NSException exceptionWithName:@"JMaterialTopViewController" reason:@"selectIndex 属性设置错误" userInfo:nil];
        [excp raise];
    }
    
    // 创建子视图
    [self createUI];
    
    // 没有设置标题label宽度, 计算出标题宽度
    if (!self.titleLabelWidth) {
        [self calculateAllTitleLabelWidth];
    }
    
    // 创建标题label
    [self createTitleLabel];
    
    // 滚到到指定位置
    if (self.titleLabels.count) {
        UILabel *label = self.titleLabels[_selectIndex];
        [self titleClick:label.gestureRecognizers.lastObject];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.isInitial == NO) {
        self.isInitial = YES;
    }
}

#pragma mark -

- (void)createUI
{
    /**  使 viewControllers 里面的 VC 能够获取到 navigationController */
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addChildViewController:obj];
    }];
    
    // 整个内容view
    _contentView = UIView.new;
    _contentView.frame = CGRectMake(0, JStatusBarH + JNavBarH, JSCREENW, JSCREENH - JStatusBarH - JNavBarH);
    [self.view addSubview:_contentView];
    
    // 标题 scrollView
    _titleScrollView = UIScrollView.new;
    _titleScrollView.frame = CGRectMake(0, 0, JSCREENW, JTitleScrollViewH);
    _titleScrollView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    _titleScrollView.showsHorizontalScrollIndicator = NO;
    [_contentView addSubview:_titleScrollView];
    
    // 下标线
    _underLine = UIView.new;
    _underLine.frame = CGRectMake(0, JTitleScrollViewH - JUnderLineH, 0, JUnderLineH);
    _underLine.backgroundColor = _underLineColor;
    [self.titleScrollView addSubview:_underLine];
    
    // 内容滚动视图
    JMaterialTopFlowLayout *layout = JMaterialTopFlowLayout.new;
    _contentScrollView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _contentScrollView.frame = CGRectMake(0, JTitleScrollViewH, JSCREENW, _contentView.frame.size.height - JTitleScrollViewH);
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.bounces = NO;
    _contentScrollView.delegate = self;
    _contentScrollView.dataSource = self;
    if ( @available(iOS 11.0, *) ) {
        _contentScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [_contentScrollView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:idty];
    [self.contentView insertSubview:_contentScrollView belowSubview:self.titleScrollView];
    
    // 所有标题label数组
    _titleLabels = @[].mutableCopy;
    // 所有标题宽度数组
    _titleWidths = @[].mutableCopy;
    
    // 标题滚动视图作为导航栏的标题视图
    if (_ifAsNavBarTitle) {
        _contentView.frame = CGRectMake(0, JStatusBarH + JNavBarH, JSCREENW, JSCREENH - JStatusBarH - JNavBarH);
        
        [_titleScrollView removeFromSuperview];
        _titleScrollView.frame = CGRectMake(0, 0, JSCREENW - 180, JTitleScrollViewH);
        _titleScrollView.backgroundColor = UIColor.clearColor;
        self.navigationItem.titleView = _titleScrollView;
        
        _contentScrollView.frame = CGRectMake(0, 0, JSCREENW, _contentView.frame.size.height);
    }
}

// 计算每个标题宽度
- (void)calculateAllTitleLabelWidth
{
    [self.titleWidths removeAllObjects];
    CGFloat totalWidth = 0;
    
    for (NSString *title in self.titles) {
    
        CGRect titleBounds = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:JTitleFont} context:nil];
        
        CGFloat width = titleBounds.size.width;
        if (width == 0) { // 默认宽度
            width = 30;
        }
        [self.titleWidths addObject:@(width)];
        
        totalWidth += width;
    }
    
    // 计算标题label之间的间距, 如果小于默认间距则以默认间距为准
    // 如果设置过标题label宽度, 则标题label之间的间距为0
    CGFloat countMargin = (_titleScrollView.frame.size.width - totalWidth) / (self.titles.count + 1);
    _titleMargin = countMargin < JTitleMargin ? JTitleMargin : countMargin;
}

// 创建标题label
- (void)createTitleLabel
{
    CGFloat labelW = self.titleLabelWidth;
    CGFloat labelH = JTitleScrollViewH - JUnderLineH;
    CGFloat labelX = 0;
    CGFloat labelY = 0;
    
    for (int i = 0; i < self.titles.count; i++) {
        
        UILabel *label = JMaterialTopTitleLabel.new;
        label.tag = i;
        label.textColor = self.normalColor;
        label.font = JTitleFont;
        label.text = self.titles[i];
        
        if (!self.titleLabelWidth) {
            labelW = [self.titleWidths[i] floatValue];

            UILabel *lastLabel = [self.titleLabels lastObject];
            labelX = CGRectGetMaxX(lastLabel.frame) + self.titleMargin;
        } else {  // 已经设置过标题宽度
            labelX = i * labelW;
        }
        
        // label位置
        label.frame = CGRectMake(labelX, labelY, labelW, labelH);
        
        // 添加单击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleClick:)];
        [label addGestureRecognizer:tap];
        
        // 保存到数组
        [self.titleLabels addObject:label];
        
        [_titleScrollView addSubview:label];
    }
    
    UILabel *lastLabel = self.titleLabels.lastObject;
    _titleScrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastLabel.frame) + self.titleMargin, JTitleScrollViewH);
}

# pragma mark - User Interaction
// 标题label 点击
- (void)titleClick:(UITapGestureRecognizer *)tap
{
    UILabel *label = (UILabel *)tap.view;

    self.lastOffsetX = label.tag * JSCREENW;
   
    // 标题label滚到到对应位置
    [self setTitleLabelPosition:label];
    // 设置下标线滚动到对应位置
    [self setUnderLinePosition:label];
    // 内容视图滚动到对应位置
    [self setContentScrollViewPosition:label];
    
    _selectIndex = label.tag;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.viewControllers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:idty forIndexPath:indexPath];
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    UIViewController *vc = self.viewControllers[indexPath.row];
    vc.view.frame = CGRectMake(0, 0, self.contentScrollView.frame.size.width, self.contentScrollView.frame.size.height);
    [cell.contentView addSubview:vc.view];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

/**
 * 滑动时调用, 会调用多次
 * 使用 scrollView.contentOffset 方法设置偏移量会在 偏移量设置完成 之后触发一次此方法
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 获取偏移量
    CGFloat offsetX = scrollView.contentOffset.x;

    NSInteger leftIndex = offsetX / JSCREENW;
    
    JMaterialTopTitleLabel *leftLabel = self.titleLabels[leftIndex];
    
    NSInteger rightIndex = leftIndex + 1;
    JMaterialTopTitleLabel *rightLabel = nil;
    if (rightIndex < self.titleLabels.count) {
        rightLabel = self.titleLabels[rightIndex];
    }
    
    // 下标线偏移
    [self setUnderLineOffset:offsetX leftLabel:leftLabel rightLabel:rightLabel];
    // 标题渐变
    [self setTitleColorGradientOffset:offsetX leftLabel:leftLabel rightLabel:rightLabel];
    
    self.lastOffsetX = offsetX;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger i = offsetX / JSCREENW;
    UILabel *label = self.titleLabels[i];
    [self setTitleLabelPosition:label];
    
    _selectIndex = label.tag;
}

#pragma mark -

// 标题颜色渐变效果
- (void)setTitleColorGradientOffset:(CGFloat)offsetX leftLabel:(JMaterialTopTitleLabel *)leftLabel rightLabel:(JMaterialTopTitleLabel *)rightLabel
{
    CGFloat rightSacle = offsetX / JSCREENW - leftLabel.tag;
    
    // 填充色渐变
    rightLabel.textColor = self.normalColor;
    rightLabel.fillColor = self.selectColor;
    rightLabel.progress = rightSacle;

    leftLabel.textColor = self.selectColor;
    leftLabel.fillColor = self.normalColor;
    leftLabel.progress = rightSacle;

    /*
    // 三色值渐变效果
    CGFloat startComponents[3];
    [self getRGBComponents:startComponents forColor:self.normalColor];
    CGFloat startR = startComponents[0];
    CGFloat startG = startComponents[1];
    CGFloat startB = startComponents[2];

    CGFloat endComponents[3];
    [self getRGBComponents:endComponents forColor:self.selectColor];
    CGFloat endR = endComponents[0];
    CGFloat endG = endComponents[1];
    CGFloat endB = endComponents[2];

    CGFloat r = endR - startR;
    CGFloat g = endG - startG;
    CGFloat b = endB - startB;
    
    CGFloat leftScale = 1 - rightSacle;

    UIColor *rightColor = [UIColor colorWithRed:startR + r * rightSacle green:startG + g * rightSacle blue:startB + b * rightSacle alpha:1];
    UIColor *leftColor = [UIColor colorWithRed:startR +  r * leftScale  green:startG +  g * leftScale  blue:startB +  b * leftScale alpha:1];

    rightLabel.textColor = rightColor;
    leftLabel.textColor = leftColor;
    */
}

// 下标线滑动效果
- (void)setUnderLineOffset:(CGFloat)offsetX leftLabel:(UILabel *)leftLabel rightLabel:(UILabel *)rightLabel {

    // x 坐标 差值
    CGFloat xDelta = rightLabel.frame.origin.x - leftLabel.frame.origin.x;
    
    // 宽度 差值
    CGFloat wDelta = rightLabel.bounds.size.width - leftLabel.bounds.size.width;
    
    // 滑动距离
    CGFloat offsetDelta = offsetX - self.lastOffsetX;
    
    // label x 坐标增量   n / xDelta = offsetDelta / JSCREENW
    CGFloat variationX = xDelta * offsetDelta / JSCREENW;
    
    // label 宽度 增量   n / wDelta = offsetDelta / JSCREENW
    CGFloat variationW = wDelta * offsetDelta / JSCREENW;
    
    CGRect frame = self.underLine.frame;
    frame.origin.x = frame.origin.x + variationX;
    frame.size.width = frame.size.width + variationW;
    self.underLine.frame = frame;
}

#pragma mark -

// 设置标题Label滚动到对应位置
- (void)setTitleLabelPosition:(UILabel *)label {
    
    for (JMaterialTopTitleLabel *lb in self.titleLabels) {
        lb.progress = 0; // 清除 label 填充色
        if (lb == label) continue;
        lb.textColor = self.normalColor;
    }
    label.textColor = self.selectColor;
    
    // 计算 label 显示在中点位置时 的偏移量
    CGFloat offsetX = label.center.x - _titleScrollView.frame.size.width * 0.5;
    if (offsetX < 0) {
        offsetX = 0;
    }
  
    CGFloat maxOffsetX = self.titleScrollView.contentSize.width - _titleScrollView.frame.size.width;
    
    if (maxOffsetX < 0) {
        maxOffsetX = 0;
    }
    if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    
    [self.titleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

// 设置下标线滚动到对应位置
- (void)setUnderLinePosition:(UILabel *)label {

    if (self.underLine.frame.size.width == 0) {
        CGRect frame = self.underLine.frame;
        frame.size.width = label.frame.size.width;
        self.underLine.frame = frame;
        
        CGPoint center = self.underLine.center;
        center.x = label.center.x;
        self.underLine.center = center;
        return;
    }
   
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.underLine.frame;
        frame.size.width = label.frame.size.width;
        self.underLine.frame = frame;
        
        CGPoint center = self.underLine.center;
        center.x = label.center.x;
        self.underLine.center = center;
    }];
}

// 设置内容视图滚动到对应位置
- (void)setContentScrollViewPosition:(UILabel *)label {
   
    NSInteger i = label.tag;
    CGFloat offsetX = i * JSCREENW;
    self.contentScrollView.contentOffset = CGPointMake(offsetX, 0);
}

#pragma mark -

// 获取颜色的三色值
- (void)getRGBComponents:(CGFloat [3])components forColor:(UIColor *)color {
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel,
                                                 1,
                                                 1,
                                                 8,
                                                 4,
                                                 rgbColorSpace,
                                                 1);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component] / 255.0f;
    }
}

@end
