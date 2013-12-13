//
//  FeSanPhamHayBanViewController.h
//  eSales
//
//  Created by Nghia Tran on 8/23/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeSanPhamHayBanViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate,UIScrollViewDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableDictionary *dictKHMoi;

- (IBAction)timKiemTapped:(id)sender;
- (IBAction)xoaTapped:(id)sender;


@end
