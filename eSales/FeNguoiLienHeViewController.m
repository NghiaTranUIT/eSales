//
//  FeNguoiLienHeViewController.m
//  eSales
//
//  Created by Nghia Tran on 8/22/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeNguoiLienHeViewController.h"
#import "ActionSheetPicker.h"
#import "FeNguoiDaiDienViewController.h"

@interface FeNguoiLienHeViewController ()
-(void) setupDefaultView;
- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element;
-(void) hideKeyboard;
-(BOOL) isNumberic:(NSString *)string;
@end

@implementation FeNguoiLienHeViewController
@synthesize txbDiaChi = _txbDiaChi, txbDienThoai = _txbDienThoai, txbDienThoaiDD = _txbDienThoaiDD, txbNgayThanhLap = _txbNgayThanhLap, txbNguoiDaiDien = _txbNguoiDaiDien, txbTaiKhoanNganHang = _txbTaiKhoanNganHang, txbTenCongTy = _txbTenCongTy, dictKHMoi=_dictKHMoi;

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
}
-(void) setupDefaultView
{
    // background
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    bg.frame = self.view.frame;
    bg.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view insertSubview:bg atIndex:0];

    NSString *custID = [_dictKHMoi objectForKey:@"CustID"];
    if(custID != nil) //Update KH
    {
        _txbDiaChi.text = [self.dictKHMoi objectForKey:@"AddrCpny"];
        
        _txbNgayThanhLap.text = [self.dictKHMoi objectForKey:@"DateCpny"];
        
        _txbNguoiDaiDien.text = [self.dictKHMoi objectForKey:@"Owner"];
        
        _txbTaiKhoanNganHang.text = [self.dictKHMoi objectForKey:@"BankAccount"];
        
        _txbTenCongTy.text = [self.dictKHMoi objectForKey:@"CpnyName"];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)luuTapped:(id)sender {
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (_txbTenCongTy == textField)
        [_txbDiaChi becomeFirstResponder];
    if (_txbDiaChi == textField)
        [self textFieldShouldBeginEditing:_txbNgayThanhLap];
    
    if (_txbNguoiDaiDien == textField)
        [_txbDienThoai becomeFirstResponder];
    if (_txbDienThoai == textField)
    {
        if ([self isNumberic:_txbDienThoai.text])
        [_txbDienThoaiDD becomeFirstResponder];
        else
        {
            _txbDienThoai.text = @"";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Lỗi" message:@"Số điện thoại không hợp lệ" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }

    }
    if (_txbDienThoaiDD == textField)
    {
        if ([self isNumberic:_txbDienThoaiDD.text])
            [_txbTaiKhoanNganHang becomeFirstResponder];
        else
        {
            _txbDienThoaiDD.text = @"";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Lỗi" message:@"Số điện thoại DĐ không hợp lệ" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
        
    }
    if (_txbTaiKhoanNganHang == textField)
        [_txbTaiKhoanNganHang becomeFirstResponder];
    
    return YES;
}
-(BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == _txbDienThoai)
    {
        if (![self isNumberic:_txbDienThoai.text])
        {
            _txbDienThoai.text = @"";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Lỗi" message:@"Số điện thoại không hợp lệ" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            
            return NO;
        }
    }
    if (textField == _txbDienThoaiDD)
    {
        if (![self isNumberic:_txbDienThoaiDD.text])
        {
            _txbDienThoaiDD.text = @"";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Lỗi" message:@"Số điện thoại không hợp lệ" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            
            return NO;
        }
    }
    return YES;
}
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _txbNgayThanhLap)
    {
        [self hideKeyboard];
        
        ActionSheetDatePicker *actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Ngày Thành Lập" datePickerMode:UIDatePickerModeDate selectedDate:[NSDate date] target:self action:@selector(dateWasSelected:element:) origin:_txbNgayThanhLap];
        [actionSheetPicker showActionSheetPicker];
        
        return NO;
    }
    return YES;
}
- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element {
    // format date
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    _txbNgayThanhLap.text = [format stringFromDate:selectedDate];
}
-(void) hideKeyboard
{
    if (_txbTenCongTy.isFirstResponder)
        [_txbTenCongTy resignFirstResponder];
    if (_txbDiaChi.isFirstResponder)
        [_txbDiaChi resignFirstResponder];
    if (_txbNguoiDaiDien.isFirstResponder)
        [_txbNguoiDaiDien resignFirstResponder];
    if (_txbDienThoai.isFirstResponder)
        [_txbDienThoai resignFirstResponder];
    if (_txbDienThoaiDD.isFirstResponder)
        [_txbDienThoaiDD resignFirstResponder];
    if (_txbTaiKhoanNganHang.isFirstResponder)
        [_txbTaiKhoanNganHang resignFirstResponder];
    
}
-(void) showDatePicker:(id)sender
{
    [self textFieldShouldBeginEditing:_txbNgayThanhLap];
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
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *idSegue = segue.identifier;
    if ([idSegue isEqualToString:@"pushNguoiDaiDien"])
    {
        
        // Save to UserDefault
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        [userDefault setObject:_txbTenCongTy.text forKey:@"3_tenCongTy"];
        [userDefault setObject:_txbDiaChi.text forKey:@"3_diaChi"];
        [userDefault setObject:_txbNgayThanhLap.text forKey:@"3_ngayThanhLap"];
        
        [userDefault setObject:_txbNguoiDaiDien.text forKey:@"3_nguoiDaiDien"];
        [userDefault setObject:_txbDienThoai.text forKey:@"3_dienThoai"];
        [userDefault setObject:_txbDienThoaiDD.text forKey:@"3_dienThoaiDD"];
        
        [userDefault setObject:_txbTaiKhoanNganHang.text forKey:@"3_taiKhoanNH"];
        
        [userDefault synchronize];
        
        // Update
        FeNguoiDaiDienViewController *feNguoiDD = (FeNguoiDaiDienViewController*)segue.destinationViewController;
        feNguoiDD.dictKHMoi = _dictKHMoi;
    }
}
@end
