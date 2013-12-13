//
//  FeGhiNhanTongTien.m
//  eSales
//
//  Created by Nghia Tran on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeGhiNhanTongTien.h"
#import "GhiNhanTongTienCell.h"
#import "ActionSheetPicker.h"
#import "FeDatabaseManager.h"
#import "ActionSheetPicker.h"
#import "FeGhiNhanSanPhamViewController.h"
#import "FeThongTinDoiThuViewController.h"

@interface FeGhiNhanTongTien()
{
    NSInteger indexLyDo;
    NSInteger indexNhaPhanPhoi;
    double _tongSauThue;
    
    NSString *stringTongTien;
    NSString *stringTongSL;
}
@property (nonatomic, assign) CGFloat tongCongKoThue;
@property (strong, nonatomic) NSMutableArray *arrNhaPhanPhoi;
@end
@implementation FeGhiNhanTongTien
@synthesize tableView = _tableView, lblCKCtu = _lblCKCtu, lblCKDong = _lblCKDong, lblNgayQH = _lblNgayQH, lblNhaPhanPhoi = _lblNhaPhanPhoi, lblTongCong = _lblTongCong, lblTongGTTH = _lblTongGTTH, lblTongSL = _lblTongSL, arrTongSP = _arrTongSP,arrLyDo = _arrLyDo, arrNhaPhanPhoi = _arrNhaPhanPhoi;
@synthesize delegate = _delegate, feThongTinDoiThu = _feThongTinDoiThu, feGhiNhanSP = _feGhiNhanSP, tongCongKoThue = _tongCongKoThue;


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
    UINib *nib = [UINib nibWithNibName:@"CellGhiNhanDonhang" bundle:[NSBundle mainBundle]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"GhiNhanTongTienCell"];
    
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    
    _arrLyDo = [db arrLyDoFromDatabase];
    indexLyDo = 0;
    
    _arrNhaPhanPhoi = [db arrNhaPhanPhoiFromDatabase];
    indexLyDo = 0;
    _lblNhaPhanPhoi.text = [[_arrNhaPhanPhoi objectAtIndex:indexNhaPhanPhoi] objectForKey:@"CpnyName"];
    
    _lblNgayQH.text = [db stringBussinessDateFromDatabase];
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    bg.frame = self.frame;
    bg.contentMode = UIViewContentModeScaleAspectFill;
    [self insertSubview:bg atIndex:0];
    self.clipsToBounds = YES;
}

- (IBAction)btnKhongMuaHangTapped:(id)sender
{
    NSMutableArray *lyDo = [[NSMutableArray alloc] initWithCapacity:_arrLyDo.count];
    
    for (NSDictionary *dict in _arrLyDo)
    {
        NSString *yc = [dict valueForKey:@"Descr"];
        [lyDo addObject:yc];
    }
    
        [ActionSheetStringPicker showPickerWithTitle:@"Lý do" rows:lyDo initialSelection:indexLyDo doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
         {
                indexLyDo = selectedIndex;
             
             // Save KH khong mua to OM_SuggertOrder
             NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
             [dict setValue:_feGhiNhanSP.arrSanPhamSelected forKey:@"GhiNhanSP"];
             [dict setValue:[_arrLyDo objectAtIndex:indexLyDo] forKey:@"LyDo"];
             
             FeDatabaseManager *db = [ FeDatabaseManager sharedInstance];
             [db saveTakeOrderKHKhongMuaWithDictionary:dict withCompletionHandler:^(BOOL success) {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Lưu Thành Công" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                 
                 [alertView show];
                 
                 [_delegate FeGhiNhanTongTienShouldClose:self];
             }];
             
            
        
        } cancelBlock:^(ActionSheetStringPicker *picker)
        {
            
        } origin:sender];
        
        
}

