//
//  FeTuoiNoView.m
//  eSales
//
//  Created by Nghia Tran on 9/10/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeTuoiNoView.h"
#import "FeTuoiNoCell.h"
#import "FeDatabaseManager.h"

@interface FeTuoiNoView() 
@property (strong, nonatomic) NSMutableArray *arrTuoiNo;
-(void) setupDefaultView;

@end
@implementation FeTuoiNoView
@synthesize txbNoHienTai = _txbNoHienTai, txbTongChuaToiHan = _txbTongChuaToiHan, txbTenKH = _txbTenKH, txbTongQH15Ngay = _txbTongQH15Ngay, txbTongQH7Ngay = _txbTongQH7Ngay, tableView = _tableView, arrTuoiNo = _arrTuoiNo, tbxTongQHTren15Ngay = _tbxTongQHTren15Ngay;

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
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    bg.frame = self.frame;
    bg.contentMode = UIViewContentModeScaleAspectFill;
    self.clipsToBounds = YES;
    [self insertSubview:bg atIndex:0];
}

-(void) setupDefaultView
{
    UINib *nib = [UINib nibWithNibName:@"FeTuoiNoCell" bundle:[NSBundle mainBundle]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"FeTuoiNoCell"];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *activeCust = [user objectForKey:@"ActiveCustomer"];
    NSString *custID = [activeCust objectForKey:@"CustID"];
    
    // Database
    FeDatabaseManager *db  =[FeDatabaseManager sharedInstance];
    _arrTuoiNo = [db arrTuoiNoFromDatabaseWithCustomerID:custID];
    

    // Set some Txb
    CGFloat tongChuaToihan = 0;
    CGFloat tongQH7 = 0;
    CGFloat tongQH15 = 0;
    CGFloat tongQHTran15 = 0;
    
    for (NSDictionary *dict in _arrTuoiNo)
    {
        NSNumber *ChuaToiHan = [dict objectForKey:@"DueYet"];
        NSNumber *QH7 = [dict objectForKey:@"Due7"];
        NSNumber *QH15 = [dict objectForKey:@"Due15"];
        NSNumber *QHTren15 = [dict objectForKey:@"DueOver15"];
        
        tongChuaToihan += ChuaToiHan.floatValue;
        tongQH7 += QH7.floatValue;
        tongQH15 +=QH15.floatValue;
        tongQHTran15 +=QHTren15.floatValue;
    }
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    
    /*
    _txbTongChuaToiHan.text = [NSString stringWithFormat:@"%.2f",tongChuaToihan];
     _txbTongQH7Ngay.text = [NSString stringWithFormat:@"%.2f",tongQH7];
     _txbTongQH15Ngay.text = [NSString stringWithFormat:@"%.2f",tongQH15];
     _tbxTongQHTren15Ngay.text = [NSString stringWithFormat:@"%.2f",tongQHTran15];
    */
    _txbTongChuaToiHan.text =  [numberFormatter stringFromNumber:[NSNumber numberWithFloat:tongChuaToihan]];
    _txbTongQH7Ngay.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:tongQH7]];
    _txbTongQH15Ngay.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:tongQH15]];
    _tbxTongQHTren15Ngay.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:tongQHTran15]];
    
    // Set title
    _txbTenKH.text = [activeCust objectForKey:@"CustName"];
    _txbNoHienTai.text = @"0";
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrTuoiNo.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *IDCell = @"FeTuoiNoCell";
    FeTuoiNoCell *cell = [_tableView dequeueReusableCellWithIdentifier:IDCell forIndexPath:indexPath];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    
    NSDictionary *dict = [_arrTuoiNo objectAtIndex:indexPath.row];
    NSNumber *ChuaToiHan = [dict objectForKey:@"DueYet"];
    NSNumber *HanMuc = [dict objectForKey:@"CreditLimit"];

    NSNumber *QH7 = [dict objectForKey:@"Due7"];
    NSNumber *QH15 = [dict objectForKey:@"Due15"];
    NSNumber *QHTren15 = [dict objectForKey:@"DueOver15"];
    
    /*
    cell.lblChuaToiHan.text = [NSString stringWithFormat:@"%.2f",ChuaToiHan.doubleValue];
    cell.lblHanMuc.text = [NSString stringWithFormat:@"%.2f",HanMuc.doubleValue];
    cell.lblHD.text = [dict objectForKey:@"OrderNumber"];
    cell.lblQH15Ngay.text = [NSString stringWithFormat:@"%.2f",QH15.doubleValue];
    cell.lblQH7Ngay.text = [NSString stringWithFormat:@"%2.f",QH7.doubleValue];
    cell.lblQHTren15Ngay.text = [NSString stringWithFormat:@"%.2f",QHTren15.doubleValue];
    */
    cell.lblChuaToiHan.text = [numberFormatter stringFromNumber:ChuaToiHan];
    cell.lblHanMuc.text = [numberFormatter stringFromNumber:HanMuc];
    cell.lblHD.text = [dict objectForKey:@"OrderNumber"];
    cell.lblQH15Ngay.text = [numberFormatter stringFromNumber:QH15];
    cell.lblQH7Ngay.text = [numberFormatter stringFromNumber:QH7];
    cell.lblQHTren15Ngay.text = [numberFormatter stringFromNumber:QHTren15];
    
    // color Cell
    if (QHTren15.integerValue != 0)
    {
        cell.contentView.backgroundColor = [UIColor redColor];
    }
    else
    {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
    
}
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
@end
