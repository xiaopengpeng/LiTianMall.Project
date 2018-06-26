//
//  HSQGoodsModelView.h
//  LiTianDecoration
//
//  Created by administrator on 2018/5/14.
//  Copyright © 2018年 administrator. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HSQGoodsModelViewDelegate <NSObject>

-(void)hsqGoodsModelViewBottomBtnClickAction:(UIButton *)sender GoodsCount:(NSString *)Count Type:(NSString *)typeString goods_id:(NSString *)goodsId GoodsKunCun:(NSString *)goodsStorage goodsSpecString:(NSString *)goodsSpecString;

@end

@interface HSQGoodsModelView : UIView

/**
 * @brief 初始化视图
 */
+ (instancetype)initGoodsModelView;

/**
 * @brief 显示视图
 */
- (void)ShowGoodsModelAndPriceView;

/**
 * @brief 区分是拼团，还是单独购买 100代表是单独购买  200代表是拼团 300代表积分商品详情
 */
@property (nonatomic, copy) NSString *TypeString;

/**
 * @brief 100代表是从商品详情界面来的 200是代表从收藏列表过来的
 */
@property (nonatomic, assign) NSInteger Source;

/**
 * @brief 商品详情的规格数据
 */
@property (nonatomic, strong) NSDictionary *dataDiction;

/**
 * @brief 积分商品详情的规格数据
 */
@property (nonatomic, strong) NSDictionary *PointDatasDiction;

/**
 * @brief 设置代理
 */
@property (nonatomic, weak) id<HSQGoodsModelViewDelegate>delegate;

@end
