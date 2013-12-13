//
//  FeDetailCustNonTradeCell.m
//  eSales
//
//  Created by MAC on 10/3/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeDetailCustNonTradeCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FeDetailCustNonTradeCell
@synthesize lbl1=_lbl1, lbl2=_lbl2, lbl3=_lbl3;

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
    _lbl1.layer.borderWidth = 1;
    _lbl1.layer.borderColor = [UIColor blackColor].CGColor;
    _lbl2.layer.borderWidth = 1;
    _lbl2.layer.borderColor = [UIColor blackColor].CGColor;
    _lbl3.layer.borderWidth = 1;
    _lbl3.layer.borderColor = [UIColor blackColor].CGColor;
    
}

@end
