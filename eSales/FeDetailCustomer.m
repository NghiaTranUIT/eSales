//
//  FeDetailCustomer.m
//  eSales
//
//  Created by Nghia Tran on 9/5/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeDetailCustomer.h"
#import "FeDatabaseManager.h"
#import "ActionSheetPicker.h"
#import "UIImageView+AFNetworking.h"
#define kURLPhoto @"http://113.161.67.149:8080/syncservicetest/Sync/Pics/"

@interface FeDetailCustomer()
{
    
}
@property (strong, nonatomic) NSMutableArray *arrSite;
@property (nonatomic) NSInteger indexSiteSelected;
@end


@implementation FeDetailCustomer
@synthesize lblCongNo = _lblCongNo, lblDiaChi = _lblDiaChi, lblDienThoat = _lblDienThoat, lblEmail = _lblEmail, lblFax = _lblFax, lblKenh = _lblKenh, lblKhuVuc = _lblKhuVuc, lblLoaiBanhang = _lblLoaiBanhang, lblLoaiCuaHang = _lblLoaiCuaHang, lblNhomKH = _lblNhomKH, lblPhuongXa = _lblPhuongXa, lblQuanHuyen = _lblQuanHuyen, lblTen = _lblTen, lblTenNguoiLienLac = _lblTenNguoiLienLac, lblTinh = _lblTinh, txfSite=_txfSite, arrSite=_arrSite, indexSiteSelected=_indexSiteSelected;

@synthesize avatar = _avatar, delegate = _delegate;
@synthesize activeCustDict = _activeCustDict;
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
    self.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.5];
    _txfSite.delegate=self;
    [self setupDefaultView];
    
}

-(void) setupDefaultView
{
    // Get Setting User
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:[user valueForKey:@"Setting"]];
    NSString *SiteDefault = [dict objectForKey:@"SiteDefault"];
    
    FeDatabaseManager *db  = [FeDatabaseManager sharedInstance];
    _arrSite = [db arrSiteFromDatabase];
    _indexSiteSelected = [self getIndexSiteFromSiteID:SiteDefault inArray:_arrSite];
    
    if(_indexSiteSelected >= _arrSite.count) // ko co Site Default
        _indexSiteSelected = 0;
    
    //Set Default Site in txf
    NSDictionary *dictSite = [_arrSite objectAtIndex:_indexSiteSelected];
    NSString *siteID = [dictSite valueForKey:@"SiteID"];
    _txfSite.text = siteID;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self loadSiteWithSiteDefault];
    return NO;
}

-(void)loadSiteWithSiteDefault
{
    NSMutableArray *site = [[NSMutableArray alloc] initWithCapacity:_arrSite.count];
    for (NSDictionary *dict in _arrSite)
    {
        [site addObject:[dict valueForKey:@"Name"]];
    }
    //NSLog(@"Site :%@", site);
    [ActionSheetStringPicker showPickerWithTitle:@"Kho" rows:site initialSelection:_indexSiteSelected doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        
        NSDictionary *dict = [_arrSite objectAtIndex:selectedIndex];
        NSString *siteID = [dict valueForKey:@"SiteID"];
        
        _txfSite.text = siteID;
  
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    } origin:_txfSite];
}

// get index Site
-(NSInteger)getIndexSiteFromSiteID:(NSString*)siteID inArray:(NSMutableArray*)arrSite
{
    int index = 0;
    
    for(NSDictionary *dict in _arrSite)
    {
        if([siteID isEqualToString: [dict objectForKey:@"SiteID"]])
        {
            return index;
        }
        index++;
    }
    return index; //ko tim thay
}

- (IBAction)btnDongTapped:(id)sender
{
    [_delegate FeDetailViewShouldDismiss:self];
}

- (IBAction)btnBatDauTapped:(id)sender
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:_txfSite.text forKey:@"SiteSelected"];
    [user synchronize];
    
    [_delegate FeDetailViewDidStart:self withCustomer:_activeCustDict];
}

-(void) reSetupViewWithCustomer:(NSDictionary *)dictCustomer
{
    /*
    NSMutableDictionary *row = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:CustID],@"CustID",
                                [NSString stringWithUTF8String:CustName],@"CustName",
                                [NSString stringWithUTF8String:ContactName],@"ContactName",
                                [NSString stringWithUTF8String:Phone],@"Phone",
                                [NSString stringWithUTF8String:Mobile],@"Mobile",
                                [NSString stringWithUTF8String:Fax],@"Fax",
                                [NSString stringWithUTF8String:Email],@"Email",
                                [NSString stringWithUTF8String:Addr1],@"Addr1",
                                [NSString stringWithUTF8String:StateName],@"StateName",
                                [NSString stringWithUTF8String:CityName],@"CityName",
                                [NSString stringWithUTF8String:DistrictName],@"DistrictName",
                                [NSString stringWithUTF8String:WardName],@"WardName",
                                [NSString stringWithUTF8String:ChannelName],@"ChannelName",
                                [NSString stringWithUTF8String:ClassIDName],@"ClassIDName",
                                [NSString stringWithUTF8String:AreaName],@"AreaName",
                                [NSString stringWithUTF8String:TerritoryName],@"TerritoryName",
                                [NSString stringWithUTF8String:ShopTypeName],@"ShopTypeName",
                                [NSString stringWithUTF8String:TradeTypeName],@"TradeTypeName",
                                [NSString stringWithUTF8String:PhotoCode],@"PhotoCode",
                                nil];
    */
    _activeCustDict = dictCustomer;
    
    _lblTen.text = [dictCustomer objectForKey:@"ContactName"];
    _lblTenNguoiLienLac.text = [dictCustomer objectForKey:@"CustName"];
    _lblDienThoat.text = [dictCustomer objectForKey:@"Phone"];
    _lblFax.text = [dictCustomer objectForKey:@"Fax"];
    
    _lblEmail.text = [dictCustomer objectForKey:@"Email"];
    _lblKenh.text = [dictCustomer objectForKey:@"ChannelName"];
    _lblKhuVuc.text = [dictCustomer objectForKey:@"AreaName"];
    _lblNhomKH.text = [dictCustomer objectForKey:@"ClassIDName"];
    _lblLoaiBanhang.text = [dictCustomer objectForKey:@"TradeTypeName"];
    _lblLoaiCuaHang.text = [dictCustomer objectForKey:@"ShopTypeName"];
    _lblDiaChi.text = [dictCustomer objectForKey:@"Addr1"];
    _lblTinh.text = [dictCustomer objectForKey:@"StateName"];
    _lblQuanHuyen.text = [dictCustomer objectForKey:@"DistrictName"];
    //_lblPhuongXa.text = [dictCustomer objectForKey:@"WardName"];
    _lblCongNo.text = @"0";
    
    
    // Set Image
    NSString *photoCode = [dictCustomer objectForKey:@"PhotoCode"];
    
    NSString *documentsDirectory = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    
    if (photoCode && ![photoCode isEqualToString:@""])
    {
        NSString *pathString_1 = [NSString stringWithFormat:@"%@/%@",documentsDirectory, photoCode];
        _avatar.image = [UIImage imageWithContentsOfFile:pathString_1];
    }

}
@end
