//
//  FeTTPhanHoiCell.m
//  eSales
//
//  Created by MAC on 9/19/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeTTPhanHoiCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FeTTPhanHoiCell
@synthesize txbSTT=_txbSTT, txbLoai=_txbLoai, txbMoTa=_txbMoTa;

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
    _txbSTT.layer.borderColor = [UIColor blackColor].CGColor;
    _txbSTT.layer.borderWidth = 1;
    
    _txbMoTa.layer.borderColor = [UIColor blackColor].CGColor;
    _txbMoTa.layer.borderWidth = 1;
    
    _txbLoai.layer.borderColor = [UIColor blackColor].CGColor;
    _txbLoai.layer.borderWidth = 1;
    
}

@end
