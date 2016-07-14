//
//  ViewController.m
//  CustomUICollectionViewLayout
//
//  Created by LI on 16/3/9.
//  Copyright © 2016年 LI. All rights reserved.
//

#import "ViewController.h"
#import "WaterFallLayout.h"
#import "ShopCell.h"
#import "MJExtension.h"
#import "ShopModel.h"
#import "MJRefresh.h"

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,WaterFallLayoutDelegate>
@property (weak, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray *shops;

@end

@implementation ViewController

- (NSMutableArray *)shops
{
    if (_shops == nil) {
        _shops = [NSMutableArray array];
    }
    return _shops;
}

static NSString * const ID = @"shop";

- (void)viewDidLoad {
    [super viewDidLoad];

    //1.初始化数据
    NSArray * shopArray = [ShopModel objectArrayWithFilename:@"1.plist"];
    [self.shops addObjectsFromArray:shopArray];
    
    //2.创建collectionview
    WaterFallLayout *layout = [[WaterFallLayout alloc] init];
    layout.delegate = self;
//    layout.sectionInset = UIEdgeInsetsMake(100, 20, 30, 40);
//    layout.columnMargin = 30;
//    layout.rowMargin = 30;
//    layout.columnsCount = 3;
    
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerNib:[UINib nibWithNibName:@"ShopCell" bundle:nil] forCellWithReuseIdentifier:ID];
    
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    [self.collectionView addFooterWithTarget:self action:@selector(loadMoreShops)];

}

- (void)loadMoreShops{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray * shopArray = [ShopModel objectArrayWithFilename:@"1.plist"];
        [self.shops addObjectsFromArray:shopArray];
        [self.collectionView reloadData];
        [self.collectionView footerEndRefreshing];
    });
}

#pragma mark WaterFallLayoutDelegate
- (CGFloat)waterFallLayout:(WaterFallLayout *)waterFallLayout heightForWidth:(CGFloat)width atIndexPath:(NSIndexPath *)indexPath{
    ShopModel *shop = self.shops[indexPath.item];
    return shop.h / shop.w * width;
}

#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.shops.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShopCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    
    cell.shop = self.shops[indexPath.item];
    
    return cell;
}

@end
