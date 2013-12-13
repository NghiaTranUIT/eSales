//
//  FeNguoiDaiDienViewController.h
//  eSales
//
//  Created by Nghia Tran on 8/22/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeNguoiDaiDienViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *txbTenKH1;
@property (weak, nonatomic) IBOutlet UITextField *txbDiaChi1;
@property (weak, nonatomic) IBOutlet UITextField *txbDienThoai1;
@property (weak, nonatomic) IBOutlet UITextField *txbNgaySinh1;
@property (weak, nonatomic) IBOutlet UITextField *txbEmail1;

@property (weak, nonatomic) IBOutlet UITextField *txbDiaChi2;
@property (weak, nonatomic) IBOutlet UITextField *txbTen2;
@property (weak, nonatomic) IBOutlet UITextField *txbNgaySinh2;
@property (weak, nonatomic) IBOutlet UITextField *txbEmail2;
@property (weak, nonatomic) IBOutlet UITextField *txbDienThoai2;

@property (weak, nonatomic) IBOutlet UITextField *txbTenKH3;
@property (weak, nonatomic) IBOutlet UITextField *txbDiaChi3;
@property (weak, nonatomic) IBOutlet UITextField *txbDienThoai3;
@property (weak, nonatomic) IBOutlet UITextField *txbNgaySinh3;
@property (weak, nonatomic) IBOutlet UITextField *txbEmail3;
@property (strong, nonatomic) NSMutableDictionary *dictKHMoi;

@end
