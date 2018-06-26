
//
//  HSQToPromoteViewController.m
//  LiTianDecoration
//
//  Created by administrator on 2018/4/13.
//  Copyright © 2018年 administrator. All rights reserved.
//

#import "HSQToPromoteViewController.h"
#import "HSQLoginHomeViewController.h"
#import "HSQToPromoteListCell.h"
#import "HSQGoodsDataListModel.h"
#import "HSQAccountTool.h"
#import "HSQPerfectInformationViewController.h"
#import "HSQPlatformAuditViewController.h"
#import "HSQMySelectionBankHomeViewController.h"  // 我的选品库首页
#import "HSQMobilePromotionProductsView.h"

@interface HSQToPromoteViewController ()<UITableViewDataSource,UITableViewDelegate,HSQToPromoteListCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *View_BottomMargin;

@property (nonatomic, strong) NSIndexPath *operatedCellIndexPath;

@property (nonatomic, strong) HSQToPromoteListCell *currentPlayingCell;

@property (assign, nonatomic) NSInteger CurrentPage; // 当前页数

@property (nonatomic, copy) NSString *totalPage;  // 总页数

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) NSDictionary *DataDiction;

@property (nonatomic, strong) HSQNoDataView *NoDataView; // 空界面

// 综合排序：空或不传；销量优先：sale_desc；价格从高到低：price_desc；价格从低到高：price_asc；人 气：comment_desc ; commission_desc:佣金比例高到低；diffusion_desc：推广量高到底；commission_desc：支出佣金高到底)
@property (nonatomic, copy) NSString *sort; // 排列方式

// 自营店铺-1 非自营店铺-0
@property (nonatomic, copy) NSString *own;

// 价格区间 0-0，必须以-为连接符
@property (nonatomic, copy) NSString *price;

// 促销类型(限时折扣：1)
@property (nonatomic, copy) NSString *promotion;

// 起批量
@property (nonatomic, copy) NSString *batch;

// 分类id
@property (nonatomic, copy) NSString *cat;

// 品牌id(多个用‘,’隔开，如：1,2,3,4,5。最多选择五个)
@property (nonatomic, copy) NSString *brand;

// 属性（形式“attributeId-attributeValueId:attributeValueId,attributeId- attributeValueId:attributeValueId”。每个属性的属性值最多选择五个
@property (nonatomic, copy) NSString *attr;

//  包邮-1 全部-0
@property (nonatomic, copy) NSString *express;

// 优惠券-1 全部-0
@property (nonatomic, copy) NSString *voucher;

// 佣金比例 （形式“1-100”）
@property (nonatomic, copy) NSString *commission;

// 销量
@property (nonatomic, copy) NSString *sellNum;

// 赠品-1 全部-0
@property (nonatomic, copy) NSString *gift;

// 选中商品的个数
@property (weak, nonatomic) IBOutlet UILabel *SelectGoodsCount_Label;

// 加入选品库的商品个数
@property (nonatomic, strong) NSMutableArray *SelectGoodsCount_array;

// 需要添加的商品
@property (nonatomic, strong) NSString *commonIds;

@end

@implementation HSQToPromoteViewController

-(NSMutableArray *)dataSource{
    
    if (_dataSource == nil) {
        
        self.dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

-(HSQNoDataView *)NoDataView{
    
    if (_NoDataView == nil) {
        
        self.NoDataView = [[HSQNoDataView alloc] initWithTitle:@"亲，没有相应的数据哦~" imageName:@"3-1P106112Q1-51" height:50 TopMargin:0];
    }
    
    return _NoDataView;
}

- (NSMutableArray *)SelectGoodsCount_array{
    
    if (_SelectGoodsCount_array == nil) {
        
        self.SelectGoodsCount_array = [NSMutableArray array];
    }
    
    return _SelectGoodsCount_array;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = KViewBackGroupColor;
    
    self.navigationItem.title = self.NavtionTitle;
    
    self.View_BottomMargin.constant = KSafeBottomHeight;
    
    self.DataDiction = [NSDictionary dictionary];
    
    [self.tableView registerClass:[HSQToPromoteListCell class] forCellReuseIdentifier:@"HSQToPromoteListCell"];
    
    // 综合排序
    self.sort = @"";
    
    // 请求推广分佣的数据
    [self AddRateRefuentView];
    
}

/**
 * @brief 添加推广分佣的刷新视图
 */
- (void)AddRateRefuentView{
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(LoadNewPromotionOfCommissionDataFromeServer)];
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(LoadMorePromotionOfCommissionDataFromeServer)];
    
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    
    [self.tableView.mj_header beginRefreshing];
    
}

