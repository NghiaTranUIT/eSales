//
//  FeThongTinDoiThuCell.h
//  eSales
//
//  Created by Nghia Tran on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeThongTinDoiThuCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblTenSP;
@property (weak, nonatomic) IBOutlet UITextField *lblGiaBan;
@property (weak, nonatomic) IBOutlet UITextField *lblSLTB;
@property (weak, nonatomic) IBOutlet UITextField *lblGhiChu;


-(void) setAllDelegateTextField:(id) sender;

@end
