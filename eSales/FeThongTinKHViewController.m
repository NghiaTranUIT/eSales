//
//  FeThongTinKHViewController.m
//  eSales
//
//  Created by Nghia Tran on 8/22/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeThongTinKHViewController.h"
#import "ActionSheetPicker.h"
#import "FeDatabaseManager.h"
#import "FeUtility.h"
#import "FeNguoiLienHeViewController.h"

@interface FeThongTinKHViewController ()
{
    NSInteger isKenhSelected;
    NSInteger isKhuVucSelected;
    NSInteger isLoaiKhachHangSelected;
    NSInteger isLoaiCuaHangSelected;
    NSInteger isLoaiBanHangSelected;
    NSInteger isTPSelected;
    NSInteger isQuanHuyenSelected;
    
    //Boo
    BOOL isDienThoaiOK;
    BOOL isFaxOK;
    BOOL isEmailOK;
}
-(void) setupDefaultView;
-(void) hideKeyboard;
-(BOOL) checkTextField:(NSString *) text;
-(BOOL) NSStringIsValidEmail:(NSString *)checkString;

// database
@property (strong, nonatomic) NSMutableArray *arrKenh;
@property (strong, nonatomic) NSMutableArray *arrKhuVuc;
@property (strong, nonatomic) NSMutableArray *arrNhomKH;
@property (strong, nonatomic) NSMutableArray *arrLoaiCuaHang;
@property (strong, nonatomic) NSMutableArray *arrLoaiBanhang;
@property (strong, nonatomic) NSMutableArray *arrTP;
@property (strong, nonatomic) NSMutableArray *arrQuanHuyen;

-(BOOL) isNumberic:(NSString *)string;
@end