/**
 * @brief 添加推广分佣的最新的数据
 */
- (void)LoadNewPromotionOfCommissionDataFromeServer{
    
    [self.tableView.mj_footer endRefreshing];
    
    [self.dataSource removeAllObjects];
    
    self.CurrentPage = 1;
    
    [[HSQProgressHUDManger Manger] ShowLoadingDataFromeServer:@"" ToView:self.view IsClearColor:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"client"] = @"app";
    params[@"page"] =  @(self.CurrentPage);
    params[@"pageSize"] = @"20";
    params[@"keyword"] = @"";
    params[@"sort"] = self.sort;
    params[@"own"] = self.own;
    params[@"price"] = self.price;
    params[@"promotion"] = self.promotion;
    params[@"batch"] = self.batch;
    params[@"cat"] = self.cat;
    params[@"brand"] = self.brand;
    params[@"attr"] = self.attr;
    params[@"express"] = self.express;
    params[@"voucher"] = self.voucher;
    params[@"commission"] = self.commission;
    params[@"sellNum"] = self.sellNum;
    params[@"gift"] = self.gift;
    
    AFNetworkRequestTool *requestTool = [AFNetworkRequestTool shareRequestTool];
    
    [requestTool.manger GET:UrlAdress(KPromotionSearchDataUrl) parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        HSQLog(@"===推广分佣的数据=%@",responseObject);
        [[HSQProgressHUDManger Manger] DismissProgressHUD];
        
        if ([responseObject[@"code"] integerValue] == 200)
        {
            self.DataDiction = responseObject[@"datas"];
            
            self.dataSource = [HSQGoodsDataListModel mj_objectArrayWithKeyValuesArray:responseObject[@"datas"][@"goodsList"]];
        }
        else
        {
            NSString *errorString = [NSString stringWithFormat:@"%@",responseObject[@"datas"][@"error"]];
            
            [[HSQProgressHUDManger Manger] ShowDisplayFailedToLoadData:errorString SuperView:self.view];
        }
        
        if (self.dataSource.count == 0)
        {
            [self.view addSubview:self.NoDataView];
        }
        
        [self.tableView.mj_header endRefreshing];
        
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self.tableView.mj_header endRefreshing];
        
        [self.tableView addSubview:self.NoDataView];
        
        [[HSQProgressHUDManger Manger] ShowProgressHUDPromptText:@"网络出问题啦！" SupView:self.view];
        
    }];
}

/**
 * @brief 添加推广分佣的更多的数据
 */
