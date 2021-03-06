//
//  HSQTopNavtionView.h
//  LiTianDecoration
//
//  Created by administrator on 2018/4/29.
//  Copyright © 2018年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HSQTopNavtionViewDelegate <NSObject>

- (void)TopNavtionViewButtonClickAction:(UIButton *)sender;

@end

@interface HSQTopNavtionView : UIView

/** 装有标题的数组*/
@property (nonatomic, strong) NSArray *TitlesArray;

/** 设置代理*/
@property (nonatomic, weak) id<HSQTopNavtionViewDelegate>delegate;

// 当前选中的按钮
@property (nonatomic, weak) UIButton *selectedButton;

// 标签栏底部的红色指示器
@property (nonatomic, weak) UIImageView *indicatorView;


@end
