//
//  HSQStoreDetailViewController.m
//  LiTianDecoration
//
//  Created by administrator on 2018/5/11.
//  Copyright © 2018年 administrator. All rights reserved.
//

#define KHeadViewHeight  0.3 * KScreenWidth + 65

#import "HSQStoreDetailViewController.h"
#import "HSQShopIntroducedViewController.h"
#import "HSQAccountTool.h"
#import "HSQStoreDetailHomeHeadReusableView.h"
#import "HSQGoodsCollectionListCell.h"
#import "HSQStoreRecommendedCollectionViewCell.h"
#import "HSQStoreDetailHeadTitleReusableView.h"
#import "HSQStoreDetailDataTool.h"
#import "HSQAllGoodsModelTitleCollectionReusableView.h"
#import "HSQClassSecondGoodsListCell.h"
#import "JHHeaderFlowLayout.h"
#import "HSQStoreActivityListCollectionViewCell.h"
#import "HSQStoreSearchGoodsViewController.h"
#import "HSQAccountTool.h"
#import "HSQLoginViewController.h"
#import "HSQContactTheMerchantController.h"
#import "HSQFreeCouponRedemptionView.h"

@interface HSQStoreDetailViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,HSQStoreDetailHomeHeadReusableViewDelegate,HSQAllGoodsModelTitleCollectionReusableViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BottomViewLayOut;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic,strong) NSDictionary *datadiction;

@property (nonatomic,strong) NSMutableArray *dataSource;

@property (nonatomic,strong) NSMutableArray *GoodsSource;

@property (nonatomic, copy) NSString *ModelType;  //分区的标示

@property (nonatomic, assign) BOOL isGrid;

@property (nonatomic, copy) NSString *IsSelect_String;

@property (nonatomic, copy) NSString *sort;  // 排列顺序

@property (nonatomic, assign) NSInteger CurrentPage; // 页数

@property (nonatomic, strong) NSMutableArray *AllGoodsSource; // 全部的商品

@property (nonatomic, copy) NSString *totalPage; // 总页数

@property (nonatomic, strong) NSMutableArray *StoreActivitys; // 全部的商品

@property (nonatomic, strong) NSString *IsCollection; // 判断用户是否收藏

@end

@implementation HSQStoreDetailViewController

-(NSMutableArray *)dataSource{
    
    if (_dataSource == nil) {
        
        self.dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (NSMutableArray *)GoodsSource{
    
    if (_GoodsSource == nil) {
        
        self.GoodsSource = [NSMutableArray array];
    }
    
    return _GoodsSource;
}

- (NSMutableArray *)AllGoodsSource{
    
    if (_AllGoodsSource == nil) {
        
        self.AllGoodsSource = [NSMutableArray array];
    }
    
    return _AllGoodsSource;
}

- (NSMutableArray *)StoreActivitys{
    
    if (_StoreActivitys == nil) {
        
        self.StoreActivitys = [NSMutableArray array];
    }
    
    return _StoreActivitys;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = KViewBackGroupColor;
    
    self.BottomViewLayOut.constant = KSafeBottomHeight;
    
    self.datadiction = [NSDictionary dictionary];
    
    self.ModelType = @"1";
    
    self.isGrid = YES; // 默认列表视图
    
    // 添加头部的搜索框按钮视图
    [self AddHeadSearchBtnView];
    
    // 创建集合视图
    [self CreatCollectionView];
    
    // 添加刷新控件
    [self addCollectionRefView];
    
    // 请求店铺详情的数据
    [self RequestForDetailsOfTheStore];
  
    // 监听店铺介绍界面收藏按钮的点击
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeStoreCollectionState:) name:@"StoreCollectionStaeNotif" object:nil];
}

/**
 * @brief 添加头部的搜索框按钮视图
 */
