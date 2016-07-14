//
//  WaterFallLayout.m
//  CustomUICollectionViewLayout
//
//  Created by LI on 16/3/9.
//  Copyright © 2016年 LI. All rights reserved.
//

#import "WaterFallLayout.h"

/** 每一列之间的间距 */
//static const CGFloat ColumnMargin = 10;
/** 每一行之间的间距 */
//static const CGFloat RowMargin = ColumnMargin;

@interface WaterFallLayout ()
/** 这个字典用来存储每一列最大的Y值(每一列的高度) */
@property (strong, nonatomic) NSMutableDictionary *maxYDict;
/** 存放所有的布局的属性 */
@property (strong, nonatomic) NSMutableArray *attrsArray;

@end

@implementation WaterFallLayout

- (NSMutableDictionary *)maxYDict
{
    if (_maxYDict == nil) {
        _maxYDict = [NSMutableDictionary dictionary];
    }
    return _maxYDict;
}

- (NSMutableArray *)attrsArray
{
    if (!_attrsArray) {
        _attrsArray = [NSMutableArray array];
    }
    return _attrsArray;
}


- (instancetype)init
{
    if (self = [super init]) {
        self.columnMargin = 10;
        self.rowMargin = 10;
        self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        self.columnsCount = 3;
    }
    return self;
}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}
/**
 *  每次布局之前的准备
 */
- (void)prepareLayout
{
    [super prepareLayout];
    
    //清空字典中的最大的Y值
    for (int i = 0; i < self.columnsCount; i ++) {
        NSString * column = [NSString stringWithFormat:@"%d",i];
        self.maxYDict[column] = @(self.sectionInset.top);
    }
    
    //计算所有cell的属性
    [self.attrsArray removeAllObjects];
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < count; i ++) {
        UICollectionViewLayoutAttributes * attributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        [self.attrsArray addObject:attributes];
    }

}
//返回indexpath这个位置Item 的布局属性
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //假设最短的那一列是第0列
    __block NSString * minColumn = @"0";
    //找出最短的那一列
    [self.maxYDict enumerateKeysAndObjectsUsingBlock:^(NSString * column, NSNumber * maxY, BOOL * _Nonnull stop) {
        if ([maxY floatValue]< [self.maxYDict[minColumn] floatValue]) {
            minColumn = column;
        }
    }];
    
    //计算尺寸
    CGFloat width = (self.collectionView.frame.size.width - self.sectionInset.left - self.sectionInset.right - (self.columnsCount - 1) * self.columnMargin) / self.columnsCount;
    CGFloat height = [self.delegate waterFallLayout:self heightForWidth:width atIndexPath:indexPath];
    
    //计算位置
    CGFloat x = self.sectionInset.left + (width + self.rowMargin) * [minColumn intValue];
    CGFloat y = [self.maxYDict[minColumn] floatValue] + self.rowMargin;
    
    //更新这一列的最大y值
    self.maxYDict[minColumn] = @(y + height);
    
    //创建属性
    UICollectionViewLayoutAttributes * attri = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attri.frame = CGRectMake(x, y, width, height);
    
    return attri;
}
//返回 rect 范围内的布局属性
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.attrsArray;
}
//返回所有的尺寸
- (CGSize)collectionViewContentSize
{
    //假设最短的那一列是第0列
    __block NSString * maxColumn = @"0";
    //找出最短的那一列
    [self.maxYDict enumerateKeysAndObjectsUsingBlock:^(NSString * column, NSNumber * maxY, BOOL * _Nonnull stop) {
        if ([maxY floatValue] > [self.maxYDict[maxColumn] floatValue]) {
            maxColumn = column;
        }
    }];
    return CGSizeMake(0, [self.maxYDict[maxColumn] floatValue]+ self.sectionInset.bottom);
}

@end
