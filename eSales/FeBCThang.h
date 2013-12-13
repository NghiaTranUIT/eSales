//
//  FeBCThang.h
//  eSales
//
//  Created by MAC on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeBCThang : UIView <UITextFieldDelegate>

//txb
@property (weak, nonatomic) IBOutlet UITextField *txbChiTieuDS;
@property (weak, nonatomic) IBOutlet UITextField *txbDoanhSo;
@property (weak, nonatomic) IBOutlet UITextField *txbPhanTramDat;
@property (weak, nonatomic) IBOutlet UITextField *txbTongKHPhaiThamVieng;
@property (weak, nonatomic) IBOutlet UITextField *txbTongKHDaThamVieng;
@property (weak, nonatomic) IBOutlet UITextField *txbPhanTramThamVieng;

@end
