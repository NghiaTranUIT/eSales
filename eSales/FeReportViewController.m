//
//  FeReportViewController.m
//  eSales
//
//  Created by MAC on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeReportViewController.h"
#import "FeDatabaseManager.h"
#import "FeUtility.h"
#import "FeThongBaoViewController.h"
#import "FeTaoMoiThongTinHoTroKyThuatViewController.h"
#import "FePhanHoi.h"
#import "FeCustomerViewController.h"
#import "FeGhiNhanSanPhamViewController.h"

@interface FeReportViewController ()
{
    BOOL isTabBCNgaySelected;
    BOOL isTabBCThangSelected;
    BOOL isTabDSDonHangSelected;
    BOOL isTabDSKHMoiSelected;
    BOOL isTabTTPhanHoiSelected;
    NSString *codePhanHoi;
    NSMutableDictionary *dictKHMoi;
}
-(void) setupDefaultView;
-(void) removeAllMainView;

@end

@implementation FeReportViewController
@synthesize tabBCNgay=_tabBCNgay, tabBCThang=_tabBCThang, tabDSDonHang=_tabDSDonHang, tabDSKHMoi=_tabDSKHMoi, tabTTPhanHoi=_tabTTPhanHoi, txbDoanhSo=_txbDoanhSo, txbSLDH=_txbSLDH, txbSLKhachHang=_txbSLKhachHang, txbSLKHBaoPhu=_txbSLKHBaoPhu, txbTongCK=_txbTongCK, txbTongKhuyenMai=_txbTongKhuyenMai;
@synthesize mainViewBCNgay=_mainViewBCNgay, mainViewBCThang=_mainViewBCThang, mainViewDSDonHang=_mainViewDSDonHang, mainViewDSKHMoi=_mainViewDSKHMoi, mainViewTTPhanHoi=_mainViewTTPhanHoi;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(_mainViewTTPhanHoi)
        [_mainViewTTPhanHoi reloadData];
    if(_mainViewDSDonHang)
        [_mainViewDSDonHang reloadData];
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
    // Tap
    isTabBCNgaySelected = YES;
    isTabBCThangSelected = NO;
    isTabDSDonHangSelected = NO;
    isTabDSKHMoiSelected = NO;
    isTabTTPhanHoiSelected = NO;
    _tabBCNgay.style=UIBarButtonItemStyleDone;
    NSMutableDictionary *dict;
    
    // Load something from DB
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    
    //Get current date
    NSDate *date = [NSDate date];
    NSString *currentDate = [NSString stringWithFormat:@"%@", [FeUtility formatDateWithDateYMD:date]];
    
    //SL KH
    _txbSLKhachHang.text = [db soluongKhacHangFromDatabaseAtDate:currentDate];
    //SL DH
    _txbSLDH.text = [db soluongDonHangFromDatabase];
    //SL KH Bao Phu
    _txbSLKHBaoPhu.text = [db soluongKHBaoPhuFromDatabase];
    //Tong KM
    _txbTongKhuyenMai.text = [db tongKhuyenMaiFromDatabase];
    //Tong CK va Doanh So
    dict = [db dictTongChietKhauVaDoanhSoFromDatabase];
    
    if([dict count] > 0)
    {
        _txbTongCK.text = [[dict objectForKey:@"tongCK"] stringValue];
        _txbDoanhSo.text = [[dict objectForKey:@"doanhSo"] stringValue];
    }else
    {
        _txbTongCK.text = @"0";
        _txbDoanhSo.text = @"0";
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueMainTakeOrder"])
    {
		
            
    }
    if ([segue.identifier isEqualToString:@"sugueGhiNhanDonHang"])
    {
        FeGhiNhanSanPhamViewController *fe =(FeGhiNhanSanPhamViewController*)segue.destinationViewController;
        fe.maDHSelected = _mainViewDSDonHang.maDHSelected;
        
    }
    if ([segue.identifier isEqualToString:@"segueNewTechnicalSupport"])
    {
        
		FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
        FeTaoMoiThongTinHoTroKyThuatViewController *fe=(FeTaoMoiThongTinHoTroKyThuatViewController*)segue.destinationViewController;
        fe.dictNewTechnicalSupport = [db arrNewTechnicalSupportFromDatabaseWithCode:codePhanHoi];
        fe.isUpdate = YES;
         
    }
    if ([segue.identifier isEqualToString:@"SegueThongBao"])
    {
        FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
        FeThongBaoViewController *tb = (FeThongBaoViewController*)segue.destinationViewController;
        tb.dictNoticeBoardSubmit = [db arrNoticeBoardSubmitFromDatabaseWithCode:codePhanHoi];
        tb.isPhanHoi = YES;
    }
    if ([segue.identifier isEqualToString:@"segueKHMoi"])
    {
        FeCustomerViewController *cust = (FeCustomerViewController*)segue.destinationViewController;
        cust.dictKHMoi = dictKHMoi;
    }

}

// Ban hang
-(void)FeDSDonHangShouldPerformSegue:(FeDSDonHang *)sender
{
    //NSLog(@"bool %s", sender.isUpdate ? "true" : "false");
    if(sender.isUpdate)
    {
        NSLog(@"update");
        _mainViewDSDonHang = sender;
        [self performSegueWithIdentifier:@"sugueGhiNhanDonHang" sender:self];
    }
    else
    {
        NSLog(@"new");
        [self performSegueWithIdentifier:@"segueMainTakeOrder" sender:self];
    }   
}

