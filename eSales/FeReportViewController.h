//
//  FeReportViewController.h
//  eSales
//
//  Created by MAC on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeDSDonHang.h"
#import "FeTTPhanHoi.h"
#import "FeDSKHMoi.h"

@interface FeReportViewController : UIViewController<UITextFieldDelegate, FeDSDonHangDelegate, FeTTPhanHoiDelegate, FeDSKHMoiDelegate>

//Tab
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tabBCNgay;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tabBCThang;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *tabDSDonHang;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tabDSKHMoi;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tabTTPhanHoi;
- (IBAction)tabBCNgayTapped:(id)sender;
- (IBAction)tabBCThangTapped:(id)sender;
- (IBAction)tabDSDonHangTapped:(id)sender;
- (IBAction)tabDSKHMoiTapped:(id)sender;
- (IBAction)tabTTPhanHoiTapped:(id)sender;

//txb
@property (weak, nonatomic) IBOutlet UITextField *txbSLDH;
@property (weak, nonatomic) IBOutlet UITextField *txbDoanhSo;
@property (weak, nonatomic) IBOutlet UITextField *txbSLKhachHang;
@property (weak, nonatomic) IBOutlet UITextField *txbSLKHBaoPhu;
@property (weak, nonatomic) IBOutlet UITextField *txbTongCK;
@property (weak, nonatomic) IBOutlet UITextField *txbTongKhuyenMai;

// Main View
@property (strong, nonatomic) IBOutlet UIView *mainViewBCNgay;
@property (strong, nonatomic) UIView *mainViewBCThang;
@property (strong, nonatomic) FeDSDonHang *mainViewDSDonHang;
@property (strong, nonatomic) FeDSKHMoi *mainViewDSKHMoi;
@property (strong, nonatomic) FeTTPhanHoi *mainViewTTPhanHoi;

@end
