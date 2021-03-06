//
//  HSQWaitSendGoodsViewController.m
//  LiTianDecoration
//
//  Created by administrator on 2018/5/26.
//  Copyright © 2018年 administrator. All rights reserved.
//

#import "HSQWaitSendGoodsViewController.h"
#import "HSQOrderListFirstCengModel.h"
#import "HSQAccountTool.h"
#import "HSQOrderGoodsListCell.h"
#import "HSQShopCarGoodsTypeListModel.h"
#import "HSQOrderGoodsListBgView.h"
#import "HSQStoreDetailViewController.h"
#import "HSQOrderDetailViewController.h"

@interface HSQWaitSendGoodsViewController ()<UITableViewDelegate,UITableViewDataSource,HSQOrderGoodsListCellDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) NSInteger currentPage; // 当前的页数

@property (nonatomic, strong) HSQNoDataView *noDataView;

@property (nonatomic, copy) NSString *keyword; // 搜索的关键字

@property (nonatomic, copy) NSString *totalPage; // 总页数

@end

@implementation HSQWaitSendGoodsViewController

-(NSMutableArray *)dataSource{
    
    if (_dataSource == nil) {
        
        self.dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (HSQNoDataView *)noDataView{
    
    if (!_noDataView) {
        
        _noDataView = [[HSQNoDataView alloc] initWithTitle:@"亲，还没有相关的订单额" imageName:@"WaitingForView" height:50 TopMargin:0];
    }
    return _noDataView;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = KViewBackGroupColor;
    
    // 1.创建tableView
    [self CreatTableView];
    
    // 2.添加刷新控件
    [self AddRefreshControls];
}

/**
 * @brief 创建tableView
 */
- (void)CreatTableView{
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - KSafeTopeHeight - KSafeBottomHeight - 50) style:(UITableViewStylePlain)];
    
    tableView.backgroundColor = [UIColor clearColor];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    [tableView registerNib:[UINib nibWithNibName:@"HSQOrderGoodsListCell" bundle:nil] forCellReuseIdentifier:@"HSQOrderGoodsListCell"];
    
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
}

/**
 * @brief 添加刷新控件
 */
- (void)AddRefreshControls{
    
    // 1.下拉加载更多的数据
    self.tableView.mj_header  = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(LoadNewWaitPayMoneryOrderListData)];
    
    [self.tableView.mj_header beginRefreshing];
    
    // 3.上啦加载更多的代码
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(LoadMoreWaitPayMoneryOrderData)];
}

/**
 * @brief 加载最新的订单数据
 */
- (void)LoadNewWaitPayMoneryOrderListData{
    
    [[HSQProgressHUDManger Manger] ShowLoadingDataFromeServer:@"" ToView:self.view IsClearColor:YES];
    
    // 0.清空数组
    [self.dataSource removeAllObjects];
    
    // 结束上啦
    [self.tableView.mj_footer endRefreshing];
    
    self.currentPage = 1;
    
    HSQAccount *account = [HSQAccountTool account];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = account.token;
    params[@"ordersState"] = @"pay";
    params[@"page"] = @(self.currentPage);
    if (self.keyword.length != 0)
    {
        params[@"keyword"] = self.keyword;
    }
    
    AFNetworkRequestTool *requestTool = [AFNetworkRequestTool shareRequestTool];
    
    [requestTool.manger POST:UrlAdress(KOrderListUrl) parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[HSQProgressHUDManger Manger] DismissProgressHUD];
        
        HSQLog(@"===订单数据===%@",responseObject);
        
        self.totalPage = [NSString stringWithFormat:@"%@",responseObject[@"datas"][@"pageEntity"][@"totalPage"]];
        
        if ([responseObject[@"code"] integerValue] == 200)
        {
            // 取出商品的数据
            [self QuChuGoodsDataFromeServer:responseObject];
        }
        else
        {
            NSString *errorString = [NSString stringWithFormat:@"%@",responseObject[@"datas"][@"error"]];
            
            [[HSQProgressHUDManger Manger] ShowDisplayFailedToLoadData:errorString SuperView:self.view];
        }
        
        [self.tableView.mj_header endRefreshing];
        
        [self.tableView reloadData];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        // 结束刷新
        [self.tableView.mj_header endRefreshing];
        
        [self.tableView addSubview:self.noDataView];
        
        // 提示数据请求失败
        [[HSQProgressHUDManger Manger] ShowProgressHUDPromptText:@"网络出现问题" SupView:self.view];
    }];
}

/**
 * @brief 加载更多的订单数据
 */
