//
//  FeTuoiNoCell.m
//  eSales
//
//  Created by Nghia Tran on 9/10/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeTuoiNoCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FeTuoiNoCell
@synthesize lblChuaToiHan = _lblChuaToiHan, lblHanMuc = _lblHanMuc, lblHD = _lblHD, lblQH15Ngay = _lblQH15Ngay, lblQH7Ngay = _lblQH7Ngay, lblQHTren15Ngay = _lblQHTren15Ngay;
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
    _lblChuaToiHan.layer.borderWidth = 1;
    _lblChuaToiHan.layer.borderColor = [UIColor blackColor].CGColor;
    _lblHanMuc.layer.borderWidth = 1;
    _lblHanMuc.layer.borderColor = [UIColor blackColor].CGColor;
    _lblHD.layer.borderWidth = 1;
    _lblHD.layer.borderColor = [UIColor blackColor].CGColor;
    _lblQH15Ngay.layer.borderWidth = 1;
    _lblQH15Ngay.layer.borderColor = [UIColor blackColor].CGColor;
    _lblQH7Ngay.layer.borderWidth = 1;
    _lblQH7Ngay.layer.borderColor = [UIColor blackColor].CGColor;
    _lblQHTren15Ngay.layer.borderWidth = 1;
    _lblQHTren15Ngay.layer.borderColor = [UIColor blackColor].CGColor;

    
}
@end
