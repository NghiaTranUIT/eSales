//
//  FeCongViecThucHienViewController.h
//  eSales
//
//  Created by MAC on 10/2/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCheckBoxView.h"
@class FeThongTinDoiThuViewController;

@interface FeCongViecThucHienViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;

-(IBAction)btnSaveTapped:(id)sender;
-(IBAction)pushSegue:(id)sender;

@property (weak, nonatomic) FeThongTinDoiThuViewController *feThongTinDoiThu;

@end
