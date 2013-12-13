//
//  FeThongTinDoiThuViewController.h
//  eSales
//
//  Created by Nghia Tran on 9/10/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeSanPhamDoiThu.h"

@interface FeThongTinDoiThuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,UISearchBarDelegate>

// TabBar
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tabSanPhamIVF;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tabSanPhamDoiThu;
- (IBAction)tabSanPhamIVFTapped:(id)sender;
- (IBAction)tabSanPhamDoiThuTapped:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableView;


@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
- (IBAction)btnXoaTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *txbSLTB;
@property (weak, nonatomic) IBOutlet UITextField *txbDSTB;

// Main View
@property (strong, nonatomic) IBOutlet UIView *mainViewSanPhamIVF;
@property (strong, nonatomic) FeSanPhamDoiThu *mainViewSanPhamDoiThu;
@property (strong, nonatomic) NSMutableArray *arrBrandSelected;

- (IBAction)pushSegue:(id)sender;
@end
