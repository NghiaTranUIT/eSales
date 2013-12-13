//
//  FeSanPhamDoiThu.h
//  eSales
//
//  Created by Nghia Tran on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeSanPhamDoiThu : UIView <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
- (IBAction)btnXoaTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *arrSanPhamDoiThuSelected;
@end