@implementation FeThongTinKHViewController
@synthesize txbDiaChi = _txbDiaChi, txbDienThoai = _txbDienThoai, txbEmail = _txbEmail, txbFax = _txbFax, txbKenh = _txbKenh, txbKhuVuc = _txbKhuVuc, txbLoaiBanHang = _txbLoaiBanHang, txbLoaiCuaHang = _txbLoaiCuaHang, txbNhomKH = _txbNhomKH, txbPhuongXa = _txbPhuongXa, txbQuanHuyen = _txbQuanHuyen, txbTenCuaHang = _txbTenCuaHang, txbTenKH = _txbTenKH, txbThanhPho = _txbThanhPho;
@synthesize arrKenh = _arrKenh,arrKhuVuc = _arrKhuVuc, arrLoaiBanhang= _arrLoaiBanhang, arrLoaiCuaHang = _arrLoaiCuaHang, arrNhomKH = _arrNhomKH, arrQuanHuyen = _arrQuanHuyen, arrTP = _arrTP, dictKHMoi=_dictKHMoi;

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
    
    isDienThoaiOK = YES;
    isFaxOK = YES;
    isEmailOK = YES;
}
-(void) setupDefaultView
{
    // get database
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    _arrKenh = [db arrKenhFromDatabase];
    _arrKhuVuc = [db arrKhuVucFromDatabase];
    _arrNhomKH = [db arrNhomKHFromDatabase];
    _arrLoaiBanhang = [db arrLoaiBanHanFromDatabase];
    _arrLoaiCuaHang = [db arrLoaiCuaHangFromDatabase];
    
    // set background
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    bg.frame = self.view.frame;
    bg.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:bg atIndex:0];
    
    NSString *custID = [self.dictKHMoi objectForKey:@"CustID"];
    if(custID != nil) //Update KH
    {
        //txb
        _txbTenCuaHang.text = [self.dictKHMoi objectForKey:@"OutletName"];
        _txbTenKH.text = [self.dictKHMoi objectForKey:@"ContactName"];
        _txbDiaChi.text = [self.dictKHMoi objectForKey:@"Addr1"];
        _txbDienThoai.text = [self.dictKHMoi objectForKey:@"Phone"];
        _txbFax.text = [self.dictKHMoi objectForKey:@"Fax"];
        _txbEmail.text = [self.dictKHMoi objectForKey:@"Email"];
        _txbPhuongXa.text = [self.dictKHMoi objectForKey:@"Ward"];
        
        //pickers
        NSDictionary *dictKenh = [self getKenhFromCode:[self.dictKHMoi objectForKey:@"Channel"] inArray:_arrKenh];
        isKenhSelected = [[dictKenh objectForKey:@"Index"] intValue];
        _txbKenh.text = [dictKenh objectForKey:@"Descr"];
        
        
        NSDictionary *dictKV = [self getKhuVucFromCode:[self.dictKHMoi objectForKey:@"Area"] inArray:_arrKhuVuc];
        isKhuVucSelected = [[dictKV objectForKey:@"Index"] intValue];
        _txbKhuVuc.text = [dictKV objectForKey:@"Descr"];
        
        
        NSDictionary *dictLoaiKH = [self getNhomKHFromCode:[self.dictKHMoi objectForKey:@"ClassId"] inArray:_arrNhomKH];
        isLoaiKhachHangSelected = [[dictLoaiKH objectForKey:@"Index"] intValue];
        _txbNhomKH.text = [dictLoaiKH objectForKey:@"Descr"];
        
        
        NSDictionary *dictLoaiCuaHang = [self getLoaiCuaHangFromCode:[self.dictKHMoi objectForKey:@"ShopType"] inArray:_arrLoaiCuaHang];
        isLoaiCuaHangSelected = [[dictLoaiCuaHang objectForKey:@"Index"] intValue];
        _txbLoaiCuaHang.text = [dictLoaiCuaHang objectForKey:@"Descr"];
        
        
        NSDictionary *dictLoaiBanHang = [self getLoaiBanHangFromCode:[self.dictKHMoi objectForKey:@"TradeType"] inArray:_arrLoaiBanhang];
        isLoaiBanHangSelected = [[dictLoaiBanHang objectForKey:@"Index"] intValue];
        _txbLoaiBanHang.text = [dictLoaiBanHang objectForKey:@"Descr"];
        
        
        _arrTP = [db arrTPFromDatabaseWithIDKhucVuc:[[_arrKhuVuc objectAtIndex:isKhuVucSelected] valueForKey:@"Area"]];
        NSDictionary *dictTP = [self getTPFromCode:[self.dictKHMoi objectForKey:@"City"] inArray:_arrTP];
        isTPSelected = [[dictTP objectForKey:@"Index"] intValue];
        _txbThanhPho.text = [dictTP objectForKey:@"Descr"];
        
        
        _arrQuanHuyen = [db arrQuanHuyenFromDatabaseWithIDThanhPho:[[_arrTP objectAtIndex:isTPSelected] valueForKey:@"State"]];
        NSDictionary *dictQuan = [self getQuanFromCode:[self.dictKHMoi objectForKey:@"District"] inArray:_arrQuanHuyen];
        isQuanHuyenSelected = [[dictQuan objectForKey:@"Index"] intValue];
        _txbQuanHuyen.text = [dictQuan objectForKey:@"Name"];
        
    }else // Them Moi KH
    {
        isKenhSelected = 0;
        _txbKenh.text = [[_arrKenh objectAtIndex:isKenhSelected] valueForKey:@"Descr"];
        
        isKhuVucSelected = 0;
        _txbKhuVuc.text = [[_arrKhuVuc objectAtIndex:isKhuVucSelected] valueForKey:@"Descr"];
        
        isLoaiKhachHangSelected = 0;
        _txbNhomKH.text = [[_arrNhomKH objectAtIndex:isLoaiKhachHangSelected] valueForKey:@"Descr"];
        
        isLoaiCuaHangSelected = 0;
        _txbLoaiCuaHang.text = [[_arrLoaiCuaHang objectAtIndex:isLoaiCuaHangSelected] valueForKey:@"Descr"];
        
        isLoaiBanHangSelected = 0;
        _txbLoaiBanHang.text = [[_arrLoaiBanhang objectAtIndex:isLoaiBanHangSelected] valueForKey:@"Descr"];
        
        _arrTP = [db arrTPFromDatabaseWithIDKhucVuc:[[_arrKhuVuc objectAtIndex:isKhuVucSelected] valueForKey:@"Area"]];
        isTPSelected = 0;
        _txbThanhPho.text = [[_arrTP objectAtIndex:isTPSelected] valueForKey:@"Descr"];
        
        _arrQuanHuyen = [db arrQuanHuyenFromDatabaseWithIDThanhPho:[[_arrTP objectAtIndex:isTPSelected] valueForKey:@"State"]];
        isQuanHuyenSelected = 0;
        _txbQuanHuyen.text = [[_arrQuanHuyen objectAtIndex:isQuanHuyenSelected] valueForKey:@"Descr"];
    }
}

