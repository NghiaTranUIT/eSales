//
//  FeDetailCustomer.h
//  eSales
//
//  Created by Nghia Tran on 9/5/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FeDeTailViewDelegate;

@interface FeDetailCustomer : UIView<UITextFieldDelegate>

// Delegate
@property (weak, nonatomic) id<FeDeTailViewDelegate> delegate;
// Avatar

@property (weak, nonatomic) NSDictionary *activeCustDict;
//lbl
@property (weak, nonatomic) IBOutlet UILabel *lblTen;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *lblTenNguoiLienLac;
@property (weak, nonatomic) IBOutlet UILabel *lblDienThoat;
@property (weak, nonatomic) IBOutlet UILabel *lblFax;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblKenh;
@property (weak, nonatomic) IBOutlet UILabel *lblKhuVuc;
@property (weak, nonatomic) IBOutlet UILabel *lblNhomKH;
@property (weak, nonatomic) IBOutlet UILabel *lblLoaiCuaHang;
@property (weak, nonatomic) IBOutlet UILabel *lblLoaiBanhang;
@property (weak, nonatomic) IBOutlet UILabel *lblDiaChi;
@property (weak, nonatomic) IBOutlet UILabel *lblTinh;
@property (weak, nonatomic) IBOutlet UILabel *lblQuanHuyen;
@property (weak, nonatomic) IBOutlet UILabel *lblPhuongXa;
@property (weak, nonatomic) IBOutlet UILabel *lblCongNo;
@property (weak, nonatomic) IBOutlet UITextField *txfSite;

- (IBAction)btnDongTapped:(id)sender;
- (IBAction)btnBatDauTapped:(id)sender;

// Change title
-(void) reSetupViewWithCustomer:(NSDictionary *) dictCustomer;

@end

@protocol FeDeTailViewDelegate <NSObject>

-(void) FeDetailViewShouldDismiss:(FeDetailCustomer *) sender;
-(void) FeDetailViewDidStart:(FeDetailCustomer *) sender withCustomer:(NSDictionary *) dict;
@end