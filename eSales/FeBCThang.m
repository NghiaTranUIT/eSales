//
//  FeBCThang.m
//  eSales
//
//  Created by MAC on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeBCThang.h"
#import "FeDatabaseManager.h"

@interface FeBCThang()
{
    
}
-(void) setupDefaultView;
@property (strong, nonatomic) NSMutableDictionary *dictBCThang;

@end;

@implementation FeBCThang
@synthesize txbChiTieuDS=_txbChiTieuDS, txbDoanhSo=_txbDoanhSo, txbPhanTramDat=_txbPhanTramDat, txbPhanTramThamVieng=_txbPhanTramThamVieng, txbTongKHDaThamVieng=_txbTongKHDaThamVieng, txbTongKHPhaiThamVieng=_txbTongKHPhaiThamVieng;
@synthesize dictBCThang=_dictBCThang;

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
    //Load something from DB
    FeDatabaseManager *db=[FeDatabaseManager sharedInstance];
    _dictBCThang = [db dictBaoCaoThangFromDatabase];
    
    //Chi tieu doanh so
    _txbChiTieuDS.text = [[_dictBCThang objectForKey:@"chitieuDS"] stringValue];
    
    //Doanh so
    _txbDoanhSo.text = [[_dictBCThang objectForKey:@"doanhso"] stringValue];
    
    //Tong KH Phai Tham Vieng
    _txbTongKHPhaiThamVieng.text = [[_dictBCThang objectForKey:@"tongKHPhaiViengTham"] stringValue];
    
    //Tong KH da tham vieng
    _txbTongKHDaThamVieng.text = [[_dictBCThang objectForKey:@"tongKHDaThamVieng"] stringValue];
    
    //Phan tram dat
    CGFloat phantramDat = ([[_dictBCThang objectForKey:@"doanhso"] floatValue] * 100 ) / [[_dictBCThang objectForKey:@"chitieuDS"] intValue];
    
    NSString *phantramDatFormat = [NSString stringWithFormat:@"%.2f %@", phantramDat, @"%"];
    
    _txbPhanTramDat.text = [phantramDatFormat stringByReplacingOccurrencesOfString:@"nan" withString:@"0"];
    
    //Phan tram tham vieng
    CGFloat phantramTV = ([[_dictBCThang objectForKey:@"tongKHDaThamVieng"] floatValue] * 100 ) / [[_dictBCThang objectForKey:@"tongKHPhaiViengTham"] intValue];
    
    NSString *phantramTVFormat = [NSString stringWithFormat:@"%.2f %@", phantramTV, @"%"];
    
    _txbPhanTramThamVieng.text = [phantramTVFormat stringByReplacingOccurrencesOfString:@"nan" withString:@"0"];
}

@end