- (IBAction)btnLuuVaThoatTapped:(id)sender
{
    if (![self isNumberic:_lblCKCtu.text] || _lblCKCtu.text.floatValue > _tongSauThue)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"CK CTừ không hợp lệ.2" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    else{
        [self textFieldShouldReturn:_lblCKCtu];
    }
    if (_arrTongSP.count > 0)
    {
        [self textFieldShouldReturn:_lblCKCtu];
        
        //
        NSLog(@"Save With ThongTinDoiThu %@",_feThongTinDoiThu.arrBrandSelected);
        NSLog(@"Save With ThongTinDoiThu %@",_feThongTinDoiThu.mainViewSanPhamDoiThu.arrSanPhamDoiThuSelected);
        
        NSLog(@"Save With ThongTinDoiThu %@",_feGhiNhanSP.arrSanPhamSelected);
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        // check
        if (_feThongTinDoiThu)
        {
            [dict setObject:_feThongTinDoiThu.arrBrandSelected forKey:@"ThongTinDoiThu"];
            [dict setObject:_feThongTinDoiThu.txbSLTB.text forKey:@"SLTB"];
            [dict setObject:_feThongTinDoiThu.txbDSTB.text forKey:@"DSTB"];
        }
        else
        {
            [dict setObject:[[NSMutableArray alloc] initWithCapacity:0]  forKey:@"ThongTinDoiThu"];
            [dict setObject:@"0" forKey:@"SLTB"];
            [dict setObject:@"0" forKey:@"DSTB"];
        }
        if (_feThongTinDoiThu.mainViewSanPhamDoiThu)
        {
            [dict setObject:_feThongTinDoiThu.mainViewSanPhamDoiThu.arrSanPhamDoiThuSelected forKey:@"SanPhamDoiThu"];
        }
        else
        {
            [dict setObject:[[NSMutableArray alloc] initWithCapacity:0] forKey:@"SanPhamDoiThu"];
        }
    
        [dict setObject:_feGhiNhanSP.arrSanPhamSelected forKey:@"GhiNhanSanPham"];
        [dict setObject:[_arrNhaPhanPhoi objectAtIndex:indexNhaPhanPhoi] forKey:@"NhaPhanPhoi"];
        
        [dict setObject:_lblCKCtu.text forKey:@"CKCTu"];
        [dict setObject:stringTongTien forKey:@"TongCong"];
        [dict setObject:_lblTongGTTH.text forKey:@"TongGTTH"];
        
        //[dict setObject:_lblTongSL.text forKey:@"TongSL"];
        [dict setObject:stringTongSL forKey:@"TongSL"];
        [dict setObject:[NSString stringWithFormat:@"%.2f",_tongCongKoThue] forKey:@"tongCongKoThue"];
        
        NSLog(@"Tong cong: %@", stringTongTien);
        NSLog(@"Tong SL: %@", _lblTongSL.text);
        
        FeDatabaseManager *db  = [FeDatabaseManager sharedInstance];
        
        // Xoa don hang cu khi update
        // NSLog(@"Update: %@",((_feGhiNhanSP.isUpdate==YES)?@"YES":@"NO"));
        if(_feGhiNhanSP.isUpdate==YES)
        {
            NSString *maDHCanXoa = _feGhiNhanSP.maDHSelected;
            //[db deleteDonHangCuFromDatabaseWithOrderNbr:maDHCanXoa];
            [self xoaDonHangCuWithOrderNbr:maDHCanXoa];
            
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:maDHCanXoa forKey:@"OrderNbrUpdate"];
        }else
        {
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:@"" forKey:@"OrderNbrUpdate"];
        }
        
        
        [db saveTakeOrderDictionary:dict WithCompletionHandler:^(BOOL success) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Lưu Thành Công" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            [alertView show];
            [_delegate FeGhiNhanTongTienShouldClose:self];
        }];
        
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Không thể tạo Đơn hàng, do không có Sản Phẩm" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alertView show];
    }
    
    
}

