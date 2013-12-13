//
//  FeNguoiDaiDienViewController.m
//  eSales
//
//  Created by Nghia Tran on 8/22/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeNguoiDaiDienViewController.h"
#import "ActionSheetPicker.h"
#import "FeUtility.h"
#import "FeSanPhamHayBanViewController.h"

@interface FeNguoiDaiDienViewController () <UITextFieldDelegate>
-(void) setupDefault;
- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element;
-(void) hideKeyboard;
-(BOOL) isNumberic:(NSString *)string;
-(BOOL) NSStringIsValidEmail:(NSString *)checkString;

@end

@implementation FeNguoiDaiDienViewController
@synthesize txbDiaChi1 = _txbDiaChi1, txbDiaChi2 = _txbDiaChi2, txbDiaChi3 = _txbDiaChi3, txbDienThoai1 = _txbDienThoai1 , txbDienThoai2 = _txbDienThoai2, txbDienThoai3 = _txbDienThoai3, txbEmail1 = _txbEmail1, txbEmail2 = _txbEmail2, txbEmail3 = _txbEmail3, txbNgaySinh1 = _txbNgaySinh1, txbNgaySinh2 = _txbNgaySinh2, txbNgaySinh3 = _txbNgaySinh3, txbTen2 = _txbTen2, txbTenKH1 = _txbTenKH1, txbTenKH3 = _txbTenKH3, dictKHMoi=_dictKHMoi;
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
    
    [self setupDefault];
}
-(void) setupDefault
{
    // background
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    bg.frame = self.view.frame;
    bg.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:bg atIndex:0];
    
    NSString *custID = [self.dictKHMoi objectForKey:@"CustID"];
    if(custID != nil) //Update KH
    {
        // Dai dien 1
        _txbDiaChi1.text = [self.dictKHMoi objectForKey:@"Addr11"];
        _txbDienThoai1.text = [self.dictKHMoi objectForKey:@"Phone1"];;
        _txbEmail1.text = [self.dictKHMoi objectForKey:@"Email1"];
        _txbNgaySinh1.text = [self.dictKHMoi objectForKey:@"DOB1"];
        _txbTenKH1.text = [self.dictKHMoi objectForKey:@"ContactName1"];
        
        //Dai dien 2
        _txbDiaChi2.text = [self.dictKHMoi objectForKey:@"Addr21"];
        _txbDienThoai2.text = [self.dictKHMoi objectForKey:@"Phone2"];
        _txbEmail2.text = [self.dictKHMoi objectForKey:@"Email2"];
        _txbNgaySinh2.text = [self.dictKHMoi objectForKey:@"DOB2"];
        _txbTen2.text = [self.dictKHMoi objectForKey:@"ContactName2"];
        
        // Dai dien 3
        _txbDiaChi3.text = [self.dictKHMoi objectForKey:@"Addr31"];
        _txbDienThoai3.text = [self.dictKHMoi objectForKey:@"Phone3"];
        _txbEmail3.text = [self.dictKHMoi objectForKey:@"Email3"];
        _txbNgaySinh3.text = [self.dictKHMoi objectForKey:@"DOB3"];
        _txbTenKH3.text = [self.dictKHMoi objectForKey:@"ContactName3"];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txbTenKH1)
        [_txbDiaChi1 becomeFirstResponder];
    if (textField == _txbDiaChi1)
        [_txbDienThoai1 becomeFirstResponder];
    if (textField == _txbDienThoai1)
    {
        if ([self isNumberic:_txbDienThoai1.text])
            [self textFieldShouldBeginEditing:_txbNgaySinh1];
        else
        {
            _txbDienThoai1.text = @"";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Lỗi" message:@"Số điện thoại không hợp lệ" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }
    if (textField == _txbEmail1)
    {
        if ([self NSStringIsValidEmail:_txbEmail1.text])
            [self textFieldShouldBeginEditing:_txbTen2];
        else
        {
            UIAlertView *alert = [FeUtility alertViewWithErrorTitle:@"Lỗi" message:@"Email không hợp lệ"];
            [alert show];
        }
    }
    
    if (textField == _txbTen2)
        [_txbDiaChi2 becomeFirstResponder];
    if (textField == _txbDiaChi2)
        [_txbDienThoai2 becomeFirstResponder];
    if (textField == _txbDienThoai2)
    {
        if ([self isNumberic:_txbDienThoai2.text])
            [self textFieldShouldBeginEditing:_txbNgaySinh2];
        else
        {
            _txbDienThoai2.text = @"";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Lỗi" message:@"Số điện thoại không hợp lệ" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }
    if (textField == _txbEmail2)
    {
        if ([self NSStringIsValidEmail:_txbEmail2.text])
            [self textFieldShouldBeginEditing:_txbTenKH3];
        else
        {
            UIAlertView *alert = [FeUtility alertViewWithErrorTitle:@"Lỗi" message:@"Email không hợp lệ"];
            [alert show];
        }
    }
    
    
    
    if (textField == _txbTenKH3)
        [_txbDiaChi3 becomeFirstResponder];
    if (textField == _txbDiaChi3)
        [_txbDienThoai3 becomeFirstResponder];
    if (textField == _txbDienThoai3)
    {
        if ([self isNumberic:_txbDienThoai3.text])
            [self textFieldShouldBeginEditing:_txbNgaySinh3];
        else
        {
            _txbDienThoai3.text = @"";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Lỗi" message:@"Số điện thoại không hợp lệ" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }
    if (textField == _txbEmail3)
    {
        if (![self NSStringIsValidEmail:_txbEmail3.text])
        {
            UIAlertView *alert = [FeUtility alertViewWithErrorTitle:@"Lỗi" message:@"Email không hợp lệ"];
            [alert show];
        }
    }
    
    return YES;
}
-(BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == _txbDienThoai1)
    {
        if (![self isNumberic:_txbDienThoai1.text])
        {
            _txbDienThoai1.text = @"";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Lỗi" message:@"Số điện thoại không hợp lệ" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            
            return NO;
        }
    }
    if (textField == _txbDienThoai2)
    {
        if (![self isNumberic:_txbDienThoai2.text])
        {
            _txbDienThoai2.text = @"";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Lỗi" message:@"Số điện thoại không hợp lệ" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            
            return NO;
        }
    }
    if (textField == _txbDienThoai3)
    {
        if (![self isNumberic:_txbDienThoai3.text])
        {
            _txbDienThoai3.text = @"";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Lỗi" message:@"Số điện thoại không hợp lệ" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            
            return NO;
        }
    }
    if (textField == _txbEmail1)
    {
        if ([_txbEmail1.text isEqualToString:@""])
            return YES;
        if (![self NSStringIsValidEmail:_txbEmail1.text])
        {
            _txbEmail1.text = @"";
            UIAlertView *alert = [FeUtility alertViewWithErrorTitle:@"Lỗi" message:@"Email không hợp lệ"];
            [alert show];
            return NO;
        }
    }
    if (textField == _txbEmail2)
    {
        if ([_txbEmail2.text isEqualToString:@""])
            return YES;
        if (![self NSStringIsValidEmail:_txbEmail2.text])
        {
            _txbEmail2.text = @"";
            UIAlertView *alert = [FeUtility alertViewWithErrorTitle:@"Lỗi" message:@"Email không hợp lệ"];
            [alert show];
            return NO;
        }
    }
    if (textField == _txbEmail3)
    {
        if ([_txbEmail3.text isEqualToString:@""])
            return YES;
        if (![self NSStringIsValidEmail:_txbEmail3.text])
        {
            _txbEmail3.text = @"";
            UIAlertView *alert = [FeUtility alertViewWithErrorTitle:@"Lỗi" message:@"Email không hợp lệ"];
            [alert show];
            return NO;
        }
    }
    
    return YES;
}
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _txbNgaySinh1)
    {
        [self hideKeyboard];
        
        ActionSheetDatePicker *actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Ngày Sinh" datePickerMode:UIDatePickerModeDate selectedDate:[NSDate date] target:self action:@selector(dateWasSelected:element:) origin:_txbNgaySinh1];
        [actionSheetPicker showActionSheetPicker];
        
        return NO;

    }
    
    if (textField == _txbNgaySinh2)
    {
        [self hideKeyboard];
        
        ActionSheetDatePicker *actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Ngày Sinh" datePickerMode:UIDatePickerModeDate selectedDate:[NSDate date] target:self action:@selector(dateWasSelected:element:) origin:_txbNgaySinh2];
        [actionSheetPicker showActionSheetPicker];
        
        return NO;
        
    }
    if (textField == _txbNgaySinh3)
    {
        [self hideKeyboard];
        
        ActionSheetDatePicker *actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Ngày Sinh" datePickerMode:UIDatePickerModeDate selectedDate:[NSDate date] target:self action:@selector(dateWasSelected:element:) origin:_txbNgaySinh3];
        [actionSheetPicker showActionSheetPicker];
        
        return NO;
        
    }
    
    return  YES;
}
- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element {
    // format date
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    if (element == _txbNgaySinh1)
        _txbNgaySinh1.text = [format stringFromDate:selectedDate];
    if (element == _txbNgaySinh2)
        _txbNgaySinh2.text = [format stringFromDate:selectedDate];
    if (element == _txbNgaySinh3)
        _txbNgaySinh3.text = [format stringFromDate:selectedDate];
}
-(void) hideKeyboard
{
    if (_txbDiaChi1.isFirstResponder)
        [_txbDiaChi1 resignFirstResponder];
    if (_txbTenKH1.isFirstResponder)
        [_txbTenKH1 resignFirstResponder];
    if (_txbDienThoai1.isFirstResponder)
        [_txbDienThoai1 resignFirstResponder];
    if (_txbEmail1.isFirstResponder)
        [_txbEmail1 resignFirstResponder];
    
    if (_txbDiaChi2.isFirstResponder)
        [_txbDiaChi2 resignFirstResponder];
    if (_txbTen2.isFirstResponder)
        [_txbTen2 resignFirstResponder];
    if (_txbDienThoai2.isFirstResponder)
        [_txbDienThoai2 resignFirstResponder];
    if (_txbEmail2.isFirstResponder)
        [_txbEmail2 resignFirstResponder];
    
    if (_txbDiaChi3.isFirstResponder)
        [_txbDiaChi3 resignFirstResponder];
    if (_txbTenKH3.isFirstResponder)
        [_txbTenKH3 resignFirstResponder];
    if (_txbDienThoai3.isFirstResponder)
        [_txbDienThoai3 resignFirstResponder];
    if (_txbEmail3.isFirstResponder)
        [_txbEmail3 resignFirstResponder];
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
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *idSegue = segue.identifier;
    if ([idSegue isEqualToString:@"pushSPHayBan"])
    {
        
        // Save to UserDefault
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        [userDefault setObject:_txbTenKH1.text forKey:@"4_tenKH1"];
        [userDefault setObject:_txbDiaChi1.text forKey:@"4_diaChi1"];
        [userDefault setObject:_txbDienThoai1.text forKey:@"4_dienThoai1"];
        [userDefault setObject:_txbNgaySinh1.text forKey:@"4_ngaySinh1"];
        [userDefault setObject:_txbEmail1.text forKey:@"4_email1"];
        
        [userDefault setObject:_txbTen2.text forKey:@"4_tenKH2"];
        [userDefault setObject:_txbDiaChi2.text forKey:@"4_diaChi2"];
        [userDefault setObject:_txbDienThoai2.text forKey:@"4_dienThoai2"];
        [userDefault setObject:_txbNgaySinh2.text forKey:@"4_ngaySinh2"];
        [userDefault setObject:_txbEmail2.text forKey:@"4_email2"];
        
        [userDefault setObject:_txbTenKH3.text forKey:@"4_tenKH3"];
        [userDefault setObject:_txbDiaChi3.text forKey:@"4_diaChi3"];
        [userDefault setObject:_txbDienThoai3.text forKey:@"4_dienThoai3"];
        [userDefault setObject:_txbNgaySinh3.text forKey:@"4_ngaySinh3"];
        [userDefault setObject:_txbEmail3.text forKey:@"4_email3"];
        
        [userDefault synchronize];
        
        // Update
        FeSanPhamHayBanViewController *feNguoiDD = (FeSanPhamHayBanViewController*)segue.destinationViewController;
        feNguoiDD.dictKHMoi = _dictKHMoi;
    }
}
@end
