//
//  FeThongTinDoiThuCell.m
//  eSales
//
//  Created by Nghia Tran on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeThongTinDoiThuCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FeThongTinDoiThuCell
@synthesize lblGhiChu = _lblGhiChu, lblGiaBan = _lblGiaBan, lblSLTB = _lblSLTB, lblTenSP = _lblTenSP;

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
    _lblGhiChu.layer.borderWidth = 1;
    _lblGhiChu.layer.borderColor = [UIColor blackColor].CGColor;
    _lblGiaBan.layer.borderWidth = 1;
    _lblGiaBan.layer.borderColor = [UIColor blackColor].CGColor;
    _lblSLTB.layer.borderWidth = 1;
    _lblSLTB.layer.borderColor = [UIColor blackColor].CGColor;
    _lblTenSP.layer.borderWidth = 1;
    _lblTenSP.layer.borderColor = [UIColor blackColor].CGColor;


}
-(void) setAllDelegateTextField:(id)sender
{
    _lblGhiChu.delegate = sender;
    _lblGiaBan.delegate = sender;
    _lblSLTB.delegate = sender;
}
@end
