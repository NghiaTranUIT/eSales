//
//  FeLoginViewController.h
//  eSales
//
//  Created by Nghia Tran on 8/22/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeLoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txbUsername;
@property (weak, nonatomic) IBOutlet UITextField *txbPassword;


- (IBAction)loginTapped:(id)sender;
- (IBAction)aboutUsTapped:(id)sender;
@end
