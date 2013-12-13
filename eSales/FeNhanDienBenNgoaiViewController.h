//
//  FeNhanDienBenNgoaiViewController.h
//  eSales
//
//  Created by Nghia Tran on 9/10/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeNhanDienBenNgoaiViewController : UIViewController <UITextFieldDelegate,UIImagePickerControllerDelegate,UIPopoverControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txbGhiChu;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;

@property (weak, nonatomic) IBOutlet UITextField *txbChiTietGhiChu;

- (IBAction)btnChupHinhTapped:(id)sender;
- (IBAction)btnLuuTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@end
