//
//  GhiNhanTongTienCell.m
//  eSales
//
//  Created by Nghia Tran on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "GhiNhanTongTienCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation GhiNhanTongTienCell
@synthesize lblDienGiai = _lblDienGiai, lblGiaban = _lblGiaban, lblSI = _lblSI, lblSoLuongBan = _lblSoLuongBan, lblThanhTien = _lblThanhTien;

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
    _lblDienGiai.layer.borderColor = [UIColor blackColor].CGColor;
    _lblDienGiai.layer.borderWidth = 1;
    _lblGiaban.layer.borderColor = [UIColor blackColor].CGColor;
    _lblGiaban.layer.borderWidth = 1;
    _lblSI.layer.borderColor = [UIColor blackColor].CGColor;
    _lblSI.layer.borderWidth = 1;
    _lblSoLuongBan.layer.borderColor = [UIColor blackColor].CGColor;
    _lblSoLuongBan.layer.borderWidth = 1;
    _lblThanhTien.layer.borderColor = [UIColor blackColor].CGColor;
    _lblThanhTien.layer.borderWidth = 1;
}


@end
