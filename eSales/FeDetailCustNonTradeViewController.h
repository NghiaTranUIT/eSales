//
//  FeDetailCustNonTradeViewController.h
//  eSales
//
//  Created by MAC on 10/3/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeDetailCustNonTradeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewCust;
@property (weak, nonatomic) IBOutlet UITableView *tableViewDetail;

@property(strong, nonatomic)NSMutableArray *arrCustTrade;
@property(strong, nonatomic)NSMutableArray *arrSurveyBrand;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
