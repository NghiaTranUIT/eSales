//
//  FeThongBaoViewController.h
//  eSales
//
//  Created by Nghia Tran on 8/23/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FePhanHoi.h"

@interface FeThongBaoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,FePhanHoiDelegate>


@property (weak, nonatomic) IBOutlet UIBarButtonItem *tabBangTin;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tabPhanHoi;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *viewBangTin;
@property (strong, nonatomic) FePhanHoi *viewPhanHoi;
@property (nonatomic) BOOL isPhanHoi;
@property (strong, nonatomic) NSMutableDictionary *dictNoticeBoardSubmit;

- (IBAction)bangTinTapped:(id)sender;
- (IBAction)phanHoiTapped:(id)sender;


@end
