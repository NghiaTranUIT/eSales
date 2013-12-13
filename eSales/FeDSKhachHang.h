//
//  FeDSKhachHang.h
//  eSales
//
//  Created by Nghia Tran on 9/3/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FeDSKhachHangDelegate;

@interface FeDSKhachHang : UIView <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) NSMutableArray *arrDSKH;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
-(void) reloadTableViewWithDSKhachHang:(NSMutableArray *) arrDSKhachHang;

@property (weak, nonatomic) id<FeDSKhachHangDelegate> delegate;

@end

@protocol FeDSKhachHangDelegate <NSObject>

-(void) FeDSKhachHange:(FeDSKhachHang *) sender selectedCustID:(NSString *) custID;

@end