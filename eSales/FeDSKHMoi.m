//
//  FeDSKHMoi.m
//  eSales
//
//  Created by MAC on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeDSKHMoi.h"
#import "FeDatabaseManager.h"
#import "FeKHMoiCell.h"

@interface FeDSKHMoi()

-(void) setupDefaultView;

@end
 
@implementation FeDSKHMoi
@synthesize tableView=_tableView, arrDSKHMoi=_arrDSKHMoi, indexSelected=_indexSelected, dictKHMoi=_dictKHMoi, custID=_custID;
@synthesize delegate=_delegate;

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
    _indexSelected = -1;
    
    // register View
    UINib *nib = [UINib nibWithNibName:@"KHMoiCell" bundle:[NSBundle mainBundle]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"KHMoiCell"];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 41;
    
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    _arrDSKHMoi = [[ NSMutableArray alloc] init];
    _arrDSKHMoi = [ db arrDSKHMoiFromDatabase];
    
    
}

- (IBAction)btnXoaTapped
{
    if(_indexSelected < 0 && _custID.length <= 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"Vui Lòng Chọn Khách Hàng Cần Xoá." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"Bạn Có Muốn Xoá Khách Hàng Này Không?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert setTag:1000];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000)
    {
        if (buttonIndex == 0)
        {
            // Cancel Tapped
        }
        else if (buttonIndex == 1)
        {
            // DELETE Tapped
            [self xoaKhachHangMoi];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"Xoá Khách Hàng Mới Thành Công." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            [alert show];
        }
    }
}
-(void)xoaKhachHangMoi
{
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    [db deleteAR_NewCustomerInforWithCustID:_custID];
    
    [_arrDSKHMoi removeObjectAtIndex:_indexSelected];
    [_tableView reloadData];
}

- (IBAction)btnDieuChinhTapped
{
    if(_indexSelected < 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"Vui Lòng Chọn Khách 1 Hàng." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }else
    {
        [_delegate FeDSKHMoiShouldPerformSegue:self];
    }
    
}

-(NSInteger ) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Count = %d",_arrDSKHMoi.count);
    return [ _arrDSKHMoi count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idCell = @"KHMoiCell";
    
    FeKHMoiCell *cell =[_tableView dequeueReusableCellWithIdentifier:idCell forIndexPath:indexPath];
    
    if([_arrDSKHMoi count] != 0)
    {
        NSDictionary *dictDSDH = [_arrDSKHMoi objectAtIndex:indexPath.row];
        
        cell.txbSTT.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];
        cell.txbTenKH.text = [dictDSDH objectForKey:@"ContactName"];
        cell.txbDiaChi.text =[dictDSDH objectForKey:@"Addr1"];
        cell.txbLoaiBanHang.text = [dictDSDH objectForKey:@"TradeName"];
    }else
    {
        cell.txbSTT.text = @"";
        cell.txbTenKH.text = @"";
        cell.txbDiaChi.text =@"";
        cell.txbLoaiBanHang.text = @"";
    }
    
    return cell;
    
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _dictKHMoi = [_arrDSKHMoi objectAtIndex:indexPath.row];
    _indexSelected = indexPath.row;
}

@end
