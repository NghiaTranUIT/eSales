//
//  FeQueryCell.m
//  eSales
//
//  Created by MAC on 10/3/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeQueryCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FeQueryCell
@synthesize lblDiaChi=_lblDiaChi, lblMaKH=_lblMaKH, lblTenKH=_lblTenKH;
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
    _lblTenKH.layer.borderWidth = 1;
    _lblTenKH.layer.borderColor = [UIColor blackColor].CGColor;
    _lblMaKH.layer.borderWidth = 1;
    _lblMaKH.layer.borderColor = [UIColor blackColor].CGColor;
    _lblDiaChi.layer.borderWidth = 1;
    _lblDiaChi.layer.borderColor = [UIColor blackColor].CGColor;

}
@end
