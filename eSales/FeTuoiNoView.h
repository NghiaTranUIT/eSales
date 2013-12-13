//
//  FeTuoiNoView.h
//  eSales
//
//  Created by Nghia Tran on 9/10/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeTuoiNoView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txbTenKH;
@property (weak, nonatomic) IBOutlet UITextField *txbNoHienTai;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UITextField *txbTongChuaToiHan;
@property (weak, nonatomic) IBOutlet UITextField *txbTongQH7Ngay;
@property (weak, nonatomic) IBOutlet UITextField *txbTongQH15Ngay;
@property (weak, nonatomic) IBOutlet UITextField *tbxTongQHTren15Ngay;


@end