// get index kenh
-(NSDictionary*)getKenhFromCode:(NSString*)code inArray:(NSMutableArray*)arrKenh
{
    int index = 0;
    
    for(NSDictionary *dict in arrKenh)
    {
        if([code isEqualToString: [dict objectForKey:@"Code"]])
        {
            NSString *Descr = [dict objectForKey:@"Descr"];
            
            NSDictionary *dictIndex = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:index],@"Index",Descr,@"Descr", nil];
            return dictIndex;
        }
        index++;
    }
    return nil; //ko tim thay
}
// get index khu vuc
-(NSDictionary*)getKhuVucFromCode:(NSString*)code inArray:(NSMutableArray*)arrKV
{
    int index = 0;
    
    for(NSDictionary *dict in arrKV)
    {
        if([code isEqualToString: [dict objectForKey:@"Area"]])
        {
            NSString *Descr = [dict objectForKey:@"Descr"];
            
            NSDictionary *dictIndex = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:index],@"Index",Descr,@"Descr", nil];
            return dictIndex;
        }
        index++;
    }
    return nil; //ko tim thay
}
// get index nhom KH
-(NSDictionary*)getNhomKHFromCode:(NSString*)code inArray:(NSMutableArray*)arrNhomKH
{
    int index = 0;
    
    for(NSDictionary *dict in arrNhomKH)
    {
        if([code isEqualToString: [dict objectForKey:@"ClassId"]])
        {
            NSString *Descr = [dict objectForKey:@"Descr"];
            
            NSDictionary *dictIndex = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:index],@"Index",Descr,@"Descr", nil];
            return dictIndex;
        }
        index++;
    }
    return nil; //ko tim thay
}
// get index loai ban hang
-(NSDictionary*)getLoaiBanHangFromCode:(NSString*)code inArray:(NSMutableArray*)arrLoaiBanHang
{
    int index = 0;
    
    for(NSDictionary *dict in arrLoaiBanHang)
    {
        if([code isEqualToString: [dict objectForKey:@"Code"]])
        {
            NSString *Descr = [dict objectForKey:@"Descr"];
            
            NSDictionary *dictIndex = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:index],@"Index",Descr,@"Descr", nil];
            return dictIndex;
        }
        index++;
    }
    return nil; //ko tim thay
}
// get index loai cua hang
-(NSDictionary*)getLoaiCuaHangFromCode:(NSString*)code inArray:(NSMutableArray*)arrLoaiCuaHang
{
    int index = 0;
    
    for(NSDictionary *dict in arrLoaiCuaHang)
    {
        if([code isEqualToString: [dict objectForKey:@"Code"]])
        {
            NSString *Descr = [dict objectForKey:@"Descr"];
            
            NSDictionary *dictIndex = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:index],@"Index",Descr,@"Descr", nil];
            return dictIndex;
        }
        index++;
    }
    return nil; //ko tim thay
}
// get index TP
-(NSDictionary*)getTPFromCode:(NSString*)code inArray:(NSMutableArray*)arrTP
{
    int index = 0;
    
    for(NSDictionary *dict in arrTP)
    {
        if([code isEqualToString: [dict objectForKey:@"State"]])
        {
            NSString *Descr = [dict objectForKey:@"Descr"];
            
            NSDictionary *dictIndex = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:index],@"Index",Descr,@"Descr", nil];
            return dictIndex;
        }
        index++;
    }
    return nil; //ko tim thay
}

// get index Quan Huyen
-(NSDictionary*)getQuanFromCode:(NSString*)code inArray:(NSMutableArray*)arrQuan
{
    int index = 0;
    
    for(NSDictionary *dict in arrQuan)
    {
        if([code isEqualToString: [dict objectForKey:@"District"]])
        {
            NSString *Name = [dict objectForKey:@"Name"];
            
            NSDictionary *dictIndex = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:index],@"Index",Name,@"Name", nil];
            return dictIndex;
        }
        index++;
    }
    return nil; //ko tim thay
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveTapped:(id)sender
{
    
}

