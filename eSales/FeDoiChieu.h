//
//  FeDoiChieu.h
//  eSales
//
//  Created by VoVu on 9/28/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeDoiChieu : UIView<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *txfNoThangTruoc;
@property (weak, nonatomic) IBOutlet UITextField *txfNoThangNay;
@property (weak, nonatomic) IBOutlet UITextField *txfTotalDebit;
@property (weak, nonatomic) IBOutlet UITextField *txfTotalCredit;


@end
