//
//  FeSettingViewController.h
//  eSales
//
//  Created by Nghia Tran on 8/30/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCheckBoxView.h"
#import "FeThongSo.h"
#import "FeBanHang.h"
@protocol FeSettingDelegate;

@interface FeSettingViewController : UIViewController <UITextFieldDelegate>
// Tab
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tabTaiKhoan;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tabThongSo;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tabBanHang;
- (IBAction)tabTaiKhoanTapped:(id)sender;
- (IBAction)tabThongSoTapped:(id)sender;
- (IBAction)tabBanHangTapped:(id)sender;

// Checkbox ThayDoiDaiKhoan
@property (strong, nonatomic) SSCheckBoxView *checkBoxThayDoiTK;
@property (strong, nonatomic) SSCheckBoxView *checkBoxThayDoiMatKhau;

// Txb
@property (strong, nonatomic) IBOutlet UITextField *txbSlsperID;
@property (strong, nonatomic) IBOutlet UITextField *txbBrandID;
@property (strong, nonatomic) IBOutlet UITextField *txbMatKhau;

- (IBAction)luuTapped:(id)sender;

// Main View
@property (strong, nonatomic) IBOutlet UIView *mainViewTaiKhoan;
@property (strong, nonatomic) UIView *mainViewThongSo;
@property (strong, nonatomic) UIView *mainViewBanHang;


@property (weak, nonatomic) id delegate;
@end

@protocol FeSettingDelegate <NSObject>

-(void) FeSettingDelegateShouldLogout:(FeSettingViewController *) sender;

@end