//
//  HSQReturnGoodsViewController.m
//  LiTianDecoration
//
//  Created by administrator on 2018/4/30.
//  Copyright © 2018年 administrator. All rights reserved.
//

#import "HSQReturnGoodsViewController.h"
#import "HSQReturnGoodsListViewController.h"  // 退货
#import "HSQTouSuListViewController.h" // 投诉列表
#import "HSQReturnMoneryListViewController.h" // 退款

@interface HSQReturnGoodsViewController ()<UIScrollViewDelegate>

// 顶部的所有标签
@property (nonatomic, weak) UIView *titlesView;

// 标签栏底部的红色指示器
@property (nonatomic, weak) UIImageView *indicatorView;

// 当前选中的按钮
@property (nonatomic, weak) UIButton *selectedButton;

// 底部的所有内容
@property (nonatomic, weak) UIScrollView *contentView;

@end

@implementation HSQReturnGoodsViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = KViewBackGroupColor;
    
    // 1.初始化子控制器
    [self setupChildVces];
    
    // 2.设置顶部标题栏
    [self setupTopTitlesView];
    
    // 3.设置底布滚动控制器
    [self setupContentView];
    
    // 添加导航栏的item
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:KImageName(@"LeftBackIcon") style:(UIBarButtonItemStylePlain) target:self action:@selector(itemBackClick:)];
    
}

/**
 * @brief 返回按钮的点击
 */
- (void)itemBackClick:(UIBarButtonItem *)sender{
    
    if (self.index_Number.integerValue == 100 || self.index_Number.integerValue == 200 || self.index_Number.integerValue == 300)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/**
 * @brief 初始化子控制器
 */
- (void)setupChildVces{
    
    // 1.退款列表
    HSQReturnMoneryListViewController *ReturnMoneryListVC = [[HSQReturnMoneryListViewController alloc] init];
    ReturnMoneryListVC.title = @"退款列表";
    [self addChildViewController:ReturnMoneryListVC];
    
    // 2.退货列表
    HSQReturnGoodsListViewController *OningOrderVC = [[HSQReturnGoodsListViewController alloc] init];
    OningOrderVC.title = @"退货列表";
    [self addChildViewController:OningOrderVC];
    
    // 4.投诉列表
    HSQTouSuListViewController *ClosedGoodsVC = [[HSQTouSuListViewController alloc] init];
    ClosedGoodsVC.title = @"投诉列表";
    [self addChildViewController:ClosedGoodsVC];
}

/**
 * @brief 设置顶部标题栏
 */
- (void)setupTopTitlesView{
    
    // 标签栏整体
    UIView *titlesView = [[UIView alloc] init];
    titlesView.backgroundColor = [UIColor whiteColor];
    titlesView.mj_w = [UIScreen mainScreen].bounds.size.width;
    titlesView.mj_h = 50;
    titlesView.mj_y = 0;
    [self.view addSubview:titlesView];
    self.titlesView = titlesView;
    
    // 底部的红色指示器
    UIImageView *indicatorView = [[UIImageView alloc] init];
    indicatorView.backgroundColor = RGB(255, 83, 63);
    indicatorView.mj_h = 2;
    indicatorView.tag = -1;
    indicatorView.mj_y = titlesView.mj_h - indicatorView.mj_h;
    self.indicatorView = indicatorView;
    
    // 内部的子标签
    CGFloat width = titlesView.mj_w / self.childViewControllers.count;
    CGFloat height = titlesView.mj_h;
    for (NSInteger i = 0; i < self.childViewControllers.count; i++) {
        
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        button.tag = i;
        button.mj_h = height;
        button.mj_w = width;
        button.mj_x = i * width;
        UIViewController *vc = self.childViewControllers[i];
        [button setTitle:vc.title forState:UIControlStateNormal];
        
        [button setTitleColor:RGB(131, 131, 131) forState:UIControlStateNormal];
        
        [button setTitleColor:RGB(255, 83, 63) forState:UIControlStateDisabled];
        
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        
        [button addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [titlesView addSubview:button];
        
       // 默认点击了第一个按钮
            if (i == 0)
            {
                button.enabled = NO;
    
                self.selectedButton = button;
    
                // 让按钮内部的label根据文字内容来计算尺寸
                [button.titleLabel sizeToFit];
    
                self.indicatorView.mj_w = button.titleLabel.mj_w;
    
                self.indicatorView.centerX = button.centerX;
                
                self.navigationItem.title = button.titleLabel.text;
            }
    }
    
    [titlesView addSubview:indicatorView];
}

/**
 * @brief 顶部按钮的点击事件
 */
- (void)titleClick:(UIButton *)button{
    
    self.navigationItem.title = button.titleLabel.text;
    
    // 修改按钮状态
    self.selectedButton.enabled = YES;
    button.enabled = NO;
    self.selectedButton = button;
    
    // 动画
    [UIView animateWithDuration:0.25 animations:^{
        self.indicatorView.width = button.titleLabel.mj_w;
        self.indicatorView.centerX = button.centerX;
    }];
    
    // 滚动
    CGPoint offset = self.contentView.contentOffset;
    offset.x = button.tag * self.contentView.width;
    [self.contentView setContentOffset:offset animated:YES];
}

/**
 * @brief 设置底布滚动控制器
 */
- (void)setupContentView{
    
    // 不要自动调整inset
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIScrollView *contentView = [[UIScrollView alloc] init];
    
    CGFloat ScrollerHeight = CGRectGetMaxY(self.titlesView.frame);
    
    contentView.showsVerticalScrollIndicator = NO;
    
    contentView.showsHorizontalScrollIndicator = NO;
    
    contentView.frame = CGRectMake(0, ScrollerHeight, KScreenWidth, KScreenHeight - ScrollerHeight - KSafeTopeHeight - KSafeBottomHeight);
    
    contentView.delegate = self;
    
    contentView.pagingEnabled = YES;
    
    contentView.backgroundColor = KViewBackGroupColor;
    
    [self.view insertSubview:contentView atIndex:0];
    
    contentView.contentSize = CGSizeMake(contentView.mj_w * self.childViewControllers.count, 0);
    
    self.contentView = contentView;
    
    // 添加第一个控制器的view
    [self scrollViewDidEndScrollingAnimation:contentView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    // 当前的索引
    NSInteger index = scrollView.contentOffset.x / scrollView.mj_w;
    
    // 取出子控制器
    UIViewController *vc = self.childViewControllers[index];
    
    vc.view.mj_x = scrollView.contentOffset.x;
    
    vc.view.mj_y = 0; // 设置控制器view的y值为0(默认是20)
    
    vc.view.mj_h = scrollView.mj_h; // 设置控制器view的height值为整个屏幕的高度(默认是比屏幕高度少个20)
    
    vc.view.mj_w = KScreenWidth;
    
    [scrollView addSubview:vc.view];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [self scrollViewDidEndScrollingAnimation:scrollView];
    
    // 点击按钮
    NSInteger index = scrollView.contentOffset.x / scrollView.mj_w;
    
    [self titleClick:self.titlesView.subviews[index]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * @brief 100是从退款界面  200  退货界面  300 投诉界面
 */
- (void)setIndex_Number:(NSString *)index_Number{
    
    _index_Number = index_Number;
    
    if (index_Number.integerValue == 100)
    {
        [self titleClick:self.titlesView.subviews[0]];
    }
    else if (index_Number.integerValue == 200)
    {
        [self titleClick:self.titlesView.subviews[1]];
    }
    else if (index_Number.integerValue == 300)
    {
        [self titleClick:self.titlesView.subviews[2]];
    }
}



@end
