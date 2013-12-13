//
//  FeDSDonHang.h
//  eSales
//
//  Created by MAC on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FeDSDonHang;

@protocol FeDSDonHangDelegate <NSObject>

-(void) FeDSDonHangShouldPerformSegue:(FeDSDonHang *) sender;
//-(void) FeDSDonHangUpdateShouldPerformSegue:(FeDSDonHang *) sender;

@end


@interface FeDSDonHang : UIView<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnXoa;
@property (weak, nonatomic) IBOutlet UIButton *btnDieuChinh;
@property (weak, nonatomic) IBOutlet UIButton *btnTaoMoi;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSMutableArray *arrDSDH;
@property (nonatomic, retain) NSString *maDHSelected;
@property (nonatomic) NSInteger indexSelected;
@property (nonatomic) BOOL isUpdate;

@property (weak, nonatomic) id<FeDSDonHangDelegate> delegate;

- (IBAction)btnXoaTapped;
- (IBAction)btnDieuChinhTapped;
- (IBAction)btnTaoMoiTapped;
- (void)reloadData;

@end

