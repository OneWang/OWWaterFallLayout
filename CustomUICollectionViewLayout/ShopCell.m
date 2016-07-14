//
//  ShopCell.m
//  CustomUICollectionViewLayout
//
//  Created by LI on 16/3/9.
//  Copyright © 2016年 LI. All rights reserved.
//

#import "ShopCell.h"
#import "UIImageView+WebCache.h"
#import "ShopModel.h"

@interface ShopCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end


@implementation ShopCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setShop:(ShopModel *)shop
{
    _shop = shop;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:shop.img] placeholderImage:[UIImage imageNamed:@"loading"]];
    
    self.priceLabel.text = shop.price;
}

@end