- (void)LoadMorePromotionOfCommissionDataFromeServer{
    
    [self.tableView.mj_header endRefreshing];
    
    [[HSQProgressHUDManger Manger] ShowLoadingDataFromeServer:@"" ToView:self.view IsClearColor:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"client"] = @"app";
    params[@"page"] =  @(++self.CurrentPage);
    params[@"pageSize"] = @"20";
    params[@"keyword"] = @"";
    params[@"sort"] = self.sort;
    params[@"own"] = self.own;
    params[@"price"] = self.price;
    params[@"promotion"] = self.promotion;
    params[@"batch"] = self.batch;
    params[@"cat"] = self.cat;
    params[@"brand"] = self.brand;
    params[@"attr"] = self.attr;
    params[@"express"] = self.express;
    params[@"voucher"] = self.voucher;
    params[@"commission"] = self.commission;
    params[@"sellNum"] = self.sellNum;
    params[@"gift"] = self.gift;
    
    AFNetworkRequestTool *requestTool = [AFNetworkRequestTool shareRequestTool];
    
    [requestTool.manger GET:UrlAdress(KPromotionSearchDataUrl) parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        HSQLog(@"===推广分佣的数据=%@",responseObject);
        [[HSQProgressHUDManger Manger] DismissProgressHUD];
        
        if ([responseObject[@"code"] integerValue] == 200)
        {
            self.DataDiction = responseObject[@"datas"];
            
            NSArray *goodsList = [HSQGoodsDataListModel mj_objectArrayWithKeyValuesArray:responseObject[@"datas"][@"goodsList"]];
            
            [self.dataSource addObject:goodsList];
        }
        else
        {
            NSString *errorString = [NSString stringWithFormat:@"%@",responseObject[@"datas"][@"error"]];
            
            [[HSQProgressHUDManger Manger] ShowDisplayFailedToLoadData:errorString SuperView:self.view];
        }
        
        [self.tableView.mj_footer endRefreshing];
        
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self.tableView.mj_footer endRefreshing];
        
        [[HSQProgressHUDManger Manger] ShowProgressHUDPromptText:@"网络出问题啦！" SupView:self.view];
        
    }];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.CurrentPage == self.totalPage.integerValue || self.totalPage.integerValue == 0)
    {
        self.tableView.mj_footer.hidden = YES;
    }
    else
    {
        self.tableView.mj_footer.hidden = NO;
    }
    
    self.NoDataView.hidden = (self.dataSource.count != 0);
    
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [self.tableView cellHeightForIndexPath:indexPath model:self.dataSource[indexPath.row] keyPath:@"model" cellClass:[HSQToPromoteListCell class] contentViewWidth:KScreenWidth];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [self.tableView cellHeightForIndexPath:indexPath model:self.dataSource[indexPath.row] keyPath:@"model" cellClass:[HSQToPromoteListCell class] contentViewWidth:KScreenWidth];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HSQToPromoteListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HSQToPromoteListCell" forIndexPath:indexPath];
    
    cell.delegate = self;
    
    self.operatedCellIndexPath = indexPath;
    
    cell.model = self.dataSource[indexPath.row];
    
    // 此步设置用于实现cell的frame缓存，可以让tableview滑动更加流畅
    [cell useCellFrameCacheWithIndexPath:indexPath tableView:tableView];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


/**
 * @brief 列表上立即选取按钮的点击
 */
- (void)AtOnceSelectButtonWithCellList:(UIButton *)sender{
    
    HSQToPromoteListCell *cell = (HSQToPromoteListCell *)sender.superview.superview;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    for (NSInteger i = 0; i < self.dataSource.count; i++) {
        
        HSQGoodsDataListModel *model = self.dataSource[i];
        
        if (i == indexPath.row)
        {
            model.IsSelectState = @"1";
        }
        else
        {
            model.IsSelectState = @"0";
        }
    }
    
    [self.tableView reloadData];
    
}

/**
 * @brief 背景视图上立即选取按钮的点击
 */
