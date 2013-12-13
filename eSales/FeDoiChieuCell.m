//
//  FeDoiChieuCell.m
//  eSales
//
//  Created by VoVu on 9/28/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeDoiChieuCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FeDoiChieuCell
@synthesize lblThanhToan=_lblThanhToan, lblDoanhSo=_lblDoanhSo, lblDienGiai=_lblDienGiai, lblNgay=_lblNgay, lblSoHD=_lblSoHD, lblSoThamChieu=_lblSoThamChieu;

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
    _lblSoThamChieu.layer.borderWidth = 1;
    _lblSoThamChieu.layer.borderColor = [UIColor blackColor].CGColor;
    _lblThanhToan.layer.borderWidth = 1;
    _lblThanhToan.layer.borderColor = [UIColor blackColor].CGColor;
    _lblSoHD.layer.borderWidth = 1;
    _lblSoHD.layer.borderColor = [UIColor blackColor].CGColor;
    _lblNgay.layer.borderWidth = 1;
    _lblNgay.layer.borderColor = [UIColor blackColor].CGColor;
    _lblDoanhSo.layer.borderWidth = 1;
    _lblDoanhSo.layer.borderColor = [UIColor blackColor].CGColor;
    _lblDienGiai.layer.borderWidth = 1;
    _lblDienGiai.layer.borderColor = [UIColor blackColor].CGColor;
}
@end
