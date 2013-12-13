//
//  FeDSKHMoi.h
//  eSales
//
//  Created by MAC on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FeDSKHMoi;
@protocol FeDSKHMoiDelegate <NSObject>

-(void) FeDSKHMoiShouldPerformSegue:(FeDSKHMoi *) sender;

@end


@interface FeDSKHMoi : UIView<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnXoa;
@property (weak, nonatomic) IBOutlet UIButton *btnDieuChinh;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSMutableArray *arrDSKHMoi;
@property (retain, nonatomic) NSMutableDictionary *dictKHMoi;
@property (nonatomic) int indexSelected;
@property(nonatomic, retain)NSString *custID;

@property (weak, nonatomic) id<FeDSKHMoiDelegate> delegate;

- (IBAction)btnXoaTapped;
- (IBAction)btnDieuChinhTapped;

@end
