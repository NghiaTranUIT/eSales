//
//  FeGhiNhanTongTien.h
//  eSales
//
//  Created by Nghia Tran on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FeGhiNhanTongTienDelegate;
@class FeGhiNhanSanPhamViewController;
@class FeThongTinDoiThuViewController;

@interface FeGhiNhanTongTien : UIView <UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic) NSMutableArray *arrTongSP;
@property (strong, nonatomic) NSMutableArray *arrLyDo;
@property (weak, nonatomic) id <FeGhiNhanTongTienDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextField *lblTongGTTH;
@property (weak, nonatomic) IBOutlet UITextField *lblCKCtu;
@property (weak, nonatomic) IBOutlet UITextField *lblCKDong;
@property (weak, nonatomic) IBOutlet UITextField *lblTongCong;
@property (weak, nonatomic) IBOutlet UITextField *lblTongSL;
@property (weak, nonatomic) IBOutlet UITextField *lblNhaPhanPhoi;
@property (weak, nonatomic) IBOutlet UITextField *lblNgayQH;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)btnKhongMuaHangTapped:(id)sender;
- (IBAction)btnLuuVaThoatTapped:(id)sender;

-(void) reloadTableViewWithArrTongSP:(NSMutableArray *) arr;
@property (weak, nonatomic) FeThongTinDoiThuViewController *feThongTinDoiThu;
@property (weak, nonatomic) FeGhiNhanSanPhamViewController *feGhiNhanSP;

@end

@protocol FeGhiNhanTongTienDelegate <NSObject>

-(void) FeGhiNhanTongTienShouldClose:(id) sender;



@end