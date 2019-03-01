//
//  OWViewController.m
//  OWWaterFallLayout
//
//  Created by OneWang on 03/01/2019.
//  Copyright (c) 2019 OneWang. All rights reserved.
//

#import "OWViewController.h"
#import "WaterFallLayout.h"
#import "ShopCell.h"
#import "ShopModel.h"
#import <MJExtension/MJExtension.h>
#import "MJRefresh.h"

#define K_Screen_Width [UIScreen mainScreen].bounds.size.width


@interface OWViewController ()<UICollectionViewDataSource,
                               UICollectionViewDelegate,
                               WaterFallLayoutDelegate>

@property (weak, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *shopsArray;


@end

@implementation OWViewController

static NSString * const ID = @"shop";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1.初始化数据
    NSArray * shopArray = [ShopModel mj_objectArrayWithFilename:@"1.plist"];
    [self.shopsArray addObjectsFromArray:shopArray];
    
    //2.创建collectionview
    WaterFallLayout *layout = [[WaterFallLayout alloc] init];
    layout.delegate = self;
    layout.sectionInset = UIEdgeInsetsMake(10, 20, 30, 40);
    layout.columnMargin = 30;
    layout.rowMargin = 30;
    layout.columnsCount = 3;
    
    CGRect frame = CGRectMake(0, 20, self.view.bounds.size.width, self.view.frame.size.height - 20);
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor orangeColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerNib:[UINib nibWithNibName:@"ShopCell" bundle:nil] forCellWithReuseIdentifier:ID];
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeaderID];
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:FooterID];
    
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreShops)];
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshShops)];
}

- (void)loadMoreShops{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray * shopArray = [ShopModel mj_objectArrayWithFilename:@"1.plist"];
        [self.shopsArray addObjectsFromArray:shopArray];
        [self.collectionView reloadData];
        [self.collectionView.mj_footer endRefreshing];
    });
}

- (void)refreshShops{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray * shopArray = [ShopModel mj_objectArrayWithFilename:@"1.plist"];
        [self.shopsArray addObjectsFromArray:shopArray];
        [self.collectionView reloadData];
        [self.collectionView.mj_header endRefreshing];
    });
}

#pragma mark WaterFallLayoutDelegate
- (CGFloat)waterFallLayout:(WaterFallLayout *)waterFallLayout heightForWidth:(CGFloat)width atIndexPath:(NSIndexPath *)indexPath{
    ShopModel *shop = self.shopsArray[indexPath.item];
    return shop.h / shop.w * width;
}

/**  collectionView  headerView */
- (CGSize)waterflowLayout:(WaterFallLayout *)waterflowLayout sectionHeaderAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(K_Screen_Width, 60);
}

/**  collectionView  footerView */
- (CGSize)waterflowLayout:(WaterFallLayout *)waterflowLayout sectionFooterAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(K_Screen_Width, 40);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.shopsArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ShopCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    cell.shop = self.shopsArray[indexPath.item];
    return cell;
}

static NSString * const HeaderID = @"HeaderID";
static NSString * const FooterID = @"FooterID";
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeaderID forIndexPath:indexPath];
        header.backgroundColor = [UIColor redColor];
        return header;
    }else{
        UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:FooterID forIndexPath:indexPath];
        footer.backgroundColor = [UIColor blueColor];
        return footer;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"-------%ld-------%ld", (long)indexPath.section, (long)indexPath.item);
}

#pragma mark - setter and getter
- (NSMutableArray *)shopsArray{
    if (!_shopsArray) {
        _shopsArray = [NSMutableArray array];
    }
    return _shopsArray;
}


@end