- (void)AddHeadSearchBtnView{
    
    UIButton *SearchBar = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [SearchBar setTitle:@"搜索店铺商品" forState:(UIControlStateNormal)];
    SearchBar.titleLabel.font = [UIFont systemFontOfSize:14];
    [SearchBar setTitleColor:RGB(150, 150, 150) forState:(UIControlStateNormal)];
    [SearchBar setImage:[UIImage imageNamed:@"6DE36884-837C-44C3-B808-CE7F7D8C4FFA"] forState:(UIControlStateNormal)];
    [SearchBar setBackgroundImage:[UIImage ReturnAPictureOfStretching:@"7D99DFED-F3B6-4DB1-9F77-E24CA867DD17"] forState:(UIControlStateNormal)];
    SearchBar.frame = CGRectMake(0, 0, KScreenWidth * 0.7, 30);
    [SearchBar setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [SearchBar addTarget:self action:@selector(TopSearchBarClickAction:) forControlEvents:(UIControlEventTouchUpInside)];
    self.navigationItem.titleView = SearchBar;
}

/**
 * @brief 搜索按钮的点击事件
 */
- (void)TopSearchBarClickAction:(UIButton *)sender{
    
    HSQStoreSearchGoodsViewController *SearchBarVC = [[HSQStoreSearchGoodsViewController alloc] init];
    SearchBarVC.storeId = self.storeId;
    [self.navigationController pushViewController:SearchBarVC animated:YES];
    
}

/**
 * @brief 创建集合视图
 */
- (void)CreatCollectionView{
    
    JHHeaderFlowLayout *Layout = [[JHHeaderFlowLayout alloc] init];
    
    Layout.minimumLineSpacing = 1;  // 最小的行间距
    
    Layout.minimumInteritemSpacing = 1; // 最小的列间距
    
    CGFloat collectionHeight = KScreenHeight - KSafeBottomHeight - KSafeTopeHeight - 50;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, collectionHeight) collectionViewLayout:Layout];
    
    collectionView.backgroundColor = [UIColor clearColor];
    
    collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    collectionView.dataSource = self;
    
    collectionView.delegate = self;
    
    collectionView.showsVerticalScrollIndicator = NO;
    
    collectionView.showsHorizontalScrollIndicator = NO;
    
    [collectionView registerNib:[UINib nibWithNibName:@"HSQStoreDetailHomeHeadReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HSQStoreDetailHomeHeadReusableView"];

    [collectionView registerNib:[UINib nibWithNibName:@"HSQStoreDetailHeadTitleReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HSQStoreDetailHeadTitleReusableView"];
    
    [collectionView registerClass:[HSQAllGoodsModelTitleCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HSQAllGoodsModelTitleCollectionReusableView"];
    
    [collectionView registerClass:[HSQGoodsCollectionListCell class] forCellWithReuseIdentifier:@"HSQGoodsCollectionListCell"];
    
    [collectionView registerClass:[HSQClassSecondGoodsListCell class] forCellWithReuseIdentifier:@"HSQClassSecondGoodsListCell"];
    
    [collectionView registerClass:[HSQStoreActivityListCollectionViewCell class] forCellWithReuseIdentifier:@"HSQStoreActivityListCollectionViewCell"];
    
    [collectionView registerNib:[UINib nibWithNibName:@"HSQStoreRecommendedCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"HSQStoreRecommendedCollectionViewCell"];
    
    [self.view addSubview:collectionView];
    
    [self.view sendSubviewToBack:collectionView];
    
    self.collectionView = collectionView;
}

/**
 * @brief 请求店铺详情的数据
 */
- (void)RequestForDetailsOfTheStore{
    
    [[HSQProgressHUDManger Manger] ShowLoadingDataFromeServer:@"" ToView:self.view IsClearColor:YES];
    
    NSMutableDictionary *Params = [[HSQParameterTool shareParameterTool] StoreDetailsOfTheParameter:self.storeId];
    
    AFNetworkRequestTool *requestTool = [AFNetworkRequestTool shareRequestTool];
    
    [requestTool.manger POST:UrlAdress(KStoreHomePageUrl) parameters:Params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[HSQProgressHUDManger Manger] DismissProgressHUD];
        
        HSQLog(@"=店铺详情==%@",responseObject);
        if ([responseObject[@"code"] integerValue] == 200)
        {
            self.datadiction = responseObject[@"datas"];
            
            self.IsCollection = [NSString stringWithFormat:@"%@",responseObject[@"datas"][@"isFavorite"]];
            
            [self.dataSource addObjectsFromArray:responseObject[@"datas"][@"recGoodsList"]];
            
            [self.GoodsSource addObjectsFromArray:responseObject[@"datas"][@"storeNewList"]];
        }
        else
        {
            NSString *message = [NSString stringWithFormat:@"%@",responseObject[@"datas"][@"error"]];
            
            [[HSQProgressHUDManger Manger] ShowDisplayFailedToLoadData:message SuperView:self.view];
        }
        
        [self.collectionView reloadData];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[HSQProgressHUDManger Manger] ShowDisplayFailedToLoadData:@"数据加载失败" SuperView:self.view];
        
    }];
    
}

/**
 * @brief 添加刷新控件
 */
- (void)addCollectionRefView{
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(LoadNewAllGoodsDataFromeServer)];
    
    self.collectionView.mj_header.automaticallyChangeAlpha = YES;
    
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(LoadMoreAllGoodsDataFromeServer)];
    
    self.collectionView.mj_header.hidden = YES;
    
    self.collectionView.mj_footer.hidden = YES;
}