- (IBAction)nexTapped:(id)sender
{
    if (_txbDienThoai.isFirstResponder)
        [self textFieldShouldReturn:_txbDienThoai];
    if (_txbEmail.isFirstResponder)
        [self textFieldShouldReturn:_txbEmail];
    
    if ([self checkTextField:_txbTenCuaHang.text] && [self checkTextField:_txbTenKH.text]
        && [self checkTextField:_txbDiaChi.text] )
    {
        if (isDienThoaiOK && isEmailOK)
            [self performSegueWithIdentifier:@"segueNguoiLienHe" sender:self];
        else
        {
            if (!isDienThoaiOK)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Lỗi" message:@"Số Điện Thoại không hợp lệ." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
                return;
            }
            if (!isEmailOK)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Lỗi" message:@"Email không hợp lệ." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
                return;
            }
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Lỗi" message:@"Tên cửa hàng, Tên KH, Địa chỉ không được để trống." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}
-(BOOL) checkTextField:(NSString *)text
{
    [text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    
    if (text.length == 0)
        return NO;
    return YES;
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
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txbTenCuaHang)
       [ _txbTenKH becomeFirstResponder];
    if (textField == _txbTenKH)
        [_txbDiaChi becomeFirstResponder];
    if (textField == _txbDiaChi)
        [ _txbDienThoai becomeFirstResponder];
    if (textField == _txbDienThoai)
    {
        if ([self isNumberic:_txbDienThoai.text])
        {
            isDienThoaiOK = YES;
            [_txbFax becomeFirstResponder];
        }
        else
        {
            isDienThoaiOK = NO;
            _txbDienThoai.text = @"";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Lỗi" message:@"Số điện thoại không hợp lệ" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }
    if (textField == _txbFax)
        [ _txbEmail becomeFirstResponder];
    if (textField == _txbEmail) 
    {
        if ([self NSStringIsValidEmail:_txbEmail.text])
            [self textFieldShouldBeginEditing:_txbKenh];
        else
        {
            UIAlertView *alert = [FeUtility alertViewWithErrorTitle:@"Lỗi" message:@"Email không hợp lệ"];
            [alert show];
        }
    }
    
    if (textField == _txbKenh)
    {
        
        //[ _txbKenh becomeFirstResponder];
    }
    if (textField == _txbKhuVuc)
        //[_txbKhuVuc becomeFirstResponder];
    if (textField == _txbNhomKH)
        //[ _txbNhomKH becomeFirstResponder];
    if (textField == _txbLoaiCuaHang)
        //[_txbLoaiCuaHang becomeFirstResponder];
    if (textField == _txbLoaiBanHang)
        //[ _txbLoaiBanHang becomeFirstResponder];
    if (textField == _txbThanhPho)
        //[_txbThanhPho becomeFirstResponder];
    if (textField == _txbQuanHuyen)
        //[ _txbQuanHuyen becomeFirstResponder];
        
    if (textField == _txbPhuongXa)
        [_txbPhuongXa becomeFirstResponder];

    return YES;
}
-(BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == _txbDienThoai)
    {
        if (![self isNumberic:_txbDienThoai.text])
        {
            isDienThoaiOK = NO;
            _txbDienThoai.text = @"";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Lỗi" message:@"Số điện thoại không hợp lệ" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            
            return NO;
        }
        else
        {
            isDienThoaiOK = YES;
        }
    }
    if (textField == _txbEmail)
    {
        if ([_txbEmail.text isEqualToString:@""])
            return YES;
        if (![self NSStringIsValidEmail:_txbEmail.text])
        {
            isEmailOK = NO;
            _txbEmail.text = @"";
            UIAlertView *alert = [FeUtility alertViewWithErrorTitle:@"Lỗi" message:@"Email không hợp lệ"];
            [alert show];
            return NO;
        }
        else
        {
            isEmailOK = YES;
        }
    }

    return YES;
}
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    
    if (textField == _txbKenh)
    {
        // init array for picker
        NSMutableArray *kenh = [[NSMutableArray alloc] initWithCapacity:_arrKenh.count];
        for (NSDictionary *dict in _arrKenh)
        {
            [kenh addObject:[dict valueForKey:@"Descr"]];
        }
        
        [self hideKeyboard];
        
        [ActionSheetStringPicker showPickerWithTitle:@"Kênh" rows:kenh initialSelection:isKenhSelected doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            _txbKenh.text = (NSString *) selectedValue;
            isKenhSelected = selectedIndex;
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:_txbKenh];
        return NO;
    }
    if (textField == _txbKhuVuc)
    {
        NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:_arrKhuVuc.count];
        for (NSDictionary *dict in _arrKhuVuc)
        {
            [arr addObject:[dict valueForKey:@"Descr"]];
        }
        
        [self hideKeyboard];
        
        [ActionSheetStringPicker showPickerWithTitle:@"Khu vực" rows:arr initialSelection:isKhuVucSelected doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
        {
            _txbKhuVuc.text = (NSString *) selectedValue;
            isKhuVucSelected = selectedIndex;
            
            // set arrTP
            _arrTP = [db arrTPFromDatabaseWithIDKhucVuc:[[_arrKhuVuc objectAtIndex:isKhuVucSelected] valueForKey:@"Area"]];
            isTPSelected = 0;
            
            NSLog(@"_arrTP = %@",_arrTP);
            
            if (_arrTP.count == 0)
            {
                _txbThanhPho.text = @"Không có giá trị";
                isTPSelected = -1;
                
                // Gan ali gia tri gia3
                NSDictionary *row = [NSDictionary dictionaryWithObjectsAndKeys:@"0",@"State",@"Khong Co Gia Tri",@"Descr", nil];
                
                _arrTP = [[NSMutableArray alloc] init];
                [_arrTP addObject:row];
                
                _arrQuanHuyen = [[NSMutableArray alloc] init];
            }
            else
            {
                _txbThanhPho.text = [[_arrTP objectAtIndex:isTPSelected] valueForKey:@"Descr"];
                
                _arrQuanHuyen = [db arrQuanHuyenFromDatabaseWithIDThanhPho:[[_arrTP objectAtIndex:isTPSelected] valueForKey:@"State"]];
            }
            
            
            if (_arrQuanHuyen.count == 0)
            {
                _txbQuanHuyen.text = @"Không có giá trị";
                isQuanHuyenSelected = -1;
                
                 NSDictionary *row = [NSDictionary dictionaryWithObjectsAndKeys:@"0",@"District",@"Khong Co Gia Tri",@"Name", nil];
                _arrQuanHuyen = [[NSMutableArray alloc] init];
                [_arrQuanHuyen addObject:row];
            }
            else
            {
                isQuanHuyenSelected = 0;
                _txbQuanHuyen.text = [[_arrQuanHuyen objectAtIndex:isQuanHuyenSelected] valueForKey:@"Name"];
            }
            
        } cancelBlock:^(ActionSheetStringPicker *picker)
        {
            
        } origin:_txbKhuVuc];
        return NO;
    }
    if (textField == _txbNhomKH)
    {
        NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:_arrNhomKH.count];
        for (NSDictionary *dict in _arrNhomKH)
        {
            [arr addObject:[dict valueForKey:@"Descr"]];
        }
        
        [self hideKeyboard];
        
        [ActionSheetStringPicker showPickerWithTitle:@"Nhóm KH" rows:arr initialSelection:isLoaiKhachHangSelected doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            _txbNhomKH.text = (NSString *) selectedValue;
            isLoaiKhachHangSelected = selectedIndex;
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:_txbNhomKH];
        return NO;
    }
    if (textField == _txbLoaiCuaHang)
    {
        NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:_arrLoaiCuaHang.count];
        for (NSDictionary *dict in _arrLoaiCuaHang)
        {
            [arr addObject:[dict valueForKey:@"Descr"]];
        }
        
        [self hideKeyboard];
        
        [ActionSheetStringPicker showPickerWithTitle:@"Loại cửa hàng" rows:arr initialSelection:isLoaiCuaHangSelected doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            _txbLoaiCuaHang.text = (NSString *) selectedValue;
            isLoaiCuaHangSelected = selectedIndex;
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:_txbLoaiCuaHang];
        return NO;
    }
    if (textField == _txbLoaiBanHang)
    {
        NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:_arrLoaiBanhang.count];
        for (NSDictionary *dict in _arrLoaiBanhang)
        {
            [arr addObject:[dict valueForKey:@"Descr"]];
        }
        
        [self hideKeyboard];
        
        [ActionSheetStringPicker showPickerWithTitle:@"Loại bán hàng" rows:arr initialSelection:isLoaiBanHangSelected doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            _txbLoaiBanHang.text = (NSString *) selectedValue;
            isLoaiBanHangSelected = selectedIndex;
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:_txbLoaiBanHang];
        return NO;
    }
    if (textField == _txbThanhPho)
    {
        if (isTPSelected != -1)
        {
            NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:_arrTP.count];
            for (NSDictionary *dict in _arrTP)
            {
                [arr addObject:[dict valueForKey:@"Descr"]];
            }
            
            [self hideKeyboard];
            
            [ActionSheetStringPicker showPickerWithTitle:@"Thành phố" rows:arr initialSelection:isTPSelected doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                _txbThanhPho.text = (NSString *) selectedValue;
                isTPSelected = selectedIndex;
                
                _arrQuanHuyen = [db arrQuanHuyenFromDatabaseWithIDThanhPho:[[_arrTP objectAtIndex:isTPSelected] valueForKey:@"State"]];
                isQuanHuyenSelected = 0;
                _txbQuanHuyen.text = [[_arrQuanHuyen objectAtIndex:isQuanHuyenSelected] valueForKey:@"Name"];
                
            } cancelBlock:^(ActionSheetStringPicker *picker) {
                
            } origin:_txbThanhPho];
            return NO;
        }
        else
            return NO;
    }
    if (textField == _txbQuanHuyen)
    {
        if (isQuanHuyenSelected != -1)
        {
            NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:_arrQuanHuyen.count];
            for (NSDictionary *dict in _arrQuanHuyen)
            {
                [arr addObject:[dict valueForKey:@"Name"]];
            }
            
            [self hideKeyboard];
            
            [ActionSheetStringPicker showPickerWithTitle:@"Quận huyện" rows:arr initialSelection:isQuanHuyenSelected doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                _txbQuanHuyen.text = (NSString *) selectedValue;
                isQuanHuyenSelected = selectedIndex;
            } cancelBlock:^(ActionSheetStringPicker *picker) {
                
            } origin:_txbQuanHuyen];
            return NO;
        }
        else
            return NO;
    }
    return YES;
}
-(void) hideKeyboard
{
    if (_txbTenCuaHang.isFirstResponder)
        [_txbTenCuaHang resignFirstResponder];
    if (_txbTenKH.isFirstResponder)
        [_txbTenKH resignFirstResponder];
    if (_txbDiaChi.isFirstResponder)
        [_txbDiaChi resignFirstResponder];
    if (_txbDienThoai.isFirstResponder)
        [_txbDienThoai resignFirstResponder];
    if (_txbFax.isFirstResponder)
        [_txbFax resignFirstResponder];
    if (_txbEmail.isFirstResponder)
        [_txbEmail resignFirstResponder];
    if (_txbPhuongXa.isFirstResponder)
        [_txbPhuongXa resignFirstResponder];

    
}
-(BOOL) isNumberic:(NSString *)string
{
    BOOL result = NO;
    if ([string isEqualToString:@""])
        return YES;
    
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
    if ([idSegue isEqualToString:@"segueNguoiLienHe"])
    {
        
        // Save to UserDefault
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        [userDefault setObject:_txbTenCuaHang.text forKey:@"2_tenCuaHang"];
        [userDefault setObject:_txbTenKH.text forKey:@"2_tenKH"];
        [userDefault setObject:_txbDiaChi.text forKey:@"2_diaChiDayDu"];
        
        [userDefault setObject:_txbDienThoai.text forKey:@"2_dienThoai"];
        [userDefault setObject:_txbFax.text forKey:@"2_fax"];
        [userDefault setObject:_txbEmail.text forKey:@"2_email"];
        
        [userDefault setObject:[_arrKenh objectAtIndex:isKenhSelected] forKey:@"2_dictKenh"];
        [userDefault setObject:[_arrKhuVuc objectAtIndex:isKhuVucSelected] forKey:@"2_dictKhuVuc"];
        [userDefault setObject:[_arrNhomKH objectAtIndex:isLoaiKhachHangSelected] forKey:@"2_dictNhomKH"];
        
        [userDefault setObject:[_arrLoaiCuaHang objectAtIndex:isLoaiCuaHangSelected] forKey:@"2_dictLoaiCuaHang"];
        [userDefault setObject:[_arrLoaiBanhang objectAtIndex:isLoaiBanHangSelected] forKey:@"2_dictLoaiBanHang"];
        if (isTPSelected != -1)
            [userDefault setObject:[_arrTP objectAtIndex:isTPSelected] forKey:@"2_dictTP"];
        else
        {
            [userDefault setObject:[_arrTP objectAtIndex:0] forKey:@"2_dictTP"];
        }
        if (isQuanHuyenSelected != -1)
            [userDefault setObject:[_arrQuanHuyen objectAtIndex:isQuanHuyenSelected] forKey:@"2_dictQuanHuyen"];
        else
        {
            [userDefault setObject:[_arrQuanHuyen objectAtIndex:0] forKey:@"2_dictQuanHuyen"];
        }
        
        [userDefault setObject:_txbPhuongXa.text forKey:@"2_phuongXa"];
        
        [userDefault synchronize];
        
        //Update
        FeNguoiLienHeViewController *feNguoiLH = (FeNguoiLienHeViewController*)segue.destinationViewController;
        feNguoiLH.dictKHMoi = _dictKHMoi;
    }
}
@end
