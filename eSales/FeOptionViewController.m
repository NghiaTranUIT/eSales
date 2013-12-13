//
//  FeOptionViewController.m
//  eSales
//
//  Created by Nghia Tran on 9/10/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeOptionViewController.h"

@interface FeOptionViewController ()

-(void) setupDefaultView;
@end

@implementation FeOptionViewController
@synthesize btnDatHang = _btnDatHang, btnLichSuBanHang= _btnLichSuBanHang, btnNhanDienBenNgoai= _btnNhanDienBenNgoai, btnThongTinDoiThu = _btnThongTinDoiThu, btnCongViecThucHien=_btnCongViecThucHien;
@synthesize status = _status;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setupDefaultView];
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    bg.frame = self.view.frame;
    bg.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:bg atIndex:0];
}
-(void) setupDefaultView
{
    // Sale Setep
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:[user objectForKey:@"Setting"]];
    NSNumber *IsStepSales = [dict objectForKey:@"IsStepSales"];
    if (IsStepSales.integerValue == 1)
    {
        _btnCongViecThucHien.enabled = NO;
        _btnNhanDienBenNgoai.enabled = NO;
        _btnDatHang.enabled = NO;
        _btnThongTinDoiThu.enabled = NO;
        _btnLichSuBanHang.enabled = YES;
        _btnCongViecThucHien.enabled = NO;
        
        // Status
        _status.text = @"Bán hàng theo từng bước.";
        [_status sizeToFit];
        _status.center = CGPointMake(self.view.center.x, _status.center.y);
    }
    else
    {
        _btnCongViecThucHien.enabled = YES;
        _btnNhanDienBenNgoai.enabled = YES;
        _btnDatHang.enabled = YES;
        _btnThongTinDoiThu.enabled = YES;
        _btnLichSuBanHang.enabled = YES;
        _btnCongViecThucHien.enabled = YES;
        _status.text = @"";
    
    }
    
    
    /*
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [user objectForKey:@"SalesSetup"];
    
    NSNumber *num1 = [dict objectForKey:@"chkPlaPre_frmSetting"];
    NSNumber *num1_1 = [dict objectForKey:@"chkSalHis_chkPlaPre_frmSetting"];
    NSNumber *num2 = [dict objectForKey:@"chkOutlChk_frmSetting"];
    NSNumber *num2_2 = [dict objectForKey:@"chkOutsChk_chkOutlChk_frmSetting"];
    NSNumber *num3 = [dict objectForKey:@"chkMarketInformation_frmSetting"];
    NSNumber *num4 = [dict objectForKey:@"chkTakOrd_frmSetting"];
    */
    // Setup
    
    [user setObject:@"0" forKey:@"OutsideChecking_Available"];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
