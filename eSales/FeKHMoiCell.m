//
//  FeKHMoiCell.m
//  eSales
//
//  Created by MAC on 9/19/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeKHMoiCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FeKHMoiCell
@synthesize txbTenKH=_txbTenKH, txbDiaChi=_txbDiaChi, txbLoaiBanHang=_txbLoaiBanHang, txbSTT=_txbSTT;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) awakeFromNib
{
    _txbTenKH.layer.borderColor = [UIColor blackColor].CGColor;
    _txbTenKH.layer.borderWidth = 1;
    
    _txbDiaChi.layer.borderColor = [UIColor blackColor].CGColor;
    _txbDiaChi.layer.borderWidth = 1;
    
    _txbLoaiBanHang.layer.borderColor = [UIColor blackColor].CGColor;
    _txbLoaiBanHang.layer.borderWidth = 1;
    
    _txbSTT.layer.borderColor = [UIColor blackColor].CGColor;
    _txbSTT.layer.borderWidth = 1;

}

@end
