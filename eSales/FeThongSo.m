//
//  FeThongSo.m
//  eSales
//
//  Created by Nghia Tran on 8/30/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeThongSo.h"
#import "FeDatabaseManager.h"
#import "FeWebservice.h"

@interface FeThongSo()
{
    
}
-(void) setupDefaultView;
@property (strong, nonatomic) NSMutableDictionary *setting;
//
-(void) checkBoxInternetChanged:(id) sender;
-(void) checkBoxCucBoChanged:(id) sender;
-(void) checkBox1Changed:(id) sender;
-(void) checkBox2Changed:(id) sender;
-(void) checkBox3Changed:(id) sender;

-(void) hideKeyboard;
-(void) removeAllCheckBox;

@end;
@implementation FeThongSo
@synthesize txbCucBo = _txbCucBo, txbDuongDan = _txbDuongDan, txbInternet = _txbInternet, checkBox1 = _checkBox1, checkBox2 = _checkBox2, checkBox3 = _checkBox3, checkBoxCucBo = _checkBoxCucBo, checkBoxInternet = _checkBoxInternet;
@synthesize setting = _setting;

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
    // Data
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    _setting = [NSKeyedUnarchiver unarchiveObjectWithData:[user valueForKey:@"Setting"]];
    
    NSNumber *isSyncWAN = [_setting objectForKey:@"IsSyncWAN"];
    BOOL boolIsSyncWAN = isSyncWAN.intValue == 1 ? YES : NO;
    
    NSNumber *isStepSales = [_setting objectForKey:@"IsStepSales"];
    BOOL boolIsStepSales = isStepSales.intValue == 1 ? YES : NO;
    
    _txbInternet.text = [_setting objectForKey:@"SyncAddress"];
    _txbCucBo.text = [_setting objectForKey:@"SyncAddressWAN"];
    
    //  Init Chceck Box
    _checkBoxInternet = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(20, 137, 30, 30) style:kSSCheckBoxViewStyleGreen checked:!boolIsSyncWAN];
    [_checkBoxInternet setStateChangedTarget:self selector:@selector(checkBoxInternetChanged:)];
    [self addSubview:_checkBoxInternet];
    
    _checkBoxCucBo = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(20, 213, 30, 30) style:kSSCheckBoxViewStyleGreen checked:boolIsSyncWAN];
    [_checkBoxCucBo setStateChangedTarget:self selector:@selector(checkBoxCucBoChanged:)];
    [self addSubview:_checkBoxCucBo];
    
    _checkBox1 = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(20, 348, 30, 30) style:kSSCheckBoxViewStyleGreen checked:YES];
    [_checkBox1 setStateChangedTarget:self selector:@selector(checkBox1Changed:)];
    [self addSubview:_checkBox1];
    
    _checkBox2 = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(20, 386, 30, 30) style:kSSCheckBoxViewStyleGreen checked:YES];
    [_checkBox2 setStateChangedTarget:self selector:@selector(checkBox2Changed:)];
    [self addSubview:_checkBox2];
    
    _checkBox3 = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(20, 424, 30, 30) style:kSSCheckBoxViewStyleGreen checked:boolIsStepSales];
    [_checkBox3 setStateChangedTarget:self selector:@selector(checkBox3Changed:)];
    [self addSubview:_checkBox3];
    
    // Set unable
    _txbDuongDan.enabled = NO;
    _txbDuongDan.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1];
    
    if (boolIsSyncWAN)
        [self checkBoxCucBoChanged:_checkBoxCucBo];
    else
        [self checkBoxInternetChanged:_checkBoxInternet];
    
    
    
    
}

- (IBAction)luuTapped:(id)sender
{

    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:[user objectForKey:@"Setting"]];
    
    int tempCHeckCucBo = _checkBoxCucBo.checked ? 1 : 0 ;
    [dict setValue:[NSNumber numberWithInt:tempCHeckCucBo] forKey:@"IsSyncWAN"];
    
    int temp = _checkBox3.checked ? 1 : 0;
    [dict setValue:[NSNumber numberWithInt:temp] forKey:@"IsStepSales"];
    
    [dict setValue:_txbInternet.text forKey:@"SyncAddress"];
    [dict setValue:_txbCucBo.text forKey:@"SyncAddressWAN"];
    
    NSLog(@"dict after edit Thong So =  %@",dict);
    [user setObject:[NSKeyedArchiver archivedDataWithRootObject:dict] forKey:@"Setting"];
    [user synchronize];
    
    
    FeDatabaseManager *db = [FeDatabaseManager  sharedInstance];
    [db saveSettingUsingNSUSerDefaultWithCompletionHandler:^(BOOL success) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Cập nhật thành công" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }];
}

- (IBAction)checkConnection:(id)sender
{
    NSString *strURL;
    if (_checkBoxCucBo.checked)
    {
        strURL = _txbCucBo.text;
    }else
    {
        strURL = _txbInternet.text;
    }
     
    
    FeWebservice *ws = [FeWebservice shareInstance];
    
    [ws checkConnectionWithURL:strURL AndCompletionHandler:^(BOOL success)  {
        if (success)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Kết Nối Thành Công." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Kết Nối Không Thành Công. Kiểm Tra Lại Đường Dẫn Đồng Bộ Hoặc Internet." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }];
}


// ************* status changed
-(void) checkBox1Changed:(id)sender
{
    [self hideKeyboard];
}
-(void) checkBox2Changed:(id)sender
{
    [self hideKeyboard];
}
-(void) checkBox3Changed:(id)sender
{
    [self hideKeyboard];
}
-(void) checkBoxCucBoChanged:(id)sender
{
    [self removeAllCheckBox];
    _checkBoxCucBo.checked = YES;
    
    if (_checkBoxCucBo.checked)
    {
        _txbCucBo.enabled = YES;
        _txbCucBo.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        _txbCucBo.enabled = NO;
        _txbCucBo.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1];
    }
}
-(void) checkBoxInternetChanged:(id)sender
{
    [self removeAllCheckBox];
    _checkBoxInternet.checked = YES;
    
    if (_checkBoxInternet.checked)
    {
        _txbInternet.enabled = YES;
        _txbInternet.backgroundColor = [UIColor whiteColor];
        
    }
    else
    {
        _txbInternet.enabled = NO;
        _txbInternet.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1];
    }
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [_txbCucBo resignFirstResponder];
    [_txbInternet resignFirstResponder];
    
    return YES;
}
-(void) hideKeyboard
{
    [_txbCucBo resignFirstResponder];
    [_txbInternet resignFirstResponder];
}
-(void) removeAllCheckBox
{
    _checkBoxCucBo.checked = NO;
    _checkBoxInternet.checked = NO;
    
    _txbCucBo.enabled = NO;
    _txbCucBo.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1];
    _txbInternet.enabled = NO;
    _txbInternet.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1];
    

}
@end