/**
 * @brief 加载最新的店铺的商品
 */
- (void)LoadNewAllGoodsDataFromeServer{
    
    self.CurrentPage = 1;
    
    [self.AllGoodsSource removeAllObjects];
    
    [self.collectionView.mj_footer endRefreshing];
    
    [[HSQProgressHUDManger Manger] ShowLoadingDataFromeServer:@"" ToView:self.view IsClearColor:YES];
    
    NSMutableDictionary *Params = [NSMutableDictionary dictionary];
    Params[@"storeId"] = self.storeId;
    Params[@"keyword"] = @"";
    Params[@"sort"] = self.sort;
    Params[@"page"] = @(self.CurrentPage);
    Params[@"discountId"] = @"";   // 折扣促销id
    Params[@"conformId"] = @"";  // 满优惠id
    Params[@"templateId"] = @"";  // 优惠券活动促销id

    AFNetworkRequestTool *requestTool = [AFNetworkRequestTool shareRequestTool];
    
    [requestTool.manger GET:UrlAdress(KSearchGoodsInStoreUrl) parameters:Params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[HSQProgressHUDManger Manger] DismissProgressHUD];
        
//        HSQLog(@"=全部商品==%@",responseObject);
        // 总页数
        self.totalPage = [NSString stringWithFormat:@"%@",responseObject[@"pageEntity"][@"totalPage"]];
        
        if ([responseObject[@"code"] integerValue] == 200)
        {
            [self.AllGoodsSource addObjectsFromArray:responseObject[@"datas"][@"goodsCommonList"]];
        }
        else
        {
            NSString *message = [NSString stringWithFormat:@"%@",responseObject[@"datas"][@"error"]];
            
            [[HSQProgressHUDManger Manger] ShowDisplayFailedToLoadData:message SuperView:self.view];
        }
        
        [self.collectionView.mj_header endRefreshing];
        
        [self.collectionView reloadData];
                
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self.collectionView.mj_header endRefreshing];
        
        [[HSQProgressHUDManger Manger] ShowDisplayFailedToLoadData:@"数据加载失败" SuperView:self.view];
        
    }];
}

/**
 * @brief 加载更多的店铺的商品
 */
