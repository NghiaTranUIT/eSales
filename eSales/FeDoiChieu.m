//
//  FeDoiChieu.m
//  eSales
//
//  Created by VoVu on 9/28/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeDoiChieu.h"
#import "FeDoiChieuCell.h"
#import "FeDatabaseManager.h"

@interface FeDoiChieu()

@property(nonatomic)CGFloat totalCredit;
@property(nonatomic)CGFloat totalDebit;
@property(nonatomic)CGFloat noThangTruoc;
@property(nonatomic)CGFloat noThangNay;

@property(strong, nonatomic)NSMutableArray *arrDoiChieu;

-(void) setupDefaultView;

@end

@implementation FeDoiChieu

@synthesize tableView=_tableView, arrDoiChieu=_arrDoiChieu, totalCredit=_totalCredit, totalDebit=_totalDebit, txfNoThangNay=_txfNoThangNay, txfNoThangTruoc=_txfNoThangTruoc, txfTotalCredit=_txfTotalCredit, txfTotalDebit=_txfTotalDebit, noThangNay=_noThangNay,
    noThangTruoc=_noThangTruoc;

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
    [self Total];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 41;  
    
}

-(void) setupDefaultView
{
    // get custID
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *activeCust = [user objectForKey:@"ActiveCustomer"];
    NSString *custID = [activeCust objectForKey:@"CustID"];
    
    // DB
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    _arrDoiChieu = [db arrDoiChieuCongNoFromDatabaseWithCustomerID:custID];
    
    
    UINib *nib = [UINib nibWithNibName:@"FeDoiChieuCell" bundle:[NSBundle mainBundle]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"FeDoiChieuCell"];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_arrDoiChieu count];
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *IDCell = @"FeDoiChieuCell";
    
    FeDoiChieuCell *cell = [_tableView dequeueReusableCellWithIdentifier:IDCell forIndexPath:indexPath];
    
    // format number
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    
    // get data
    NSMutableDictionary *dict = [_arrDoiChieu objectAtIndex:indexPath.row];
    
    NSNumber *Debit = [dict objectForKey:@"Debit"];
    NSNumber *Credit = [dict objectForKey:@"Credit"];
    _totalCredit += Credit.floatValue;
    _totalDebit += Debit.floatValue;
    
    cell.lblSoThamChieu.text = [dict objectForKey:@"RefNbr"];
    cell.lblSoHD.text = [dict objectForKey:@"InvNbr"];
    cell.lblNgay.text = [dict objectForKey:@"Date"];
    cell.lblDienGiai.text = [dict objectForKey:@"Desc"];
    cell.lblDoanhSo.text = [numberFormatter stringFromNumber:Debit];
    cell.lblThanhToan.text = [numberFormatter stringFromNumber:Credit];
    
    return cell;
    
}

-(void) Total
{
    _totalDebit = 0;
    _totalCredit = 0;
    _noThangTruoc= 0;
    _noThangNay = 0;
    
    for(int i = 0; i < [_arrDoiChieu count]; i++)
    {
        NSMutableDictionary *dict = [_arrDoiChieu objectAtIndex:i];
        NSNumber *Debit = [dict objectForKey:@"Debit"];
        NSNumber *Credit = [dict objectForKey:@"Credit"];
        _totalCredit += Credit.floatValue;
        _totalDebit += Debit.floatValue;
    }
    // format number
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    
    _noThangNay = _totalDebit - _totalCredit;
    
    _txfNoThangNay.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:_noThangNay]];

    _txfTotalDebit.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:_totalDebit]];
                           
    _txfTotalCredit.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:_totalCredit]];
}
@end
