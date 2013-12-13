//
//  FeBanHang.h
//  eSales
//
//  Created by Nghia Tran on 8/30/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCheckBoxView.h"

@interface FeBanHang : UIView
- (IBAction)luuTapped:(id)sender;

// CheckBox
@property (strong, nonatomic) SSCheckBoxView *checkBox1;
@property (strong, nonatomic) SSCheckBoxView *checkBox1_1;

@property (strong, nonatomic) SSCheckBoxView *checkBox2;
@property (strong, nonatomic) SSCheckBoxView *checkBox2_1;

@property (strong, nonatomic) SSCheckBoxView *checkBox3;
@property (strong, nonatomic) SSCheckBoxView *checkBox4;

@end
