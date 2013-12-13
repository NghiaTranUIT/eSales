//
//  FeTTPhanHoi.h
//  eSales
//
//  Created by MAC on 9/19/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FeTTPhanHoi;

@protocol FeTTPhanHoiDelegate <NSObject>

-(void) FeTTPhanHoiTypeTShouldPerformSegue:(FeTTPhanHoi *) sender;
-(void) FeTTPhanHoiTypeYShouldPerformSegue:(FeTTPhanHoi *) sender;

@end

@interface FeTTPhanHoi : UIView<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnXoa;
@property (weak, nonatomic) IBOutlet UIButton *btnDieuChinh;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSMutableArray *arrTTPhanHoi;
@property (nonatomic) int isType;
@property (nonatomic) int indexSelected;
@property(nonatomic, retain)NSString *code; 

@property (weak, nonatomic) id<FeTTPhanHoiDelegate> delegate;

- (IBAction)btnXoaTapped;
- (IBAction)btnDieuChinhTapped;
- (void)reloadData;

@end
