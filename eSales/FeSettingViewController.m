//
//  FeSettingViewController.m
//  eSales
//
//  Created by Nghia Tran on 8/30/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeSettingViewController.h"
#import "FeDatabaseManager.h"


@interface FeSettingViewController ()
{
    BOOL isTabTaiKhoanSelected;
    BOOL isTabThongSoSelected;
    BOOL isTabBanHangSelected;
}
-(void) setupDefaultView;

// change state
-(void) checkBoxThayDoiTKChanged:(id) sender;
-(void) checkBoxThayDoiMatKhauChangged:(id) sender;
-(void) removeAllMainView;

@property (strong, nonatomic) NSMutableDictionary *setting;
@end

@implementation FeSettingViewController
@synthesize tabBanHang = _tabBanHang, tabTaiKhoan = _tabTaiKhoan, tabThongSo = _tabThongSo, checkBoxThayDoiMatKhau = _checkBoxThayDoiMatKhau, checkBoxThayDoiTK = _checkBoxThayDoiTK, txbBrandID = _txbBrandID, txbMatKhau = _txbMatKhau, txbSlsperID = _txbSlsperID;
@synthesize mainViewTaiKhoan = _mainViewTaiKhoan;
@synthesize setting = _setting;
@synthesize mainViewBanHang = _mainViewBanHang, mainViewThongSo = _mainViewThongSo;
@synthesize delegate = _delegate;

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
    // Tab
    isTabBanHangSelected = NO;
    isTabTaiKhoanSelected = YES;
    isTabThongSoSelected = NO;
    _tabTaiKhoan.style = UIBarButtonItemStyleDone;
    
    // Init check box
    _checkBoxThayDoiTK = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(21, 38, 30, 30) style:kSSCheckBoxViewStyleGreen checked:NO];
    [_checkBoxThayDoiTK setStateChangedTarget:self selector:@selector(checkBoxThayDoiTKChanged:)];
    [_mainViewTaiKhoan addSubview:_checkBoxThayDoiTK];
    
    _checkBoxThayDoiMatKhau = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(21, 245, 30, 30) style:kSSCheckBoxViewStyleGreen checked:NO];
    [_checkBoxThayDoiMatKhau setStateChangedTarget:self selector:@selector(checkBoxThayDoiMatKhauChangged:)];
    [_mainViewTaiKhoan addSubview:_checkBoxThayDoiMatKhau];
    
    //
    [self checkBoxThayDoiMatKhauChangged:_checkBoxThayDoiMatKhau];
    [self checkBoxThayDoiTKChanged:_checkBoxThayDoiTK];
    
    
    // Load something from DB
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    _setting = [NSKeyedUnarchiver unarchiveObjectWithData:[user objectForKey:@"Setting"]];
    NSLog(@"Setting = %@",_setting);
    
    _txbBrandID.text = [_setting valueForKey:@"BranchID"];
    _txbSlsperID.text = [_setting valueForKey:@"SlsperID"];
    _txbMatKhau.text = [_setting valueForKey:@"Password"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tabTaiKhoanTapped:(id)sender
{
    if (isTabTaiKhoanSelected)
        return;
    
    // Remove all
    [self removeAllMainView];
    
    [self.view addSubview:_mainViewTaiKhoan];
    
    isTabTaiKhoanSelected = YES;
    _tabTaiKhoan.style = UIBarButtonItemStyleDone;
    
    [self.view addSubview:_mainViewTaiKhoan];
}

- (IBAction)tabThongSoTapped:(id)sender
{
    if (isTabThongSoSelected)
        return;
    
    // Remove all
    [self removeAllMainView];
    
    if (!_mainViewThongSo)
    {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"ThongSo" owner:self options:nil];
        _mainViewThongSo = [arr lastObject];
        _mainViewThongSo.frame = CGRectMake(0, 44, _mainViewThongSo.frame.size.width, _mainViewThongSo.frame.size.height);
    }
    
    
    
    isTabThongSoSelected = YES;
    _tabThongSo.style = UIBarButtonItemStyleDone;
    
    [self.view addSubview:_mainViewThongSo];
}

- (IBAction)tabBanHangTapped:(id)sender
{
    if (isTabBanHangSelected)
        return;
    
    // Remove all
    [self removeAllMainView];
    
    if (!_mainViewBanHang)
    {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"BanHang" owner:self options:nil];
        _mainViewBanHang = [arr lastObject];
        _mainViewBanHang.frame  =CGRectMake(0, 44, _mainViewBanHang.frame.size.width, _mainViewBanHang.frame.size.height);
    }
    
    
    
    isTabBanHangSelected = YES;
    _tabBanHang.style = UIBarButtonItemStyleDone;
    
    [self.view addSubview:_mainViewBanHang];
}
- (IBAction)luuTapped:(id)sender
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:[user objectForKey:@"Setting"]];
        
    [dict setObject:_txbBrandID.text forKey:@"BranchID"];
    [dict setObject:_txbSlsperID.text forKey:@"SlsperID"];
    [dict setObject:_txbMatKhau.text forKey:@"Password"];
    
    NSLog(@"dict after edit = %@",dict);
    [user setObject:[NSKeyedArchiver archivedDataWithRootObject:dict] forKey:@"Setting"];
    
    [user synchronize];
    
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    [db saveSettingUsingNSUSerDefaultWithCompletionHandler:^(BOOL success)
    {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Cập nhật thành công. Quay lại màn hình đăng nhập." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        
        [_delegate FeSettingDelegateShouldLogout:self];
        
    }];
}
-(void) checkBoxThayDoiMatKhauChangged:(id)sender
{
    if (_checkBoxThayDoiMatKhau.checked)
    {
        _txbMatKhau.enabled = YES;
        _txbMatKhau.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        _txbMatKhau.enabled = NO;
        _txbMatKhau.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1];
    }
}
-(void) checkBoxThayDoiTKChanged:(id)sender
{
    if (_checkBoxThayDoiTK.checked)
    {
        _txbBrandID.enabled = YES;
        _txbSlsperID.enabled = YES;
        
        _txbBrandID.backgroundColor = [UIColor whiteColor];
        _txbSlsperID.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        _txbBrandID.enabled = NO;
        _txbSlsperID.enabled = NO;
        
        _txbBrandID.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1];
        _txbSlsperID.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1];
        
    }
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (_checkBoxThayDoiTK.checked)
    {
        if (textField == _txbSlsperID)
        {
            [_txbBrandID becomeFirstResponder];
        }
        if (textField == _txbBrandID)
        {
            [_txbBrandID resignFirstResponder];
        }
    }
    if (_checkBoxThayDoiMatKhau)
    {
        if (textField == _txbMatKhau)
            [_txbMatKhau resignFirstResponder];
    }
    return YES;
}
-(void) removeAllMainView
{
    isTabBanHangSelected = NO;
    isTabTaiKhoanSelected = NO;
    isTabThongSoSelected = NO;
    
    if (_mainViewBanHang)
        [_mainViewBanHang removeFromSuperview];
    if (_mainViewTaiKhoan)
        [_mainViewTaiKhoan removeFromSuperview];
    if (_mainViewThongSo)
        [_mainViewThongSo removeFromSuperview];
    
    _tabBanHang.style = UIBarButtonItemStyleBordered;
    _tabTaiKhoan.style = UIBarButtonItemStyleBordered;
    _tabThongSo.style = UIBarButtonItemStyleBordered;
}
-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == _txbMatKhau)
    {
        //_txbMatKhau.text = @"";
    }
}
@end
