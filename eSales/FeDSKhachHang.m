//
//  FeDSKhachHang.m
//  eSales
//
//  Created by Nghia Tran on 9/3/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeDSKhachHang.h"
#import "FeKhachHangCell.h"

@interface FeDSKhachHang ()

-(void) setupDefaultView;

@end
@implementation FeDSKhachHang
@synthesize tableView = _tableView, arrDSKH = _arrDSKH;
@synthesize delegate = _delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) awakeFromNib
{
    [self setupDefaultView];
}
-(void) setupDefaultView
{
    // register View
    UINib *nib = [UINib nibWithNibName:@"KhachHangCell" bundle:[NSBundle mainBundle]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"KhachHangCell"];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
}
-(NSInteger ) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Count = %d",_arrDSKH.count);
    return _arrDSKH.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idCell = @"KhachHangCell";
    
    FeKhachHangCell *cell = [_tableView dequeueReusableCellWithIdentifier:idCell forIndexPath:indexPath];
    
    NSDictionary *dict = [_arrDSKH objectAtIndex:indexPath.row];
    cell.txbMaKhachHang.text = [dict objectForKey:@"CustID"];
    cell.txbTenKhachHang.text = [dict objectForKey:@"CustName"];
    cell.txDiaChi.text = [dict objectForKey:@"Addr1"];
    
    return cell;
    
}

-(void) reloadTableViewWithDSKhachHang:(NSMutableArray *)arrDSKhachHang
{
    _arrDSKH = arrDSKhachHang;
    [_tableView reloadData];
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [_arrDSKH objectAtIndex:indexPath.row];
    NSString *custID = [dict objectForKey:@"CustID"];
    
    [_delegate FeDSKhachHange:self selectedCustID:custID];
}
@end
