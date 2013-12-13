//
//  FeNhaPhanPhoiViewController.h
//  eSales
//
//  Created by Nghia Tran on 8/23/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeNhaPhanPhoiViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txbNhaPhanPhoi1;
@property (weak, nonatomic) IBOutlet UITextField *txbNhaPhanPhoi2;
@property (weak, nonatomic) IBOutlet UITextField *txbNhaPhanPhoi3;
@property (weak, nonatomic) IBOutlet UITextField *txbNhaPhanPhoi4;
@property (weak, nonatomic) IBOutlet UITextField *txbNhaPhanPhoi5;
@property (strong, nonatomic) NSMutableDictionary *dictKHMoi;

- (IBAction)luuTapped:(id)sender;
@end
