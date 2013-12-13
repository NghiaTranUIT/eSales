//
//  FeOptionViewController.h
//  eSales
//
//  Created by Nghia Tran on 9/10/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeOptionViewController : UIViewController

// Button
@property (weak, nonatomic) IBOutlet UIButton *btnLichSuBanHang;
@property (weak, nonatomic) IBOutlet UIButton *btnNhanDienBenNgoai;
@property (weak, nonatomic) IBOutlet UIButton *btnThongTinDoiThu;
@property (weak, nonatomic) IBOutlet UIButton *btnDatHang;
@property (weak, nonatomic) IBOutlet UIButton *btnCongViecThucHien;

// ACtion
@property (weak, nonatomic) IBOutlet UILabel *status;


@end