- (void)AtOnceSelectButtonWithBgViewClickAction:(UIButton *)sender{
    
    NSString *token = [HSQAccountTool account].token;
    
    if (token.length == 0) // 没有登录
    {
        HSQLoginHomeViewController *LoginVC = [[HSQLoginHomeViewController alloc] init];
        
        [self.navigationController pushViewController:LoginVC animated:YES];
    }
    else
    {
        HSQToPromoteListCell *cell = (HSQToPromoteListCell *)sender.superview.superview.superview;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        HSQGoodsDataListModel *model = self.dataSource[indexPath.row];
        
        [[HSQProgressHUDManger Manger] ShowLoadingDataFromeServer:@"" ToView:self.view IsClearColor:YES];
        
        NSDictionary *params = @{@"token":token,@"commonId":model.commonId};
        
        AFNetworkRequestTool *requestTool = [AFNetworkRequestTool shareRequestTool];
        
        [requestTool.manger POST:UrlAdress(KAddPromotionalItemUrl) parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [[HSQProgressHUDManger Manger] DismissProgressHUD];
            
            HSQLog(@"==立即选取的数据==%@",responseObject);
            if ([responseObject[@"code"] integerValue] == 200)
            {
                model.IsSelectState = @"0";
                
                model.IsJoinLibrary = 1;
                
                [self.SelectGoodsCount_array addObject:model.commonId];
                
                // 选中商品的数量
                [self CalculateTheNumberOfSelectedItems];
            }
            else
            {
                NSString *errorString = [NSString stringWithFormat:@"%@",responseObject[@"datas"][@"error"]];
                
                [[HSQProgressHUDManger Manger] ShowDisplayFailedToLoadData:errorString SuperView:self.view];
            }
            
            [self.tableView reloadData];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [[HSQProgressHUDManger Manger] ShowProgressHUDPromptText:KErrorPlacherString SupView:self.view];
            
        }];
    }
    

}

/**
 * @brief 背景视图上立即分享按钮的点击
 */
- (void)AtOnceShareButtonWithBgViewClickAction:(UIButton *)sender{
    
    
}

/**
 * @brief 我的选品库
 */
- (IBAction)MySelectionBankBtnClickAction:(UIButton *)sender {
    
    HSQAccount *account = [HSQAccountTool account];
    
    if (account.token.length == 0)
    {
        HSQLoginHomeViewController *LoginVC = [[HSQLoginHomeViewController alloc] init];
        
        [self.navigationController pushViewController:LoginVC animated:YES];
    }
    else
    {
        // 1.验证会员是否拥有推广资格
         [self RequestForEligibilityToPromoteWithSource:100];
    }
}

/**
 * @brief 加入选品库
 */
- (IBAction)AddToTheSelectionBankClickAction:(UIButton *)sender {
    
    HSQAccount *account = [HSQAccountTool account];
    
    if (account.token.length == 0)
    {
        HSQLoginHomeViewController *LoginVC = [[HSQLoginHomeViewController alloc] init];
        
        [self.navigationController pushViewController:LoginVC animated:YES];
    }
    else
    {
        // 1.验证会员是否拥有推广资格
        [self RequestForEligibilityToPromoteWithSource:200];
    }
}

/**
 * @brief 验证会员是否拥有推广资格
 */
- (void)RequestForEligibilityToPromoteWithSource:(NSInteger)source{
    
    NSString *token = [HSQAccountTool account].token;
    
    if (token.length != 0)
    {
        [[HSQProgressHUDManger Manger] ShowLoadingDataFromeServer:@"" ToView:self.view IsClearColor:YES];
        
        NSDictionary *params = @{@"token":token};
        
        AFNetworkRequestTool *requestTool = [AFNetworkRequestTool shareRequestTool];
        
        [requestTool.manger POST:UrlAdress(KGetMemberZiGeInfoUrl) parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [[HSQProgressHUDManger Manger] DismissProgressHUD];
            
            HSQLog(@"===请求是否拥有推广分佣的资格==%@",responseObject);
            
            if ([responseObject[@"code"] integerValue] == 200)
            {
                NSDictionary *datas = responseObject[@"datas"];
                
                if ([datas[@"distributorJoin"] isEqual:[NSNull null]]) // 表明该会员没有推广资格
                {
                    [self PromptNoPromotionQualification];
                }
                else
                {
                    // 10:新增，20：不同意，30 ：同意，90：清退
                    NSString *state = [NSString stringWithFormat:@"%@",datas[@"distributorJoin"][@"state"]];
                    
                    if (state.integerValue == 10) // 已经提交，但是没有出结果
                    {
                        [self PromptToPromoteTheCommissionHasBeenSubmittedInTheReviewStatus];
                    }
                    else if (state.integerValue == 20 || state.integerValue == 90) // 被拒绝，需要重新提交
                    {
                        [self ThePromotionQualificationRejectedAndNeedsToBeResubmitted:state.integerValue distributorJoin:datas[@"distributorJoin"]];
                    }
                    else if (state.integerValue == 30) // 已经拥有推广资格啦
                    {                        
                        if (source == 100) // 我的选品库
                        {
                            [self CheckMySelectionLibrary];
                        }
                        else // 加入选品库
                        {
                            [self JoinMySelectionLibrary];
                        }
                    }
                }
            }
            else if ([responseObject[@"code"] integerValue] == 400)
            {
                [self PromptNoPromotionQualification];
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [[HSQProgressHUDManger Manger] ShowProgressHUDPromptText:KErrorPlacherString SupView:self.view];
            
        }];
    }
}

