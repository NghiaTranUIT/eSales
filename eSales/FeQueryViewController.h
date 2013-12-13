//
//  FeQueryViewController.h
//  eSales
//
//  Created by MAC on 10/3/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeQueryViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;



@end
