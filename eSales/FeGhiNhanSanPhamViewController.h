//
//  FeGhiNhanSanPhamViewController.h
//  eSales
//
//  Created by Nghia Tran on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeGhiNhanTongTien.h"
@class FeThongTinDoiThuViewController;

@interface FeGhiNhanSanPhamViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,UITextFieldDelegate,FeGhiNhanTongTienDelegate>

// Tab bar
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tabSanPham;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tabSoTien;


@property (strong, nonatomic) NSString *maDHSelected;
@property (nonatomic) BOOL isUpdate;

- (IBAction)tabSanPhamTapped:(id)sender;
- (IBAction)tabSoTienTapped:(id)sender;
- (IBAction)btnXoaTapped:(id)sender;

@property (strong, nonatomic) NSMutableArray *arrSanPhamSelected;
// Main View
@property (strong, nonatomic) IBOutlet UIView *mainSanPham;
@property (strong, nonatomic) FeGhiNhanTongTien *mainTongTien;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UITextField *lblTongTien;

@property (weak, nonatomic) FeThongTinDoiThuViewController *feThongTinDoiThu;
@end
