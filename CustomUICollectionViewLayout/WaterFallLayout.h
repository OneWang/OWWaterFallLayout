//
//  WaterFallLayout.h
//  CustomUICollectionViewLayout
//
//  Created by LI on 16/3/9.
//  Copyright © 2016年 LI. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WaterFallLayout;
@protocol WaterFallLayoutDelegate <NSObject>

- (CGFloat)waterFallLayout:(WaterFallLayout *)waterFallLayout heightForWidth:(CGFloat)width atIndexPath:(NSIndexPath *)indexPath;

@end

@interface WaterFallLayout : UICollectionViewLayout

@property (assign, nonatomic) UIEdgeInsets sectionInset;

/** 每一列之间的间距 */
@property (nonatomic, assign) CGFloat columnMargin;
/** 每一行之间的间距 */
@property (nonatomic, assign) CGFloat rowMargin;

/** 显示多少列 */
@property (nonatomic, assign) int columnsCount;

@property (weak, nonatomic) id<WaterFallLayoutDelegate> delegate;


@end