- (void)LoadMoreWaitPayMoneryOrderData{
    
    [self.tableView.mj_header endRefreshing];
    
    HSQAccount *account = [HSQAccountTool account];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = account.token;
    params[@"ordersState"] = @"pay";
    params[@"page"] = @(++self.currentPage);
    if (self.keyword.length != 0)
    {
        params[@"keyword"] = self.keyword;
    }
    
    AFNetworkRequestTool *requestTool = [AFNetworkRequestTool shareRequestTool];
    
    [requestTool.manger POST:UrlAdress(KOrderListUrl) parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[HSQProgressHUDManger Manger] DismissProgressHUD];
        
        HSQLog(@"===加载更多订单数据===%@",responseObject);
        
        if ([responseObject[@"code"] integerValue] == 200)
        {
            // 取出商品的数据
            [self QuChuGoodsDataFromeServer:responseObject];
        }
        else
        {
            NSString *errorString = [NSString stringWithFormat:@"%@",responseObject[@"datas"][@"error"]];
            
            [[HSQProgressHUDManger Manger] ShowDisplayFailedToLoadData:errorString SuperView:self.view];
        }
        
        [self.tableView.mj_footer endRefreshing];
        
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        // 结束刷新
        [self.tableView.mj_footer endRefreshing];
        
        // 提示数据请求失败
        [[HSQProgressHUDManger Manger] ShowProgressHUDPromptText:@"网络出现问题" SupView:self.view];
    }];
    
}

/**
 * @brief 取出商品的数据
 */
- (void)QuChuGoodsDataFromeServer:(NSDictionary *)responseObject{
    
    NSArray *ordersPayVoList = responseObject[@"datas"][@"ordersPayVoList"];
    
    if (ordersPayVoList.count == 0)
    {
        [self.tableView addSubview:self.noDataView];
    }
    else
    {
        // 中间的规格列表
        for (NSDictionary *dict in responseObject[@"datas"][@"ordersPayVoList"]){
            
            // 外层数据 有多少个分区
            HSQOrderListFirstCengModel *FirstModel = [[HSQOrderListFirstCengModel alloc] initWithDictionary:dict error:nil];
            
            FirstModel.ordersVoList = [NSMutableArray array];
            
            [self.dataSource addObject:FirstModel];
            
            // 内层数据 每个店铺有几个cell
            for (NSInteger i = 0; i < [dict[@"ordersVoList"] count] ; i++) {
                
                NSDictionary *ModelDiction = dict[@"ordersVoList"][i];
                
                HSQOrderListSecondCengModel *SecondModel = [[HSQOrderListSecondCengModel alloc] init];
                
                SecondModel.ordersGoodsVoList_array = [NSMutableArray array];
                
                [SecondModel setValuesForKeysWithDictionary:ModelDiction];
                
                [FirstModel.ordersVoList addObject:SecondModel];
                
                // 每个商品下有几种规格
                for (NSDictionary *ThirdDiction in ModelDiction[@"ordersGoodsVoList"]) {
                    
                    HSQShopCarGoodsTypeListModel *ThirdModel = [[HSQShopCarGoodsTypeListModel alloc] init];
                    
                    [ThirdModel setValuesForKeysWithDictionary:ThirdDiction];
                    
                    [SecondModel.ordersGoodsVoList_array addObject:ThirdModel];
                }
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.currentPage == self.totalPage.integerValue || self.totalPage.integerValue == 0)
    {
        self.tableView.mj_footer.hidden = YES;
    }
    else
    {
        self.tableView.mj_footer.hidden = NO;
    }
    
    self.noDataView.hidden = (self.dataSource.count != 0);
    
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    HSQOrderListFirstCengModel *FirstModel = self.dataSource[section];
    
    return FirstModel.ordersVoList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HSQOrderListFirstCengModel *FirstModel = self.dataSource[indexPath.section];
    
    HSQOrderListSecondCengModel *SecondModel = FirstModel.ordersVoList[indexPath.row];
    
    CGSize photosSize = [HSQOrderGoodsListBgView SizeWithDataModelArray:SecondModel.ordersGoodsVoList_array];
    
    if (SecondModel.showRefundWaiting.integerValue == 1)
    {
        return 125 + photosSize.height;
    }
    else
    {
        return 85 + photosSize.height;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HSQOrderGoodsListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HSQOrderGoodsListCell" forIndexPath:indexPath];
    
    HSQOrderListFirstCengModel *FirstModel = self.dataSource[indexPath.section];
    
    cell.model = FirstModel.ordersVoList[indexPath.row];
    
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HSQOrderListFirstCengModel *FirstModel = self.dataSource[indexPath.section];
    
    HSQOrderListSecondCengModel *secondModel = FirstModel.ordersVoList[indexPath.row];
    
    HSQOrderDetailViewController *OrderDetailVC = [[HSQOrderDetailViewController alloc] init];
    
    OrderDetailVC.ordersId = secondModel.ordersId;
    
    OrderDetailVC.OrderDetailTealSuccessModel = ^(id success) {
        
        [self.tableView.mj_header beginRefreshing];
    };
    
    [self.navigationController pushViewController:OrderDetailVC animated:YES];
    
}

/**
 * @brief 进入店铺
 */
- (void)JoinStoreButtonClickAction:(UIButton *)sender{
    
    HSQOrderGoodsListCell *cell = (HSQOrderGoodsListCell *)sender.superview.superview.superview;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    HSQOrderListFirstCengModel *FirstModel = self.dataSource[indexPath.section];
    
    HSQOrderListSecondCengModel *secondModel = FirstModel.ordersVoList[indexPath.row];
    
    HSQStoreDetailViewController *StoreVC = [[HSQStoreDetailViewController alloc] init];
    
    StoreVC.storeId = secondModel.storeId;
    
    [self.navigationController pushViewController:StoreVC animated:YES];
}
















@end
