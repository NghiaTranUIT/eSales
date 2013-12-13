//
//  FeBanHang.m
//  eSales
//
//  Created by Nghia Tran on 8/30/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeBanHang.h"
#import "FeDatabaseManager.h"

@interface FeBanHang ()
{
    
}
-(void) setupDefault;
@property (strong, nonatomic) NSMutableArray *arrSalesSetup;
@end
@implementation FeBanHang
@synthesize checkBox1 = _checkBox1, checkBox1_1 = _checkBox1_1, checkBox2 = _checkBox2, checkBox2_1 = _checkBox2_1, checkBox3 = _checkBox3, checkBox4 = _checkBox4;
@synthesize arrSalesSetup = _arrSalesSetup;

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
    [self setupDefault];
}

-(void) setupDefault
{
    //
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    _arrSalesSetup = [db arrSaleSetupFromDatabase];
    
    BOOL cbx1 = NO;
    BOOL cbx1_1 = NO;
    BOOL cbx2 = NO;
    BOOL cbx2_1 = NO;
    BOOL cbx3 = NO;
    BOOL cbx4 = NO;
    
    for (NSDictionary *dict in _arrSalesSetup)
    {
        NSString *stringSetupID = [dict objectForKey:@"SetupID"];
        if ([stringSetupID isEqualToString:@"chkPlaPre_frmSetting"])
        {
            NSNumber *number = [dict objectForKey:@"Status"];
            cbx1 = number.intValue == 1 ? YES : NO;
        }
        
        if ([stringSetupID isEqualToString:@"chkSalHis_chkPlaPre_frmSetting"])
        {
            NSNumber *number = [dict objectForKey:@"Status"];
            cbx1_1 = number.intValue == 1 ? YES : NO;
        }
        
        if ([stringSetupID isEqualToString:@"chkOutlChk_frmSetting"])
        {
            NSNumber *number = [dict objectForKey:@"Status"];
            cbx2 = number.intValue == 1 ? YES : NO;        }
        
        if ([stringSetupID isEqualToString:@"chkOutsChk_chkOutlChk_frmSetting"])
        {
            NSNumber *number = [dict objectForKey:@"Status"];
            cbx2_1 = number.intValue == 1 ? YES : NO;        }
        
        if ([stringSetupID isEqualToString:@"chkTakOrd_frmSetting"])
        {
            NSNumber *number = [dict objectForKey:@"Status"];
            cbx4 = number.intValue == 1 ? YES : NO;        }
        
        if ([stringSetupID isEqualToString:@"chkMarketInformation_frmSetting"])
        {
            NSNumber *number = [dict objectForKey:@"Status"];
            cbx3 = number.intValue == 1 ? YES : NO;
        }

        
    }
    
    // init Check Box
    _checkBox1 = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(20, 20, 30, 30) style:kSSCheckBoxViewStyleGreen checked:cbx1];
    [self addSubview:_checkBox1];
    
    _checkBox1_1 = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(58, 58, 30, 30) style:kSSCheckBoxViewStyleGreen checked:cbx1_1];
    [self addSubview:_checkBox1_1];
    
    _checkBox2 = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(20, 120, 30, 30) style:kSSCheckBoxViewStyleGreen checked:cbx2];
    [self addSubview:_checkBox2];
    
    _checkBox2_1 = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(58, 158, 30, 30) style:kSSCheckBoxViewStyleGreen checked:cbx2_1];
    [self addSubview:_checkBox2_1];
    
    _checkBox3 = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(20, 217, 30, 30) style:kSSCheckBoxViewStyleGreen checked:cbx3];
    [self addSubview:_checkBox3];
    
    _checkBox4 = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(20, 255, 30, 30) style:kSSCheckBoxViewStyleGreen checked:cbx4];
    [self addSubview:_checkBox4];
            
}

- (IBAction)luuTapped:(id)sender
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setValue:[NSNumber numberWithBool:_checkBox1.checked] forKey:@"chkPlaPre_frmSetting"];
    [dict setValue:[NSNumber numberWithBool:_checkBox1_1.checked] forKey:@"chkSalHis_chkPlaPre_frmSetting"];
    [dict setValue:[NSNumber numberWithBool:_checkBox2.checked] forKey:@"chkOutlChk_frmSetting"];
    [dict setValue:[NSNumber numberWithBool:_checkBox2_1.checked] forKey:@"chkOutsChk_chkOutlChk_frmSetting"];
    [dict setValue:[NSNumber numberWithBool:_checkBox3.checked] forKey:@"chkMarketInformation_frmSetting"];
    [dict setValue:[NSNumber numberWithBool:_checkBox4.checked] forKey:@"chkTakOrd_frmSetting"];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:dict forKey:@"SalesSetup"];
    [user synchronize];
    

    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    [db saveSaleSetupUsingNSUserDefaultWithCompletionHandler:^(BOOL success) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Lưu thành công." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }];
}
@end