- (void)LoadMoreAllGoodsDataFromeServer{
    
    if (self.totalPage.integerValue == self.CurrentPage || self.totalPage.integerValue == 0)
    {
        [self.collectionView.mj_footer endRefreshingWithNoMoreData];
    }
    else
    {
        [self.collectionView.mj_header endRefreshing];
        
        [[HSQProgressHUDManger Manger] ShowLoadingDataFromeServer:@"" ToView:self.view IsClearColor:YES];
        
        NSMutableDictionary *Params = [NSMutableDictionary dictionary];
        Params[@"storeId"] = self.storeId;
        Params[@"keyword"] = @"";
        Params[@"sort"] = self.sort;
        Params[@"page"] = @(++self.CurrentPage);
        Params[@"discountId"] = @"";   // 折扣促销id
        Params[@"conformId"] = @"";  // 满优惠id
        Params[@"templateId"] = @"";  // 优惠券活动促销id
        
        AFNetworkRequestTool *requestTool = [AFNetworkRequestTool shareRequestTool];
        
        [requestTool.manger GET:UrlAdress(KSearchGoodsInStoreUrl) parameters:Params progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            [[HSQProgressHUDManger Manger] DismissProgressHUD];
            
            if ([responseObject[@"code"] integerValue] == 200)
            {
                NSArray *array = responseObject[@"datas"][@"goodsCommonList"];
                
                [self.AllGoodsSource addObjectsFromArray:array];
            }
            else
            {
                [self.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
            
            [self.collectionView.mj_footer endRefreshing];
            
            [self.collectionView reloadData];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [self.collectionView.mj_footer endRefreshing];
            
            [[HSQProgressHUDManger Manger] ShowDisplayFailedToLoadData:@"数据加载失败" SuperView:self.view];
            
        }];
    }
    
}

/**
 * @brief 店铺活动的数据
 */
#warning TODO 店铺活动没有数据
- (void)requestStoreActivityDataFromServer{

    [[HSQProgressHUDManger Manger] ShowLoadingDataFromeServer:@"" ToView:self.view IsClearColor:YES];
    
    NSDictionary *params = @{@"storeId":self.storeId};
    
    AFNetworkRequestTool *RequestTool = [AFNetworkRequestTool shareRequestTool];
    
    [RequestTool.manger GET:UrlAdress(KStoreActivityUrl) parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[HSQProgressHUDManger Manger] DismissProgressHUD];
        
        HSQLog(@"=店铺活动==%@",responseObject);
        if ([responseObject[@"code"] integerValue] == 200)
        {
            [self.StoreActivitys addObjectsFromArray:responseObject[@"datas"][@"voucherTemplateList"]];
        }
        else
        {
            NSString *message = [NSString stringWithFormat:@"%@",responseObject[@"datas"][@"error"]];
            
            [[HSQProgressHUDManger Manger] ShowDisplayFailedToLoadData:message SuperView:self.view];
        }
        
         [self.collectionView reloadData];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[HSQProgressHUDManger Manger] ShowDisplayFailedToLoadData:@"数据加载失败" SuperView:self.view];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 * @brief 店铺介绍
 */
- (IBAction)StoreIntroductionButtonClickAction:(UIButton *)sender {
    
    HSQShopIntroducedViewController *ShopIntroducedVC = [[HSQShopIntroducedViewController alloc] init];
    
    ShopIntroducedVC.storeId = self.storeId;
    
    [self.navigationController pushViewController:ShopIntroducedVC animated:YES];
}

/**
 * @brief 免费领券
 */
- (IBAction)FreeCouponButtonClickAction:(UIButton *)sender {
    
    HSQFreeCouponRedemptionView *FreeCouponView = [HSQFreeCouponRedemptionView initFreeCouponRedemptionView];
    
    [FreeCouponView ShowFreeCouponRedemptionView];
}

/**
 * @brief 联系客服
 */
- (IBAction)ContactTheCustomerServiceButtonClick:(UIButton *)sender {
    
    HSQContactTheMerchantController *ContactTheMerchantVC = [[HSQContactTheMerchantController alloc] init];
    
    [self.navigationController pushViewController:ContactTheMerchantVC animated:YES];
}

#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    if (self.datadiction.allKeys.count == 0)
    {
        return 0;
    }
    else
    {
        HSQStoreDetailDataTool *StoreDetailTool = [HSQStoreDetailDataTool shareStoreDetailDataTool];
        
        if (self.ModelType.integerValue == 4)
        {
//            NSArray *conformList = self.datadiction[@"conformList"]; // 满优惠
            
            NSArray *discountList = self.datadiction[@"discountList"]; // 限时折扣
            
            return [StoreDetailTool ReturnCollectionSection:self.ModelType Array:self.StoreActivitys ZheKouArray:discountList];
        }
        else
        {
            return [StoreDetailTool ReturnCollectionSection:self.ModelType Array:self.GoodsSource ZheKouArray:nil];
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    HSQStoreDetailDataTool *StoreDetailTool = [HSQStoreDetailDataTool shareStoreDetailDataTool];

    if (self.ModelType.integerValue == 1)  // 店铺首页
    {
        return [StoreDetailTool numberOfItemsInSection:section dataSource:self.dataSource SecondArray:nil modelType:self.ModelType];
    }
    else  if (self.ModelType.integerValue == 2) // 全部商品
    {
        return [StoreDetailTool numberOfItemsInSection:section dataSource:self.AllGoodsSource  SecondArray:nil modelType:self.ModelType];
    }
    else  if (self.ModelType.integerValue == 3) // 商品上新
    {        
        return [StoreDetailTool numberOfItemsInSection:section dataSource:self.GoodsSource SecondArray:nil modelType:self.ModelType];
    }
    else
    {
        return [StoreDetailTool numberOfItemsInSection:section dataSource:nil SecondArray:nil modelType:self.ModelType];
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    HSQStoreDetailDataTool *StoreDetailTool = [HSQStoreDetailDataTool shareStoreDetailDataTool];
    
    return [StoreDetailTool referenceSizeForHeaderInSection:section modelType:self.ModelType];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    
    return CGSizeMake(0, 0);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionReusableView *reusableView = nil;
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        if (indexPath.section == 0)
        {
            HSQStoreDetailHomeHeadReusableView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HSQStoreDetailHomeHeadReusableView" forIndexPath:indexPath];
            
            headView.dataDiction = self.datadiction;
            
            headView.delegate = self;
            
            reusableView = headView;
        }
        else
        {
            if (self.ModelType.integerValue == 2) // 全部的商品
            {
                HSQAllGoodsModelTitleCollectionReusableView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HSQAllGoodsModelTitleCollectionReusableView" forIndexPath:indexPath];
                
                headView.delegate = self;
                
                reusableView = headView;
            }
            else
            {
                HSQStoreDetailHeadTitleReusableView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HSQStoreDetailHeadTitleReusableView" forIndexPath:indexPath];
                
                if (self.ModelType.integerValue == 1)  // 店铺首页
                {
                    headView.BgView.backgroundColor = [UIColor whiteColor];
                    
                    if (indexPath.section == 1)
                    {
                        headView.Title_Label.text = @"店铺排行榜";
                    }
                    else  if (indexPath.section == 2)
                    {
                        headView.Title_Label.text = @"店铺推荐";
                    }
                }
                else  if (self.ModelType.integerValue == 3) // 商品上新
                {
                    headView.BgView.backgroundColor = [UIColor clearColor];
                    
                    if (indexPath.section != 0)
                    {
                        NSDictionary *dicton = self.GoodsSource[indexPath.section - 1];
                        
                        headView.Title_Label.text = [NSString stringWithFormat:@"%@",dicton[@"updateTime"]];
                    }
                }
                else if (self.ModelType.integerValue == 4) // 店铺活动
                {
                    headView.BgView.backgroundColor = [UIColor whiteColor];
                    
                    NSDictionary *dict = self.StoreActivitys[indexPath.section];
                    
                    headView.Title_Label.text = [NSString stringWithFormat:@"%@",dict[@"templateTitle"]];
                }
                
                reusableView = headView;
            }
        }
    }
    if (kind == UICollectionElementKindSectionFooter)
    {
           reusableView = nil;
    }
    return reusableView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.ModelType.integerValue == 1)  // 店铺首页
    {
        HSQStoreDetailDataTool *StoreDetailTool = [HSQStoreDetailDataTool shareStoreDetailDataTool];
        
        return [StoreDetailTool sizeForItemAtIndexPath:indexPath modelType:self.ModelType];
    }
    else  if (self.ModelType.integerValue == 2) // 全部商品
    {
        if (self.isGrid)
        {
            return CGSizeMake((KScreenWidth - 2) / 2, (KScreenWidth - 2) / 2 + 75);
        }
        else
        {
            return CGSizeMake(KScreenWidth, 120);
        }
    }
    else  if (self.ModelType.integerValue == 3) // 商品上新
    {
        return CGSizeMake((KScreenWidth - 2)/2, (KScreenWidth - 2)/2);
    }
    else // 店铺活动
    {
        return CGSizeMake(KScreenWidth, 120);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.ModelType.integerValue == 1) // 店铺首页
    {
        if (indexPath.section == 1)
        {
            HSQStoreRecommendedCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HSQStoreRecommendedCollectionViewCell" forIndexPath:indexPath];
            
            cell.dataDiction = self.datadiction;
            
            return cell;
        }
        else
        {
            HSQGoodsCollectionListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HSQGoodsCollectionListCell" forIndexPath:indexPath];
            
            [cell.OrginPrice_label setHidden:YES];
            
            cell.StoreGoodsDiction = self.dataSource[indexPath.row];
            
            return cell;
        }
    }
    else if (self.ModelType.integerValue == 2) // 全部商品
    {
        HSQClassSecondGoodsListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HSQClassSecondGoodsListCell" forIndexPath:indexPath];
        
        cell.isGrid = _isGrid;
        
        cell.dataDiction = self.AllGoodsSource[indexPath.row];
        
        cell.DiscountBtn.hidden = YES;
        
        return cell;
    }
    else if (self.ModelType.integerValue == 3) // 商品上新
    {
        HSQGoodsCollectionListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HSQGoodsCollectionListCell" forIndexPath:indexPath];
        
        [cell.OrginPrice_label setHidden:YES];
                
        return cell;
    }
    else // 店铺活动
    {
        HSQStoreActivityListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HSQStoreActivityListCollectionViewCell" forIndexPath:indexPath];
        
        cell.dataDiction = self.StoreActivitys[indexPath.section];
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

/**
 * @brief 顶部店铺首页，全部商品，商品上新，店铺活动四个模块的点击
 */
- (void)TopModelViewButtonClickInStoreDetailHomeHeadReusableView:(UIButton *)sender{
    
    if ([sender.titleLabel.text isEqualToString:@"全部商品"])
    {
        self.collectionView.mj_header.hidden = NO;
        self.collectionView.mj_footer.hidden = NO;
    }
    else
    {
        self.collectionView.mj_header.hidden = YES;
        self.collectionView.mj_footer.hidden = YES;
    }
    
    if ([sender.titleLabel.text isEqualToString:@"店铺首页"])
    {
        self.ModelType = @"1";
    }
    else if ([sender.titleLabel.text isEqualToString:@"全部商品"])
    {
        self.ModelType = @"2";
        self.sort = @"default_desc";
        [self.collectionView.mj_header beginRefreshing];
    }
    else if ([sender.titleLabel.text isEqualToString:@"商品上新"])
    {
        self.ModelType = @"3";
    }
    else if ([sender.titleLabel.text isEqualToString:@"店铺活动"])
    {
        self.ModelType = @"4";
        [self requestStoreActivityDataFromServer];
    }
    
    [self.collectionView reloadData];
}

/**
 * @brief 顶部综合，价格，销量，布局等模块的筛选
 */
- (void)AllGoodsModelTitleCollectionReusableViewButtonClickAction:(UIButton *)sender{
    
    if (sender.tag == 3) // 布局
    {
        [self ChangeViewLayOut];
    }
    else if (sender.tag == 2) // 销量
    {
        if ([self.sort isEqualToString:@"sale_desc"]) // 销量从低到高
        {
            self.sort = @"sale_asc";
            [self.collectionView.mj_header beginRefreshing];
        }
        else
        {
            self.sort = @"sale_desc";
            [self.collectionView.mj_header beginRefreshing];
        }
    }
    else if (sender.tag == 1) // 价格
    {
        if ([self.sort isEqualToString:@"price_desc"]) // 价格从低到高
        {
            self.sort = @"price_asc";
            [self.collectionView.mj_header beginRefreshing];
        }
        else
        {
            self.sort = @"price_desc";
            [self.collectionView.mj_header beginRefreshing];
        }
    }
    else if (sender.tag == 0) // 综合
    {
        if (![self.sort isEqualToString:@"default_desc"])
        {
            self.sort = @"default_desc";
            [self.collectionView.mj_header beginRefreshing];
        }
    }
}

/**
 * @brief 改变控件的布局
 */
- (void)ChangeViewLayOut{
    
    if (self.isGrid == YES)
    {
        self.isGrid = NO;
    }
    else
    {
        self.isGrid = YES;
    }
    
    [self.collectionView reloadData];
}

/**
 * @brief 改变店铺的收藏状态
 */
- (void)ChangeStoreCollectionState:(NSNotification *)notif{
    
    // 请求店铺详情的数据，重新判断店铺的收藏状态
    [self RequestForDetailsOfTheStore];
}

/**
 * @brief 店铺头部收藏按钮的点击事件
 */
- (void)HeadViewCollectionButtonClickAction:(UIButton *)sender{
    
    HSQStoreDetailHomeHeadReusableView *HeadReusableView = (HSQStoreDetailHomeHeadReusableView *)sender.superview.superview;

    HSQAccount *account = [HSQAccountTool account];

    if (account.token.length == 0)  // 没有登录
    {
        HSQLoginViewController *LoginVC = [[HSQLoginViewController alloc] init];
        
        [self.navigationController pushViewController:LoginVC animated:YES];
    }
    else
    {
        // 该用户是否收藏了该店铺(1–是，0–否)
        if (self.IsCollection.integerValue == 0) // 没有收藏，点击收藏
        {
            [self UserCollectionStore:account.token HeadCell:HeadReusableView];
        }
        else if (self.IsCollection.integerValue == 1) // 收藏，点击取消收藏
        {
            [self UserCancelCollectionStore: account.token HeadCell:HeadReusableView];
        }
    }
}

/**
 * @brief 收藏店铺
 */
- (void)UserCollectionStore:(NSString *)token HeadCell:(HSQStoreDetailHomeHeadReusableView *)cell{
    
    [[HSQProgressHUDManger Manger] ShowLoadingDataFromeServer:@"" ToView:self.view IsClearColor:YES];
    
    NSDictionary *diction = @{@"storeId":self.storeId,@"token":token};
    
    AFNetworkRequestTool *requestTool = [AFNetworkRequestTool shareRequestTool];
    
    [requestTool.manger POST:UrlAdress(KCollectionStoreUrl) parameters:diction progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[HSQProgressHUDManger Manger] DismissProgressHUD];
        
        if ([responseObject[@"code"] integerValue] == 200)
        {
            self.IsCollection = @"1";
            
            cell.Collectionstate_Label.text = @"已收藏";
        }
        else
        {
            NSString *message = [NSString stringWithFormat:@"%@",responseObject[@"datas"][@"error"]];
            
            [[HSQProgressHUDManger Manger] ShowDisplayFailedToLoadData:message SuperView:self.view];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[HSQProgressHUDManger Manger] ShowDisplayFailedToLoadData:@"收藏店铺失败" SuperView:self.view];
        
    }];
}

/**
 * @brief 取消收藏店铺
 */
- (void)UserCancelCollectionStore:(NSString *)token HeadCell:(HSQStoreDetailHomeHeadReusableView *)cell{
    
    [[HSQProgressHUDManger Manger] ShowLoadingDataFromeServer:@"" ToView:self.view IsClearColor:YES];
    
    NSDictionary *diction = @{@"storeId":self.storeId,@"token":token};
    
    AFNetworkRequestTool *requestTool = [AFNetworkRequestTool shareRequestTool];
    
    [requestTool.manger POST:UrlAdress(KCancelCollectionStoreUrl) parameters:diction progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[HSQProgressHUDManger Manger] DismissProgressHUD];
        
        if ([responseObject[@"code"] integerValue] == 200)
        {
            self.IsCollection = @"0";
            
           cell.Collectionstate_Label.text = @"收藏";
        }
        else
        {
            NSString *message = [NSString stringWithFormat:@"%@",responseObject[@"datas"][@"error"]];
            
            [[HSQProgressHUDManger Manger] ShowDisplayFailedToLoadData:message SuperView:self.view];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[HSQProgressHUDManger Manger] ShowDisplayFailedToLoadData:@"取消收藏店铺失败" SuperView:self.view];
        
    }];
}



















@end
