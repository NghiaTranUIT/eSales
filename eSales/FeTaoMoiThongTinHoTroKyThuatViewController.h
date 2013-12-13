//
//  FeTaoMoiThongTinHoTroKyThuatViewController.h
//  eSales
//
//  Created by Nghia Tran on 8/23/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeTaoMoiThongTinHoTroKyThuatViewController : UIViewController <UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITextField *txbLoaiYC;
@property (weak, nonatomic) IBOutlet UITextField *txbTieuDe;
@property (weak, nonatomic) IBOutlet UITextView *txbNoiDung;
@property (weak, nonatomic) IBOutlet UITextField *txbMaAnh;

@property (weak, nonatomic) IBOutlet UIImageView *pic1;
@property (weak, nonatomic) IBOutlet UIImageView *pic2;
@property (weak, nonatomic) IBOutlet UIImageView *pic3;
@property (nonatomic) BOOL isUpdate;
@property (weak, nonatomic) NSString *curCode;
@property (strong, nonatomic) NSMutableDictionary *dictNewTechnicalSupport;

// action
- (IBAction)taoMoiTapped:(id)sender;
- (IBAction)chupHinhTapped:(id)sender;
- (IBAction)luuTapped:(id)sender;
- (IBAction)dongTapped:(id)sender;


@end
