//
//  FePhanHoi.h
//  eSales
//
//  Created by Nghia Tran on 8/23/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FePhanHoiDelegate;

@interface FePhanHoi : UIView <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txbTieuDe;
@property (weak, nonatomic) IBOutlet UITextView *txbNoiDung;
@property (weak, nonatomic) IBOutlet UITextField *txbMaAnh;

@property (weak, nonatomic) IBOutlet UIImageView *pic1;
@property (weak, nonatomic) IBOutlet UIImageView *pic2;
@property (weak, nonatomic) IBOutlet UIImageView *pic3;
@property (strong, nonatomic) NSString *curCode;
@property (nonatomic) BOOL isPhanHoi;


- (IBAction)taoMoiTapped:(id)sender;
- (IBAction)chupHinhTapped:(id)sender;
- (IBAction)luuTapped:(id)sender;
- (IBAction)dongTapped:(id)sender;
- (void) hideKeyboard;
- (void)isPhanHoi:(BOOL)phanhoi;

@property (weak, nonatomic) id<FePhanHoiDelegate> delegate;
@end

@protocol FePhanHoiDelegate <NSObject>

-(void) FePhanHoiCloseViewController:(FePhanHoi *) sender;



@end
