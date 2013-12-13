//
//  FeDonHangCell.m
//  eSales
//
//  Created by MAC on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeDonHangCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FeDonHangCell
@synthesize txbMaKH=_txbMaKH, txbTongSL=_txbTongSL, txbTongTien=_txbTongTien;

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
    _txbMaKH.layer.borderColor = [UIColor blackColor].CGColor;
    _txbMaKH.layer.borderWidth = 1;
    
    _txbTongSL.layer.borderColor = [UIColor blackColor].CGColor;
    _txbTongSL.layer.borderWidth = 1;
    
    _txbTongTien.layer.borderColor = [UIColor blackColor].CGColor;
    _txbTongTien.layer.borderWidth = 1;
    
    _txbTenKH.layer.borderColor = [UIColor blackColor].CGColor;
    _txbTenKH.layer.borderWidth = 1;
    
    _txbDHSo.layer.borderColor = [UIColor blackColor].CGColor;
    _txbDHSo.layer.borderWidth = 1;
}

@end
