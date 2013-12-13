//
//  FeKhachHangCell.m
//  eSales
//
//  Created by Nghia Tran on 9/3/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeKhachHangCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FeKhachHangCell
@synthesize txbMaKhachHang = _txbMaKhachHang, txbTenKhachHang = _txbTenKhachHang, txDiaChi = _txDiaChi;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) awakeFromNib
{
    _txbMaKhachHang.layer.borderColor = [UIColor blackColor].CGColor;
    _txbMaKhachHang.layer.borderWidth = 1;
    
    _txbTenKhachHang.layer.borderColor = [UIColor blackColor].CGColor;
    _txbTenKhachHang.layer.borderWidth = 1;
    
    _txDiaChi.layer.borderColor = [UIColor blackColor].CGColor;
    _txDiaChi.layer.borderWidth = 1;
    
}
@end
