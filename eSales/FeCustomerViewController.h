//
//  FeCustomerViewController.h
//  eSales
//
//  Created by Nghia Tran on 8/22/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeCustomerViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarCusttomer;
@property (weak, nonatomic) IBOutlet UILabel *lng;
@property (weak, nonatomic) IBOutlet UILabel *lat;
@property (strong, nonatomic) NSMutableDictionary *dictKHMoi;

- (IBAction)takeAvatar:(id)sender;
@end