//Phan Hoi
    // Ho tro ky thuat
-(void)FeTTPhanHoiTypeTShouldPerformSegue:(FeTTPhanHoi *)sender
{
    codePhanHoi = sender.code;
    [self performSegueWithIdentifier:@"segueNewTechnicalSupport" sender:self];
    
}
    // Thong bao
-(void)FeTTPhanHoiTypeYShouldPerformSegue:(FeTTPhanHoi *)sender
{
    codePhanHoi = sender.code;
    [self performSegueWithIdentifier:@"SegueThongBao" sender:self];
}
// KH Moi
-(void)FeDSKHMoiShouldPerformSegue:(FeDSKHMoi *)sender
{
    dictKHMoi = sender.dictKHMoi;
    [self performSegueWithIdentifier:@"segueKHMoi" sender:self];
}

- (IBAction)tabBCNgayTapped:(id)sender
{
    if (isTabBCNgaySelected)
        return;
    
    // Remove all
    [self removeAllMainView];
    
    //[self.view addSubview:_mainViewBCNgay];
    
    isTabBCNgaySelected = YES;
    _tabBCNgay.style = UIBarButtonItemStyleDone;
    
    [self.view addSubview:_mainViewBCNgay];
}
- (IBAction)tabBCThangTapped:(id)sender
{
    if (isTabBCThangSelected)
        return;
    
    // Remove all
    [self removeAllMainView];
    
    if (!_mainViewBCThang)
    {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"BCThang" owner:self options:nil];
        _mainViewBCThang = [arr lastObject];
        _mainViewBCThang.frame = CGRectMake(0, 44, _mainViewBCThang.frame.size.width, _mainViewBCThang.frame.size.height);
    }
    
    
    
    isTabBCThangSelected = YES;
    _tabBCThang.style = UIBarButtonItemStyleDone;
    
    [self.view addSubview:_mainViewBCThang];
}
- (IBAction)tabDSDonHangTapped:(id)sender
{
    if (isTabDSDonHangSelected)
        return;
    
    // Remove all
    [self removeAllMainView];
    
    if (!_mainViewDSDonHang)
    {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"DSDonHang" owner:self options:nil];
        _mainViewDSDonHang = [arr lastObject];
        _mainViewDSDonHang.frame = CGRectMake(0, 44, _mainViewDSDonHang.frame.size.width, _mainViewDSDonHang.frame.size.height);
        
        // set delegate//////////////////////
        _mainViewDSDonHang.delegate = self;
    }
    
    
    
    isTabDSDonHangSelected = YES;
    _tabDSDonHang.style = UIBarButtonItemStyleDone;
    
    [self.view addSubview:_mainViewDSDonHang];
     
}

- (IBAction)tabDSKHMoiTapped:(id)sender
{
    if (isTabDSKHMoiSelected)
        return;
    
    // Remove all
    [self removeAllMainView];
    
    if (!_mainViewDSKHMoi)
    {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"DSKHMoi" owner:self options:nil];
        _mainViewDSKHMoi = [arr lastObject];
        _mainViewDSKHMoi.frame = CGRectMake(0, 44, _mainViewDSKHMoi.frame.size.width, _mainViewDSKHMoi.frame.size.height);
        // set delegate//////////////////////
        _mainViewDSKHMoi.delegate = self;
    }
    
    
    
    isTabDSKHMoiSelected = YES;
    _tabDSKHMoi.style = UIBarButtonItemStyleDone;
    
    [self.view addSubview:_mainViewDSKHMoi];
}
- (IBAction)tabTTPhanHoiTapped:(id)sender
{
    if (isTabTTPhanHoiSelected)
        return;
    
    // Remove all
    [self removeAllMainView];
    
    if (!_mainViewTTPhanHoi)
    {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"TTPhanHoi" owner:self options:nil];
        _mainViewTTPhanHoi = [arr lastObject];
        _mainViewTTPhanHoi.frame = CGRectMake(0, 44, _mainViewTTPhanHoi.frame.size.width, _mainViewTTPhanHoi.frame.size.height);
        
        // set delegate//////////////////////
        _mainViewTTPhanHoi.delegate = self;
    }
    
    
    
    isTabTTPhanHoiSelected = YES;
    _tabTTPhanHoi.style = UIBarButtonItemStyleDone;
    
    [self.view addSubview:_mainViewTTPhanHoi];
}

-(void) removeAllMainView
{
    isTabBCNgaySelected = NO;
    isTabBCThangSelected = NO;
    isTabDSDonHangSelected = NO;
    isTabDSKHMoiSelected = NO;
    isTabTTPhanHoiSelected = NO;
    
    if (_mainViewBCNgay)
        [_mainViewBCNgay removeFromSuperview];
    if (_mainViewBCThang)
        [_mainViewBCThang removeFromSuperview];
    if (_mainViewDSDonHang)
        [_mainViewDSDonHang removeFromSuperview];
    if (_mainViewDSKHMoi)
        [_mainViewDSKHMoi removeFromSuperview];
    if (_mainViewTTPhanHoi)
        [_mainViewTTPhanHoi removeFromSuperview];
    
    _tabBCNgay.style = UIBarButtonItemStyleBordered;
    _tabBCThang.style = UIBarButtonItemStyleBordered;
    _tabDSDonHang.style = UIBarButtonItemStyleBordered;
    _tabDSKHMoi.style = UIBarButtonItemStyleBordered;
    _tabTTPhanHoi.style = UIBarButtonItemStyleBordered;
}

@end
