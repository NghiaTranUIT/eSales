//
//  FeLichSuBanHangViewController.h
//  eSales
//
//  Created by Nghia Tran on 9/10/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeTuoiNoView.h"
#import "FeDoiChieu.h"

@interface FeLichSuBanHangViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>



// Tab
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tabLichSuBanHang;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tabTuoiNo;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tabDoiChieu;

- (IBAction)tabLichSuBanHangTapped:(id)sender;
- (IBAction)tabTuoiNoTapped:(id)sender;
- (IBAction)tabDoiChieuTapped:(id)sender;


// Main View
@property (strong, nonatomic) IBOutlet UIView *mainViewLichSuBanHang;
@property (strong, nonatomic) FeTuoiNoView *mainViewTuoiNo;
@property (strong, nonatomic) FeDoiChieu *mainViewDoiChieu;
// Outlet
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