/**
 * @brief 提示没有推广资格
 */
- (void)PromptNoPromotionQualification{
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"你还不是推广会员" preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *action01 = [UIAlertAction actionWithTitle:@"返回" style:(UIAlertActionStyleCancel) handler:nil];
    
    UIAlertAction *action02 = [UIAlertAction actionWithTitle:@"申请" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        HSQPerfectInformationViewController *PerfectInformationVC = [[HSQPerfectInformationViewController alloc] init];
        
        [self.navigationController pushViewController:PerfectInformationVC animated:YES];
        
    }];
    
    [alertVC addAction:action01];
    
    [alertVC addAction:action02];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

/**
 * @brief 提示推广分佣已提交，在审核状态
 */
- (void)PromptToPromoteTheCommissionHasBeenSubmittedInTheReviewStatus{
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"您已经提交了推广分佣的申请" preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *action01 = [UIAlertAction actionWithTitle:@"返回" style:(UIAlertActionStyleCancel) handler:nil];
    
    UIAlertAction *action02 = [UIAlertAction actionWithTitle:@"查看" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        HSQPlatformAuditViewController *PlatformAuditVC = [[HSQPlatformAuditViewController alloc] init];
        
        PlatformAuditVC.source = 100;
        
        PlatformAuditVC.reason = @"您的推广分佣申请已经提交请等待审核";
        
        [self.navigationController pushViewController:PlatformAuditVC animated:YES];
        
    }];
    
    [alertVC addAction:action01];
    
    [alertVC addAction:action02];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

/**
 * @brief 推广资格被拒绝，需要重新提交
 */
- (void)ThePromotionQualificationRejectedAndNeedsToBeResubmitted:(NSInteger)state distributorJoin:(NSDictionary *)distributorJoin{
    
    HSQPlatformAuditViewController *PlatformAuditVC = [[HSQPlatformAuditViewController alloc] init];
    
    PlatformAuditVC.source = 20;
    
    PlatformAuditVC.reason = [NSString stringWithFormat:@"您的推广分佣已被取消，取消原因：%@",distributorJoin[@"joininMessage"]];
    
    PlatformAuditVC.distributorJoin = distributorJoin;
    
    [self.navigationController pushViewController:PlatformAuditVC animated:YES];
}

/**
 * @brief 查看我的选品库
 */
- (void)CheckMySelectionLibrary{
    
    HSQMySelectionBankHomeViewController *MySelectionBankVC = [[HSQMySelectionBankHomeViewController alloc] init];
    
    [self.navigationController pushViewController:MySelectionBankVC animated:YES];

}

/**
 * @brief 加入选品库
 */