-(void) xoaDonHangCuWithOrderNbr:(NSString*)orderNbr
{
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    [db deleteOM_SaleOrdWithOrderNbr:orderNbr];
    
    NSMutableArray *arrOM_SalesOrdDet = [db arrAllOM_SalesOrdDetFromDatabaseWithOrderNbr:orderNbr];
    
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
    
    [db deleteOM_SalesOrdDetWithOrderNbr:orderNbr];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrTongSP.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idCell = @"GhiNhanTongTienCell";
    GhiNhanTongTienCell *cell = [_tableView dequeueReusableCellWithIdentifier:idCell forIndexPath:indexPath];
    
    
    NSMutableDictionary *dict = [_arrTongSP objectAtIndex:indexPath.row];
    cell.lblDienGiai.text = [dict objectForKey:@"desrc"];
    
    cell.lblSI.text = @"0";
    
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    NSString *stringSL = [dict objectForKey:@"SL"];
    NSString *stringTongTieng = [dict objectForKey:@"TongTien"];
    NSString *stringGiaBan = [dict objectForKey:@"stkBasePrc"];
    
    cell.lblSoLuongBan.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:stringSL.floatValue]];
    cell.lblThanhTien.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:stringTongTieng.floatValue]];
    cell.lblGiaban.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:stringGiaBan.floatValue]];
    return cell;
}
-(void) reloadTableViewWithArrTongSP:(NSMutableArray *)arr
{
    _arrTongSP = arr;
    [_tableView reloadData];
    
    // Set contetn
    CGFloat tongSL = 0;
    
    //Tong cong sau thue chua tru CK - Tong GTTH
    double tongCongSauThue = 0;
    
    // Tong cong ko tinh thue
    double tongCongKoThue = 0;
    
    for (NSMutableDictionary *dict in _arrTongSP)
    {
        NSString *SL = [dict objectForKey:@"SL"];
        NSString *TongTien = [dict objectForKey:@"TongTien"];
        
        // TInh Thue
        NSString *stringLoaiThue = [dict objectForKey:@"TaxCat"];
        CGFloat loaiThue = 0;
        if ([stringLoaiThue isEqualToString:@"VAT05"])
        {
            loaiThue = 0.05;
        }
        else if ([stringLoaiThue isEqualToString:@"VAT10"])
        {
            loaiThue = 0.1;
        }
        else if ([stringLoaiThue isEqualToString:@"VAT00"])
        {
            loaiThue = 0;
        }
        
        
        tongSL += SL.floatValue;
        
        // Tong cong đã bao gồm VAT
        tongCongSauThue += TongTien.floatValue + TongTien.floatValue * loaiThue;
        
        tongCongKoThue += TongTien.floatValue;
    }
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    
    _tongSauThue = tongCongSauThue;
    
    _lblTongSL.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:tongSL]];
    _lblTongGTTH.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:tongCongSauThue]];
    _lblTongCong.text = [numberFormatter stringFromNumber:[NSNumber numberWithInt:tongCongSauThue]];
    _tongCongKoThue = tongCongKoThue;
    stringTongSL = [NSString stringWithFormat:@"%f", tongSL];
    
}
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _lblCKCtu)
        return YES;
    if (textField == _lblNhaPhanPhoi)
    {
        // init array for picker
        NSMutableArray *nhaPhanPhoi = [[NSMutableArray alloc] initWithCapacity:_arrNhaPhanPhoi.count];
        for (NSDictionary *dict in _arrNhaPhanPhoi)
        {
            [nhaPhanPhoi addObject:[dict valueForKey:@"CpnyName"]];
        }
        
        [_lblCKCtu resignFirstResponder];
        
        [ActionSheetStringPicker showPickerWithTitle:@"Nhà Phân Phối" rows:nhaPhanPhoi initialSelection:indexNhaPhanPhoi doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            NSDictionary *dict = [_arrNhaPhanPhoi objectAtIndex:selectedIndex];
            NSString *CpnyID = [dict valueForKey:@"CpnyID"];
            
            _lblNhaPhanPhoi.text = (NSString *) selectedValue;
            indexNhaPhanPhoi = selectedIndex;
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:_lblNhaPhanPhoi];
        return NO;

    }
    if (textField == _lblNgayQH)
    {


    }
    
    return NO;
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _lblCKCtu)
    {
        if ([self isNumberic:_lblCKCtu.text] && _lblCKCtu.text.floatValue <= _tongSauThue)
        {
            [_lblCKCtu resignFirstResponder];
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];

            double sum = _tongSauThue- _lblCKCtu.text.floatValue;
            
            _lblTongCong.text = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:sum]];
            stringTongTien = [NSString stringWithFormat:@"%.0f",sum];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"CK CTừ không hợp lệ.2" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        
    }
    return YES;
}

-(BOOL) isNumberic:(NSString *)string
{
    BOOL result = NO;
    
    NSString *someRegexp = @"^(?:[0-9]\\d*)(?:\\.\\d*)?$";
    NSPredicate *myTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", someRegexp];
    
    if ([myTest evaluateWithObject: string]){
        //Matches
        result = YES;
    }
    return result;
}
@end
