//
//  FeDSDonHang.m
//  eSales
//
//  Created by MAC on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeDSDonHang.h"
#import "FeDonHangCell.h"
#import "FeDatabaseManager.h"
#import "FeMainTakeOrderViewController.h"

@interface FeDSDonHang ()
 

-(void) setupDefaultView;

@end

@implementation FeDSDonHang

@synthesize tableView=_tableView, arrDSDH=_arrDSDH, maDHSelected=_maDHSelected, indexSelected=_indexSelected, isUpdate=_isUpdate;
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
    _maDHSelected = @"";
    _indexSelected = 0;
    // register View
    UINib *nib = [UINib nibWithNibName:@"DonHangCell" bundle:[NSBundle mainBundle]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"DonHangCell"];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 41;
    
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    _arrDSDH = [[ NSMutableArray alloc] init];
    _arrDSDH = [ db arrDSDonHangFromDatabase];
    
    
}
- (void)reloadData
{
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    _arrDSDH = [[ NSMutableArray alloc] init];
    _arrDSDH = [ db arrDSDonHangFromDatabase];
    
    [_tableView reloadData];
}

-(NSInteger ) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"Count = %d",_arrDSDH.count);
    return [ _arrDSDH count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idCell = @"DonHangCell";

    FeDonHangCell *cell =[_tableView dequeueReusableCellWithIdentifier:idCell forIndexPath:indexPath];
    NSDictionary *dictDSDH = [_arrDSDH objectAtIndex:indexPath.row];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];    
    
    NSString *tongSL = [dictDSDH objectForKey:@"tongSL"];    
    NSString *tongTien = [dictDSDH objectForKey:@"tongTien"];
    
    cell.txbMaKH.text = [dictDSDH objectForKey:@"maKH"];
    cell.txbTongTien.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:tongTien.floatValue]];
    cell.txbTongSL.text =[numberFormatter stringFromNumber:[NSNumber numberWithFloat:tongSL.floatValue]];
    cell.txbTenKH.text = [dictDSDH objectForKey:@"tenKH"];
    cell.txbDHSo.text = [dictDSDH objectForKey:@"dhSo"];
    return cell;
    
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [_arrDSDH objectAtIndex:indexPath.row];
    _maDHSelected = [dict objectForKey:@"dhSo"];
    _indexSelected = indexPath.row;
    NSLog(@"DH So = %@",_maDHSelected);

}

- (IBAction)btnXoaTapped
{
    
    
    if(_maDHSelected.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"Vui Lòng Chọn Đơn Hàng Cần Xoá." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show]; 
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"Bạn Có Muốn Xoá Đơn Hàng Này Không?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert setTag:1000];
        [alert show];
    }
    
}

- (IBAction)btnDieuChinhTapped
{
    _isUpdate = YES;
    [_delegate FeDSDonHangShouldPerformSegue:self];
}
- (IBAction)btnTaoMoiTapped
{
    _isUpdate = NO;
    [_delegate FeDSDonHangShouldPerformSegue:self];
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
            [self xoaDonHang];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"Xoá Đơn Hàng Thành Công." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            [alert show];
        }
    }
}

-(void) xoaDonHang
{
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    [db deleteOM_SaleOrdWithOrderNbr:_maDHSelected];
    
    NSMutableArray *arrOM_SalesOrdDet = [db arrAllOM_SalesOrdDetFromDatabaseWithOrderNbr:_maDHSelected];
    
    for(NSMutableDictionary *dict in arrOM_SalesOrdDet)
    {
        NSMutableDictionary *dictItemLoc = [db arrIN_ItemLocByKeyWithInvtID:[dict valueForKey:@"InvtID"] SiteID:[dict valueForKey:@"SiteID"] WhseLoc:[dict valueForKey:@"WhseLoc"] ];
        if(dictItemLoc.count > 0)
        {
            int lineQty_OM_SalesOrdDet= [[dict valueForKey:@"LineQty"] intValue];
            int qtyAvail_IN_ItemLoc = [[dictItemLoc valueForKey:@"QtyAvail"] intValue] ;
            int newQtyAvail = qtyAvail_IN_ItemLoc + lineQty_OM_SalesOrdDet;
            
            [db updateIN_ItemLocWithDict:dictItemLoc QtyAvail:newQtyAvail];
        }
        
        int freeQty = [[dict valueForKey:@"FreeQty"] intValue];
        if(freeQty > 0)
        {
            NSMutableDictionary *dictItemLoc = [db arrIN_ItemLocByKeyWithInvtID:[dict valueForKey:@"InvtID"] SiteID:[dict valueForKey:@"SiteIDFree"] WhseLoc:[dict valueForKey:@"WhseLocFree"] ];
            if(dictItemLoc.count > 0)
            {
                //int lineQty_OM_SalesOrdDet= [[dict valueForKey:@"LineQty"] intValue];
                int qtyAvail_IN_ItemLoc = [[dictItemLoc valueForKey:@"QtyAvail"] intValue] ;
                int newQtyAvail = qtyAvail_IN_ItemLoc + freeQty;
                
                [db updateIN_ItemLocWithDict:dictItemLoc QtyAvail:newQtyAvail];
            }
        }
    }
    
    [db deleteOM_SalesOrdDetWithOrderNbr:_maDHSelected];
    [_arrDSDH removeObjectAtIndex:_indexSelected];
    [_tableView reloadData];
}
@end
