//
//  FeCongViecThucHienCell.m
//  eSales
//
//  Created by MAC on 10/3/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeCongViecThucHienCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FeCongViecThucHienCell
@synthesize lblCheckbox=_lblCheckbox, lblChupHinh=_lblChupHinh, lblGhiChu=_lblGhiChu, lblTenCongViec=_lblTenCongViec;

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
    _lblCheckbox.layer.borderWidth = 1;
    _lblCheckbox.layer.borderColor = [UIColor blackColor].CGColor;
    _lblChupHinh.layer.borderWidth = 1;
    _lblChupHinh.layer.borderColor = [UIColor blackColor].CGColor;
    _lblGhiChu.layer.borderWidth = 1;
    _lblGhiChu.layer.borderColor = [UIColor blackColor].CGColor;
    _lblTenCongViec.layer.borderWidth = 1;
    _lblTenCongViec.layer.borderColor = [UIColor blackColor].CGColor;
}
@end
