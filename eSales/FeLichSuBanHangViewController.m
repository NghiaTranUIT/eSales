//
//  FeLichSuBanHangViewController.m
//  eSales
//
//  Created by Nghia Tran on 9/10/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeLichSuBanHangViewController.h"
#import "FeDatabaseManager.h"
#import <QuartzCore/QuartzCore.h>


@interface FeLichSuBanHangViewController ()
{
    BOOL isTabLichSuBanHangSelected;
    BOOL isTabTuoiNoSelected;
    BOOL isTabDoiChieuSelected;
}
-(void) setupDefaultView;
@property (strong, nonatomic) NSMutableArray *arrLichSuBanHang;
@end

@implementation FeLichSuBanHangViewController
@synthesize tableView = _tableView, mainViewLichSuBanHang = _mainViewLichSuBanHang, tabLichSuBanHang = _tabLichSuBanHang, tabTuoiNo = _tabTuoiNo, arrLichSuBanHang = _arrLichSuBanHang, mainViewTuoiNo = _mainViewTuoiNo, mainViewDoiChieu=_mainViewDoiChieu, tabDoiChieu=_tabDoiChieu;

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
    // Default
    isTabLichSuBanHangSelected = YES;
    isTabTuoiNoSelected = NO;
    isTabDoiChieuSelected = NO;
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *activeCust = [user objectForKey:@"ActiveCustomer"];
    NSString *custID = [activeCust objectForKey:@"CustID"];
    NSLog(@"active CustID = %@",custID);
    
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    _arrLichSuBanHang = [db arrLichSuBanHangFromDatabaseWithCustomerID:custID];
    
    NSLog(@"arr lich su ban hang = %@",_arrLichSuBanHang);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tabLichSuBanHangTapped:(id)sender
{
    if (isTabLichSuBanHangSelected)
        return;
    
    _tabTuoiNo.style = UIBarButtonItemStyleBordered;
    _tabLichSuBanHang.style = UIBarButtonItemStyleDone;
    _tabDoiChieu.style = UIBarButtonItemStyleBordered;
    
    [_mainViewTuoiNo removeFromSuperview];
    [self.view addSubview:_mainViewLichSuBanHang];
    
    isTabLichSuBanHangSelected = YES;
    isTabTuoiNoSelected = NO;
    isTabDoiChieuSelected = NO;
}

- (IBAction)tabTuoiNoTapped:(id)sender
{
    if (isTabTuoiNoSelected)
        return;
    
    if (!_mainViewTuoiNo)
    {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"FeTuoiNoView" owner:self options:nil];
        _mainViewTuoiNo = [arr lastObject];
        _mainViewTuoiNo.frame = CGRectMake(0, 44, 768, 916);
    }
    
    _tabTuoiNo.style = UIBarButtonItemStyleDone;
    _tabLichSuBanHang.style = UIBarButtonItemStyleBordered;
    _tabDoiChieu.style = UIBarButtonItemStyleBordered;
    
    [_mainViewLichSuBanHang removeFromSuperview];
    [self.view addSubview:_mainViewTuoiNo];
    
    isTabTuoiNoSelected = YES;
    isTabLichSuBanHangSelected = NO;
    isTabDoiChieuSelected = NO;
}

- (IBAction)tabDoiChieuTapped:(id)sender
{
    if (isTabDoiChieuSelected)
        return;
    
    if (!_mainViewDoiChieu)
    {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"FeDoiChieu" owner:self options:nil];
        _mainViewDoiChieu = [arr lastObject];
        _mainViewDoiChieu.frame = CGRectMake(0, 44, 768, 916);
    }
    
    _tabDoiChieu.style = UIBarButtonItemStyleDone;
    _tabLichSuBanHang.style = UIBarButtonItemStyleBordered;
    _tabTuoiNo.style = UIBarButtonItemStyleBordered;
    
    [_mainViewLichSuBanHang removeFromSuperview];
    [self.view addSubview:_mainViewDoiChieu];
    
    isTabDoiChieuSelected = YES;
    isTabTuoiNoSelected = NO;
    isTabLichSuBanHangSelected = NO;
}

-(NSInteger ) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrLichSuBanHang.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *IDCell = @"CellLichSuBanHang";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:IDCell forIndexPath:indexPath];
    
    UILabel *lblMaSanPham = (UILabel *)[cell viewWithTag:100];
    UILabel *lblSanPham = (UILabel *)[cell viewWithTag:101];
    UILabel *lblSoLuong = (UILabel *)[cell viewWithTag:102];
    UILabel *lblQty = (UILabel *)[cell viewWithTag:103];
    
    // Border
    lblMaSanPham.layer.borderColor = [UIColor blackColor].CGColor;
    lblMaSanPham.layer.borderWidth = 1;
    lblSanPham.layer.borderColor = [UIColor blackColor].CGColor;
    lblSanPham.layer.borderWidth = 1;
    lblSoLuong.layer.borderColor = [UIColor blackColor].CGColor;
    lblSoLuong.layer.borderWidth = 1;
    lblQty.layer.borderColor = [UIColor blackColor].CGColor;
    lblQty.layer.borderWidth = 1;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];

    // Set content
    NSDictionary *dcit = [_arrLichSuBanHang objectAtIndex:indexPath.row];
    NSNumber *amo = [dcit objectForKey:@"Amo"];
    NSNumber *Qty = [dcit objectForKey:@"Qty"];
    
    lblMaSanPham.text = [dcit objectForKey:@"InvtID"];
    lblSanPham.text =[dcit objectForKey:@"Descr"];
    //lblSoLuong.text = [NSString stringWithFormat:@"%.2f",amo.floatValue];
    //lblQty.text = [NSString stringWithFormat:@"%.2f",Qty.floatValue];
    
    lblSoLuong.text = [numberFormatter stringFromNumber:amo];
    lblQty.text = [numberFormatter stringFromNumber:Qty];
    
    return cell;
}
@end