- (void)JoinMySelectionLibrary{
    
    HSQLog(@"===我的选中的商品==%@",self.commonIds);
    
    if (self.SelectGoodsCount_array.count == 0)
    {
        [[HSQProgressHUDManger Manger] ShowProgressHUDPromptText:@"请选择商品" SupView:self.view];
    }
    else
    {
        HSQMobilePromotionProductsView *PromotionProductsView = [HSQMobilePromotionProductsView initMobilePromotionProductsView];
        
        PromotionProductsView.ClickGroupSuccessBlock = ^(NSString *distributorFavoritesId) {
            
            [[HSQProgressHUDManger Manger] ShowLoadingDataFromeServer:@"" ToView:self.view IsClearColor:YES];
            
            NSDictionary *params = @{@"token":[HSQAccountTool account].token,@"favoritesId":distributorFavoritesId,@"commonIds":self.commonIds};
            
            AFNetworkRequestTool *requestTool = [AFNetworkRequestTool shareRequestTool];
            
            [requestTool.manger POST:UrlAdress(KAddPromotionalItemsInBulkUrl) parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                [[HSQProgressHUDManger Manger] DismissProgressHUD];
                
                HSQLog(@"==加入选品库==%@",responseObject);
                if ([responseObject[@"code"] integerValue] == 200)
                {
                    self.SelectGoodsCount_Label.text = @"已选取0/200个商品";
                    
                    [self.SelectGoodsCount_array removeAllObjects];
                }
                else
                {
                    NSString *errorString = [NSString stringWithFormat:@"%@",responseObject[@"datas"][@"error"]];
                    
                    [[HSQProgressHUDManger Manger] ShowDisplayFailedToLoadData:errorString SuperView:self.view];
                }
                
                [self.tableView reloadData];
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                [[HSQProgressHUDManger Manger] ShowProgressHUDPromptText:KErrorPlacherString SupView:self.view];
                
            }];
        };
        
        [PromotionProductsView ShowMobilePromotionProductsView];
    }
}

/**
 * @brief 选中商品的数量
 */
- (void)CalculateTheNumberOfSelectedItems{
    
    NSSet *set = [NSSet setWithArray:self.SelectGoodsCount_array];
    
    NSArray *New_Array = [set allObjects];
    
    self.commonIds = [New_Array componentsJoinedByString:@","];
    
    self.SelectGoodsCount_Label.text = [NSString stringWithFormat:@"已选取%ld/200个商品",New_Array.count];
}














































///**
// * @brief 计算cell是否移除屏幕
// */
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//
//    if (self.operatedCellIndexPath != nil) {
//
//        HSQToPromoteListCell *cell = (HSQToPromoteListCell *)[self.tableView cellForRowAtIndexPath:self.operatedCellIndexPath];
//
//        CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:self.operatedCellIndexPath];
//
//        CGRect  rectInSuperview = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
//
//       if ( rectInSuperview.origin.y > KScreenHeight - KSafeTopeHeight - KSafeBottomHeight - 95 || rectInSuperview.origin.y < 0 )
//        {
//            // 对已经移出屏幕的 Cell 做相应的处理
//            cell.IsHiddenBgView = YES;
//        }
//    }
//}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//
//    cell.startPlayVideoAction = ^(){
//
//        //        // 这个地方可以对上一次记录的 Cell 和 IndexPath 进行处理,比如我就可以把正在播放的视频停掉,类似这样
//        //        // 记录 当前被点击 cell 的位置和 indexPath
//        self.operatedCellIndexPath = indexPath;
//
//        self.currentPlayingCell = (HSQToPromoteListCell *)[self.tableView cellForRowAtIndexPath: indexPath];
//    };
//
//    // 这里我记录了 Cell 的 IndexPath 和 Cell
//    if ( self.operatedCellIndexPath != nil )
//    {
//        CGRect rectInTableView = [self.tableView rectForRowAtIndexPath: self.operatedCellIndexPath];
//
//        CGRect rectInSuperview = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
//
//        if ( rectInSuperview.origin.y > KScreenHeight || rectInSuperview.origin.y + rectInSuperview.size.height < 0 )
//        {
//            // 对已经移出屏幕的 Cell 做相应的处理
//            HSQLog(@"===我出来啦");
//        }
//        else
//        {
//            HSQLog(@"===我还在啊");
//        }
//    }
//}



@end
