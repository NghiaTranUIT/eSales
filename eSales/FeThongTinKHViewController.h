//
//  FeThongTinKHViewController.h
//  eSales
//
//  Created by Nghia Tran on 8/22/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeThongTinKHViewController : UIViewController <UITextFieldDelegate>

// iboutlet
@property (weak, nonatomic) IBOutlet UITextField *txbTenCuaHang;
@property (weak, nonatomic) IBOutlet UITextField *txbTenKH;
@property (weak, nonatomic) IBOutlet UITextField *txbDiaChi;
@property (weak, nonatomic) IBOutlet UITextField *txbDienThoai;
@property (weak, nonatomic) IBOutlet UITextField *txbFax;
@property (weak, nonatomic) IBOutlet UITextField *txbEmail;
@property (weak, nonatomic) IBOutlet UITextField *txbKenh;
@property (weak, nonatomic) IBOutlet UITextField *txbKhuVuc;
@property (weak, nonatomic) IBOutlet UITextField *txbNhomKH;
@property (weak, nonatomic) IBOutlet UITextField *txbLoaiCuaHang;
@property (weak, nonatomic) IBOutlet UITextField *txbLoaiBanHang;
@property (weak, nonatomic) IBOutlet UITextField *txbThanhPho;
@property (weak, nonatomic) IBOutlet UITextField *txbQuanHuyen;
@property (weak, nonatomic) IBOutlet UITextField *txbPhuongXa;
@property (strong, nonatomic) NSMutableDictionary *dictKHMoi;

- (IBAction)saveTapped:(id)sender;
- (IBAction)nexTapped:(id)sender;

@end
