//
//  FeThongSo.h
//  eSales
//
//  Created by Nghia Tran on 8/30/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCheckBoxView.h"

@interface FeThongSo : UIView <UITextFieldDelegate>


// Txb
@property (weak, nonatomic) IBOutlet UITextField *txbDuongDan;
@property (weak, nonatomic) IBOutlet UITextField *txbInternet;
@property (weak, nonatomic) IBOutlet UITextField *txbCucBo;

// Check Boz
@property (strong, nonatomic) SSCheckBoxView *checkBoxInternet;
@property (strong, nonatomic) SSCheckBoxView *checkBoxCucBo;
@property (strong, nonatomic) SSCheckBoxView *checkBox1;
@property (strong, nonatomic) SSCheckBoxView *checkBox2;
@property (strong, nonatomic) SSCheckBoxView *checkBox3;

// ACtion
- (IBAction)luuTapped:(id)sender;
- (IBAction)checkConnection:(id)sender;


@end
