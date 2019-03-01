//
//  WaterFallLayout.m
//  CustomUICollectionViewLayout
//
//  Created by LI on 16/3/9.
//  Copyright © 2016年 LI. All rights reserved.
//  瀑布流重定义

#import "WaterFallLayout.h"

@interface WaterFallLayout ()

/** 这个字典用来存储每一列最大的Y值(每一列的高度) */
@property (strong, nonatomic) NSMutableDictionary<NSString *,NSNumber *> *maxYDict;
/** 存放所有的布局的属性 */
@property (strong, nonatomic) NSMutableArray<UICollectionViewLayoutAttributes *> *attrsArray;
/**  记录当前布局的 section 位置 */
@property (assign, nonatomic) NSInteger section;

@end

@implementation WaterFallLayout

- (instancetype)init{
    if (self = [super init]) {
        self.columnMargin = 10;
        self.rowMargin = 10;
        self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        self.columnsCount = 3;
        self.section = 0;
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

/**
 *  每次布局之前的准备
 */
- (void)prepareLayout{
    [super prepareLayout];
    
    //1. 清空字典中的最大的Y值
    for (int i = 0; i < self.columnsCount; i ++) {
        NSString * column = [NSString stringWithFormat:@"%d",i];
        self.maxYDict[column] = @(self.sectionInset.top);
    }
    
    //计算所有cell的属性
    self.section = 0;
    [self.attrsArray removeAllObjects];
    NSInteger sections = self.collectionView.numberOfSections;
    for (NSInteger index = 0; index < sections; index++) {
        // 2. 计算 sectionHeader 的属性
        UICollectionViewLayoutAttributes *headerAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:index]];
        [self.attrsArray addObject:headerAttrs];
        
        // 3. 计算所有 item 的属性
        NSInteger count = [self.collectionView numberOfItemsInSection:index];
        for (int i = 0; i < count; i++) {
            UICollectionViewLayoutAttributes *itemAttrs = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:index]];
            [self.attrsArray addObject:itemAttrs];
        }
        
        // 4. 计算 sectionFooter 的属性
        UICollectionViewLayoutAttributes *footerAttrs = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:0 inSection:index]];
        [self.attrsArray addObject:footerAttrs];
    }
}

//返回indexpath这个位置Item 的布局属性
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    //假设最短的那一列是第0列
    __block NSString *minColumn = @"0";
    //找出最短的那一列
    [self.maxYDict enumerateKeysAndObjectsUsingBlock:^(NSString * column, NSNumber * maxY, BOOL * _Nonnull stop) {
        if ([maxY floatValue] < [self.maxYDict[minColumn] floatValue]) {
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

/** 返回一行对应的视图 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {   // 返回头部视图
        return [self attributesForHeaderAtIndexPath:indexPath];
    } else {    // 返回底部视图
        return [self attributesForFooterAtIndexPath:indexPath];
    }
}

//返回 rect 范围内的布局属性
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    return self.attrsArray;
}

//返回所有的尺寸
- (CGSize)collectionViewContentSize{
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

/** 获得缓存字典中最大的 Y 值 */
- (CGFloat)getMaxY {
    __block NSString *maxColumn = @"0";
    [self.maxYDict enumerateKeysAndObjectsUsingBlock:^(NSString *column, NSNumber *maxY, BOOL *stop) {
        if ([maxY floatValue] > [self.maxYDict[maxColumn] floatValue]) {
            maxColumn = column;
        }
    }];
    return [self.maxYDict[maxColumn] floatValue];
}

/** 更新缓存字典中最大的 Y 值 */
- (void)updateMaxY:(CGFloat)maxY {
    for (NSInteger i = 0; i < self.columnsCount; i ++) {
        NSString *column = [NSString stringWithFormat:@"%ld", (long)i];
        self.maxYDict[column] = @(maxY);
    }
}

/** 头部视图 */
- (UICollectionViewLayoutAttributes *)attributesForHeaderAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
    CGSize headerSize = CGSizeZero;
    if ([self.delegate respondsToSelector:@selector(waterflowLayout:sectionHeaderAtIndexPath:)]) {
        headerSize = [self.delegate waterflowLayout:self sectionHeaderAtIndexPath:indexPath];
    }
    
    CGFloat x = (self.collectionView.frame.size.width - headerSize.width) * 0.5;
    // 获得当前组最大的 y 值
    CGFloat maxY = [self getMaxY];
    
    // collectionView有多组, 如果这次布局的 indePath.section 和上次self.section的不同, 就要更新布局的最大 Y 值
    if (self.section != indexPath.section) {
        attrs.frame = CGRectMake(x, maxY + self.sectionInset.top, headerSize.width, headerSize.height);
        // 将下一组的初始 Y 值更新
        CGFloat newMaxY = CGRectGetMaxY(attrs.frame);
        [self updateMaxY:newMaxY];
        self.section = indexPath.section;
    } else {    // collectionView有多组, 第一次布局, 将所有的高度更新为头视图的高度
        attrs.frame = CGRectMake(x, maxY , headerSize.width, headerSize.height);
        
        [self updateMaxY:CGRectGetMaxY(attrs.frame)];
    }
    return attrs;
}

/** 底部视图 */
- (UICollectionViewLayoutAttributes *)attributesForFooterAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:indexPath];
    CGSize footerSize = CGSizeZero;
    if ([self.delegate respondsToSelector:@selector(waterflowLayout:sectionFooterAtIndexPath:)]) {
        footerSize = [self.delegate waterflowLayout:self sectionFooterAtIndexPath:indexPath];
    }
    
    CGFloat x = (self.collectionView.frame.size.width - footerSize.width) * 0.5;
    
    CGFloat maxY = [self getMaxY];
    attrs.frame = CGRectMake(x, maxY + self.sectionInset.bottom, footerSize.width, footerSize.height);
    
    // 更新当前行的最大 Y 值
    [self updateMaxY:CGRectGetMaxY(attrs.frame)];
    return attrs;
}

#pragma mark - setter and geter
- (NSMutableDictionary<NSString *,NSNumber *> *)maxYDict{
    if (!_maxYDict) {
        _maxYDict = [NSMutableDictionary dictionary];
    }
    return _maxYDict;
}

- (NSMutableArray<UICollectionViewLayoutAttributes *> *)attrsArray{
    if (!_attrsArray) {
        _attrsArray = [NSMutableArray array];
    }
    return _attrsArray;
}

@end
