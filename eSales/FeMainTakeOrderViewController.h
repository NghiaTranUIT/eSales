//
//  FeMainTakeOrderViewController.h
//  eSales
//
//  Created by Nghia Tran on 9/5/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCheckBoxView.h"

@interface FeMainTakeOrderViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UISearchBarDelegate>

// TexbBox
@property (weak, nonatomic) IBOutlet UITextField *txbNgayVT;
@property (weak, nonatomic) IBOutlet UITextField *txbTimTheo;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


// Tab bar
@property (weak, nonatomic) IBOutlet UIView *mainViewDSKhachHang;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Check Box
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) SSCheckBoxView *checkBoxTatCaKH;
@end
