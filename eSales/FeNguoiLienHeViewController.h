//
//  FeNguoiLienHeViewController.h
//  eSales
//
//  Created by Nghia Tran on 8/22/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeNguoiLienHeViewController : UIViewController <UITextFieldDelegate>

// txb
@property (weak, nonatomic) IBOutlet UITextField *txbTenCongTy;
@property (weak, nonatomic) IBOutlet UITextField *txbDiaChi;
@property (weak, nonatomic) IBOutlet UITextField *txbNgayThanhLap;
@property (weak, nonatomic) IBOutlet UITextField *txbNguoiDaiDien;
@property (weak, nonatomic) IBOutlet UITextField *txbDienThoai;
@property (weak, nonatomic) IBOutlet UITextField *txbDienThoaiDD;
@property (weak, nonatomic) IBOutlet UITextField *txbTaiKhoanNganHang;
@property (strong, nonatomic) NSMutableDictionary *dictKHMoi;

- (IBAction)luuTapped:(id)sender;
- (IBAction)showDatePicker:(id)sender;
@end
