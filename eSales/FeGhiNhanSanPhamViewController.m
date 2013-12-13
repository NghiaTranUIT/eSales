//
//  FeGhiNhanSanPhamViewController.m
//  eSales
//
//  Created by Nghia Tran on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeGhiNhanSanPhamViewController.h"
#import "FeDatabaseManager.h"
#import <QuartzCore/QuartzCore.h>
#import "ActionSheetPicker.h"

@interface FeGhiNhanSanPhamViewController ()
{
    BOOL isSearching;
    
    BOOL isGhiNhanSanPhamSelected;
    BOOL isGhiNhanTongTienSelected;
    NSInteger isSiteSelected;
}
@property (strong, nonatomic) NSMutableArray *arrSanPham;

@property (strong, nonatomic) NSMutableArray *arrSearching;

@property (strong, nonatomic) NSMutableArray *arrSLDonHang;

@property (strong, nonatomic) NSString *siteSelected;


-(void) setupDefaultView;
@end

@implementation FeGhiNhanSanPhamViewController
@synthesize tableView = _tableView, tabSanPham = _tabSanPham, tabSoTien = _tabSoTien, searchBar = _searchBar, mainSanPham = _mainSanPham, lblTongTien = _lblTongTien, isUpdate=_isUpdate;
@synthesize arrSanPham = _arrSanPham, arrSanPhamSelected = _arrSanPhamSelected, arrSearching = _arrSearching, maDHSelected=_maDHSelected, arrSLDonHang=_arrSLDonHang, siteSelected=_siteSelected;
@synthesize mainTongTien = _mainTongTien, feThongTinDoiThu = _feThongTinDoiThu;

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

    
    isGhiNhanSanPhamSelected = YES;
    isGhiNhanTongTienSelected = NO;
    isSiteSelected = 0;
    
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    bg.frame = self.view.frame;
    bg.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:bg atIndex:0];
    
}

-(void) setupDefaultView
{
    //Price Of Cust
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    _siteSelected = [user objectForKey:@"SiteSelected"];
    
    NSDictionary *activeCust = [user objectForKey:@"ActiveCustomer"];
    NSString *custID = [activeCust objectForKey:@"CustID"];
    NSString *priceClassID = [activeCust objectForKey:@"PriceClassID"];
    if([priceClassID isEqualToString:@""])
        priceClassID = @"";
    
    FeDatabaseManager *db  = [FeDatabaseManager sharedInstance];
    _arrSanPham = [db arrGhiNhanDonHangFromDatabaseWithCustID:custID AndPriceClassID:priceClassID AndSiteID:_siteSelected];
    
    
    _arrSanPhamSelected = [[NSMutableArray alloc] init];
    _arrSearching = [[NSMutableArray alloc] init];
    
    // Update SL
    //NSLog(@"Ma DH: %@", _maDHSelected);
    if(_maDHSelected)
    {
        _arrSLDonHang = [db arrSLGhiNhanDonHangFromDatabaseWithOrderNbr:_maDHSelected];
        _isUpdate = YES;
        
        // get custID can update
        NSMutableDictionary *dict = [_arrSLDonHang objectAtIndex:0];
        NSString *newCustID = [dict objectForKey:@"CustID"];
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:newCustID forKey:@"CustIDUpdate"];

    }else
    {
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:@"" forKey:@"CustIDUpdate"];
    }
    
        
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tabSanPhamTapped:(id)sender
{
    if (isGhiNhanSanPhamSelected)
        return;
    
    // remove
    [_mainTongTien removeFromSuperview];
    [self.view addSubview:_mainSanPham];
    
    // tab bar
    _tabSanPham.style = UIBarButtonItemStyleDone;
    _tabSoTien.style = UIBarButtonItemStyleBordered;
    
    isGhiNhanTongTienSelected = NO;
    isGhiNhanSanPhamSelected = YES;
}

- (IBAction)tabSoTienTapped:(id)sender
{
    if (isGhiNhanTongTienSelected)
        return;
    if (!_mainTongTien)
    {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"GhiNhanTongTien" owner:self options:nil];
        _mainTongTien = [arr lastObject];
        _mainTongTien.frame = CGRectMake(0, 0, 768, 916);
        _mainTongTien.delegate = self;
        _mainTongTien.feGhiNhanSP = self;
        _mainTongTien.feThongTinDoiThu = _feThongTinDoiThu;

    }
    
    // remove
    [_mainSanPham removeFromSuperview];
    [self.view addSubview:_mainTongTien];
    
    // tab bar
    _tabSanPham.style = UIBarButtonItemStyleBordered;
    _tabSoTien.style = UIBarButtonItemStyleDone;
    
    isGhiNhanTongTienSelected = YES;
    isGhiNhanSanPhamSelected = NO;
    
    // reload
    [_mainTongTien reloadTableViewWithArrTongSP:_arrSanPhamSelected];
}
-(void) FeGhiNhanTongTienShouldClose:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)btnXoaTapped:(id)sender
{
    if (isSearching)
    {
        [self searchBarCancelButtonClicked:_searchBar];
    }
}

-(NSInteger ) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isSearching)
        return _arrSearching.count;
    else
        return _arrSanPham.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idCell = @"GhiNhanSanPhamCell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:idCell forIndexPath:indexPath];
    
        // Contetn
    
    NSMutableDictionary *dict;
    if (isSearching)
        dict = [_arrSearching objectAtIndex:indexPath.row];
    else
        dict = [_arrSanPham objectAtIndex:indexPath.row];
    
    NSString *invtID = [dict objectForKey:@"invtID"];
    NSString *desrc = [dict objectForKey:@"desrc"];
    NSString *stkBasePrc = [dict objectForKey:@"stkBasePrc"];
    NSString *SL = [dict objectForKey:@"SL"];
    NSString *SLKM = [dict objectForKey:@"SLKM"];
    NSString *MaCTKM = [dict objectForKey:@"MaCTKM"];
    NSString *QtyVail = [dict objectForKey:@"QtyVail"];
    NSString *OrigQtyVail = [dict objectForKey:@"OrigQtyVail"];    
    NSString *SiteID = [dict objectForKey:@"SiteID"];
    
    
    // UI
    UILabel *lblTenSP = (UILabel *) [cell viewWithTag:100];
    UILabel *lblGiaban = (UILabel *) [cell viewWithTag:101];
    UITextField *lblSoLuong = (UITextField *) [cell viewWithTag:102];
    UITextField *lblSLKM = (UITextField *) [cell viewWithTag:103];
    UITextField *lblMaCTKM = (UITextField *) [cell viewWithTag:104];
    //UILabel *lblMaSP = (UILabel *) [cell viewWithTag:105];
    UITextField *lblSite = (UITextField *) [cell viewWithTag:105];
    UILabel *lblTonKho = (UILabel *) [cell viewWithTag:200];
    
    
    // Border
    lblTenSP.layer.borderColor = [UIColor blackColor].CGColor;
    lblTenSP.layer.borderWidth = 1;
    lblGiaban.layer.borderColor = [UIColor blackColor].CGColor;
    lblGiaban.layer.borderWidth = 1;
    lblSoLuong.layer.borderColor = [UIColor blackColor].CGColor;
    lblSoLuong.layer.borderWidth = 1;
    lblSLKM.layer.borderColor = [UIColor blackColor].CGColor;
    lblSLKM.layer.borderWidth = 1;
    lblMaCTKM.layer.borderColor = [UIColor blackColor].CGColor;
    lblMaCTKM.layer.borderWidth = 1;
    //lblMaSP.layer.borderColor = [UIColor blackColor].CGColor;
    //lblMaSP.layer.borderWidth = 1;
    lblSite.layer.borderColor = [UIColor blackColor].CGColor;
    lblSite.layer.borderWidth = 1;
    lblTonKho.layer.borderColor = [UIColor blackColor].CGColor;
    lblTonKho.layer.borderWidth = 1;
    
    // set conetent
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];

    lblTenSP.text = desrc;
    lblGiaban.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:stkBasePrc.floatValue]];
    lblSLKM.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:SLKM.floatValue]];;
    lblMaCTKM.text = MaCTKM;
    lblTonKho.text = [NSString stringWithFormat:@"%@/%@",QtyVail,OrigQtyVail];
    //lblMaSP.text = invtID;
    lblSoLuong.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:SL.floatValue]];
    
    if(SiteID == nil)
        lblSite.text = _siteSelected;
    else
        lblSite.text = SiteID;
    
    
    NSMutableDictionary *dictSLDH = [self compareInvtID:invtID];
    if(dictSLDH) // update SL
    {
        if([lblSoLuong.text isEqualToString:@"0"])
        {
                // add SL moi len tf
            lblSoLuong.text = [[dictSLDH objectForKey:@"LineQty"] stringValue];
            [dict setObject:@"1" forKey:@"color"];
                
            // add sp selected vao arr
            NSMutableDictionary *dictSLMoi = [_arrSanPham objectAtIndex:indexPath.row];
            [dictSLMoi setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSoLuong.text]] forKey:@"SL"];
            [_arrSanPhamSelected addObject:dictSLMoi];
                
            // Tính lại tổng tiền
            [self checkTongSP];
        }       
    }
    
    // Setcolor
    NSString *color = [dict objectForKey:@"color"];
    switch (color.integerValue)
    {
        case 0:
        {
            cell.contentView.backgroundColor = [UIColor whiteColor];
            break;
        }
        case 2:
        {
            cell.contentView.backgroundColor = [UIColor redColor];
            break;
        }
        case 1:
        {
            cell.contentView.backgroundColor = [UIColor greenColor];
            break;
        }
        default:
            break;
    }

    return cell;
}
-(NSMutableDictionary*)compareInvtID:(NSString *)invtId
{
    for(int i = 0; i < _arrSLDonHang.count; i++)
    {
        NSMutableDictionary *dict = [_arrSLDonHang objectAtIndex:i];
        NSString *dictInvtId = [dict objectForKey:@"InvtID"];
       if([dictInvtId isEqualToString:invtId])
           return dict;
    }
    return nil;
}
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
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
/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >= 8 && range.length == 0)
    {
    	return NO; // return NO to not change text
    }
    else
    {
        return YES;
    }
}
 */
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    //FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    
    UIView *contentView = [textField superview];
    UITableViewCell *cell = (UITableViewCell *)[contentView superview];
    NSIndexPath *index = [_tableView indexPathForCell:cell];
    NSMutableDictionary *dict = [_arrSanPham objectAtIndex:index.row];

    /*
    NSMutableDictionary *dictPrice;
    if (isSearching)
    {
        dictPrice = [_arrSearching objectAtIndex:index.row];
    }   
    else
    {
        dictPrice = [_arrSanPham objectAtIndex:index.row];
    }
    */   
    
    
    NSString *codeColor = [dict valueForKey:@"color"];
    //if (textField.tag != 105)
    //{
        switch (codeColor.integerValue) {
            case 0:
            {
                textField.text = @"";
                break;
            }
            case 2:
            {
                contentView.backgroundColor = [UIColor whiteColor];
                textField.text = @"";
                break;
            }
            case 1:
            {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
                
                textField.text = [NSString stringWithFormat:@"%@",[numberFormatter numberFromString:textField.text]];
                break;
            }
            default:
                break;
        }
        return YES;
    //}
    /*
    else//////////////// chon Site//////////
    {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];

        
        NSString *invtID = [dictPrice objectForKey:@"invtID"];
        
        _arrSite = [db arrSiteFromDatabaseWithInvtID:invtID];
        
        NSMutableArray *site = [[NSMutableArray alloc] initWithCapacity:_arrSite.count];
        for (NSDictionary *dict in _arrSite)
        {
            [site addObject:[dict valueForKey:@"Name"]];
        }
        
        [ActionSheetStringPicker showPickerWithTitle:@"Kho" rows:site initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            
            NSDictionary *dict = [_arrSite objectAtIndex:selectedIndex];
            NSString *siteID = [dict valueForKey:@"SiteID"];                        
            [textField setText:siteID];
            

            float price = [db priceOfSite:siteID AndInvtID:invtID];
            NSLog(@"Price: %f", price);
            [dictPrice setObject:[NSString stringWithFormat:@"%.0f",price] forKey:@"stkBasePrc"];
            [_arrSanPham addObject:dictPrice];
            
            
            UIView *contentView = [textField superview];
            UITableViewCell *cell =(UITableViewCell *) [contentView superview];
            UILabel *lblPrice = (UILabel*) [cell viewWithTag:101];
            
            //if(price > 0)// ko tim thay trong price of cust
            lblPrice.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:price]];
            
            [self checkTongSP];
            
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:textField];
        
        return NO;
    }*/
}
-(BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    
    if (!isSearching)// Ko search
    {
        if ([textField.text isEqualToString:@""] || [textField.text isEqualToString:@"0"])
        {
            textField.text = @"0";
            
            UIView *contentView = [textField superview];
            UITableViewCell *cell = (UITableViewCell *)[contentView superview];
            NSIndexPath *index = [_tableView indexPathForCell:cell];
            NSMutableDictionary *dict = [_arrSanPham objectAtIndex:index.row];
            
            // lbl
            UITextField *lblSoLuong = (UITextField *) [cell viewWithTag:102];
            UITextField *lblSLKM = (UITextField *) [cell viewWithTag:103];
            UITextField *lblMaCTKM = (UITextField *) [cell viewWithTag:104];
            
            
            __weak NSMutableArray *arr = [NSMutableArray arrayWithObjects:lblSoLuong, lblSLKM,lblMaCTKM, nil];
            BOOL isHasValue = NO;
            for (UITextField *lbl in arr)
            {
                if (lbl == textField)
                    continue;
                if ([self isNumberic:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lbl.text]]] && ![lbl.text isEqualToString:@"0"])
                    isHasValue = YES;
                
            }
            if (isHasValue)
            {
                // EDIT
                
                // add Dictionary
                textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:textField.text.floatValue]];
                
                [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSoLuong.text]] forKey:@"SL"];
                [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSLKM.text]] forKey:@"SLKM"];
                [dict setValue:lblMaCTKM.text forKey:@"MaCTKM"];
                
                [dict setValue:@"1" forKey:@"color"];
                
                NSLog(@"EDIT Object withDict = %@",dict);
                
                contentView.backgroundColor = [UIColor greenColor];
                
                // - bot
                NSString *OrigQtyVail = [dict objectForKey:@"OrigQtyVail"];
                NSNumber *numberSoLuong = [numberFormatter numberFromString:lblSoLuong.text];
                NSString *temp = [NSString stringWithFormat:@"%d",OrigQtyVail.integerValue - numberSoLuong.integerValue];
                NSLog(@"temp = %@",temp);
                [dict setValue:temp forKey:@"QtyVail"];
                
                return YES;
            }
            
            //
            
            
            
            if ([_arrSanPhamSelected containsObject:dict])
            {
                [_arrSanPhamSelected removeObject:dict];
                NSLog(@"Removed Dict = %@",dict);
            }
            
            
            // Color cell with White color
            [dict setValue:@"0" forKey:@"color"];
            cell.tag = 0;
            contentView.backgroundColor = [UIColor whiteColor];
        }
        else //////////// add value
        {
            if (![textField.text isEqualToString:@"0"])
            {
                UIView *contentView = [textField superview];
                UITableViewCell *cell = (UITableViewCell *)[contentView superview];
                
                // check error With Red Color
                if ([self isNumbericAllCell:cell])
                {
                    
                    NSIndexPath *index = [_tableView indexPathForCell:cell];
                    NSMutableDictionary *dict = [_arrSanPham objectAtIndex:index.row];
                    
                    // lbl
                    UITextField *lblSoLuong = (UITextField *) [cell viewWithTag:102];
                    UITextField *lblSLKM = (UITextField *) [cell viewWithTag:103];
                    UITextField *lblMaCTKM = (UITextField *) [cell viewWithTag:104];
                    UITextField *lblSiteID = (UITextField *) [cell viewWithTag:105];
                    
                    if (![_arrSanPhamSelected containsObject:dict])
                    {
                        /*
                        // add Dictionary
                        [dict setValue:lblSoLuong.text forKey:@"SL"];
                        [dict setValue:lblSLKM.text forKey:@"SLKM"];
                         */
                        textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:textField.text.floatValue]];
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSoLuong.text]] forKey:@"SL"];
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSLKM.text]] forKey:@"SLKM"];
                        [dict setValue:lblMaCTKM.text forKey:@"MaCTKM"];
                        [dict setValue:lblSiteID.text forKey:@"SiteID"];
                        
                        [dict setValue:@"1" forKey:@"color"];
                        
                        [_arrSanPhamSelected addObject:dict];
                        
                        NSLog(@"added Object withDict no search = %@",dict);
                        
                        contentView.backgroundColor = [UIColor greenColor];
                        
                        // - bot
                        NSString *OrigQtyVail = [dict objectForKey:@"OrigQtyVail"];
                        
                        NSNumber *numberSoLuong = [numberFormatter numberFromString:lblSoLuong.text];
                        
                        NSString *temp = [NSString stringWithFormat:@"%d",OrigQtyVail.integerValue - numberSoLuong.integerValue];
                        
                        NSLog(@"temp = %@",temp);
                        [dict setValue:temp forKey:@"QtyVail"];
                        
                    }
                    else
                    {
                        // EDIT
                        
                        // add Dictionary
                        textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:textField.text.floatValue]];
                        
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSoLuong.text]] forKey:@"SL"];
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSLKM.text]] forKey:@"SLKM"];
                        [dict setValue:lblMaCTKM.text forKey:@"MaCTKM"];
                        
                        [dict setValue:@"1" forKey:@"color"];
                        
                        NSLog(@"EDIT Object withDict = %@",dict);
                        
                        contentView.backgroundColor = [UIColor greenColor];
                        
                        // - bot
                        NSString *OrigQtyVail = [dict objectForKey:@"OrigQtyVail"];
                        NSNumber *numberSoLuong = [numberFormatter numberFromString:lblSoLuong.text];
                        NSString *temp = [NSString stringWithFormat:@"%d",OrigQtyVail.integerValue - numberSoLuong.integerValue];
                        NSLog(@"temp = %@",temp);
                        [dict setValue:temp forKey:@"QtyVail"];


                    }
                    
                    
                }
                else // error
                {
                    //UIView *contentView = [textField superview];
                    //UITableViewCell *cell = (UITableViewCell *)[contentView superview];
                    
                    NSIndexPath *index = [_tableView indexPathForCell:cell];
                    NSMutableDictionary *dict = [_arrSanPham objectAtIndex:index.row];
                    
                    // lbl
                    UITextField *lblSoLuong = (UITextField *) [cell viewWithTag:102];
                    UITextField *lblSLKM = (UITextField *) [cell viewWithTag:103];
                    UITextField *lblMaCTKM = (UITextField *) [cell viewWithTag:104];
                    
                    // Color cell
                    
                    [dict setValue:lblSoLuong.text forKey:@"SL"];
                    [dict setValue:lblSLKM.text forKey:@"SLKM"];
                    [dict setValue:lblMaCTKM.text forKey:@"MaCTKM"];
                    
                    [dict setValue:@"2" forKey:@"color"];
                    cell.tag = 0;
                    
                    contentView.backgroundColor = [UIColor redColor];
                    
                    if ([_arrSanPhamSelected containsObject:dict])
                    {
                        [_arrSanPhamSelected removeObject:dict];
                        NSLog(@"Removed Dict = %@",dict);
                    }
                    
                }
            }
        }
    }
    else  // search
    {
        if ([textField.text isEqualToString:@""] || [textField.text isEqualToString:@"0"])
        {
            textField.text = @"0";
            
            UIView *contentView = [textField superview];
            UITableViewCell *cell = (UITableViewCell *)[contentView superview];
            NSIndexPath *index = [_tableView indexPathForCell:cell];
            NSMutableDictionary *dict = [_arrSearching objectAtIndex:index.row];
            
            // lbl
            UITextField *lblSoLuong = (UITextField *) [cell viewWithTag:102];
            UITextField *lblSLKM = (UITextField *) [cell viewWithTag:103];
            UITextField *lblMaCTKM = (UITextField *) [cell viewWithTag:104];
            
            
            __weak NSMutableArray *arr = [NSMutableArray arrayWithObjects:lblSoLuong, lblSLKM,lblMaCTKM, nil];
            BOOL isHasValue = NO;
            for (UITextField *lbl in arr)
            {
                if (lbl == textField)
                    continue;
                if ([self isNumberic:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lbl.text]]] && ![lbl.text isEqualToString:@"0"])
                    isHasValue = YES;
                
            }
            if (isHasValue)
            {
                // EDIT
                
                // add Dictionary
                textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:textField.text.floatValue]];
                
                [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSoLuong.text]] forKey:@"SL"];
                [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSLKM.text]] forKey:@"SLKM"];
                [dict setValue:lblMaCTKM.text forKey:@"MaCTKM"];
                
                [dict setValue:@"1" forKey:@"color"];
                
                NSLog(@"EDIT Object withDict = %@",dict);
                
                contentView.backgroundColor = [UIColor greenColor];
                
                // - bot
                NSString *OrigQtyVail = [dict objectForKey:@"OrigQtyVail"];
                NSNumber *numberSoLuong = [numberFormatter numberFromString:lblSoLuong.text];
                NSString *temp = [NSString stringWithFormat:@"%d",OrigQtyVail.integerValue - numberSoLuong.integerValue];
                NSLog(@"temp = %@",temp);
                [dict setValue:temp forKey:@"QtyVail"];
                
                return YES;
            }
            
            
            
            if ([_arrSanPhamSelected containsObject:dict])
            {
                [_arrSanPhamSelected removeObject:dict];
                NSLog(@"Removed Dict = %@",dict);
            }
            
            
            // Color cell with White color
            [dict setValue:@"0" forKey:@"color"];
            cell.tag = 0;
            contentView.backgroundColor = [UIColor whiteColor];
        }
        else
        {
            if (![textField.text isEqualToString:@"0"])
            {
                UIView *contentView = [textField superview];
                UITableViewCell *cell = (UITableViewCell *)[contentView superview];
                
                // check error With Red Color
                if ([self isNumbericAllCell:cell])
                {
                    
                    NSIndexPath *index = [_tableView indexPathForCell:cell];
                    NSMutableDictionary *dict = [_arrSearching objectAtIndex:index.row];
                    
                    // lbl
                    UITextField *lblSoLuong = (UITextField *) [cell viewWithTag:102];
                    UITextField *lblSLKM = (UITextField *) [cell viewWithTag:103];
                    UITextField *lblMaCTKM = (UITextField *) [cell viewWithTag:104];
                    UITextField *lblSiteID = (UITextField *) [cell viewWithTag:105];
                    
                    if (![_arrSanPhamSelected containsObject:dict])
                    {
                        textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:textField.text.floatValue]];
                        
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSoLuong.text]] forKey:@"SL"];
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSLKM.text]] forKey:@"SLKM"];
                        [dict setValue:lblMaCTKM.text forKey:@"MaCTKM"];
                        [dict setValue:lblSiteID.text forKey:@"SiteID"];
                        
                        [dict setValue:@"1" forKey:@"color"];
                        
                        [_arrSanPhamSelected addObject:dict];
                        
                        NSLog(@"added Object withDict search = %@",dict);
                        
                        contentView.backgroundColor = [UIColor greenColor];
                        
                        // - bot
                        NSString *OrigQtyVail = [dict objectForKey:@"OrigQtyVail"];
                        NSNumber *numberSoLuong = [numberFormatter numberFromString:lblSoLuong.text];
                        NSString *temp = [NSString stringWithFormat:@"%d",OrigQtyVail.integerValue - numberSoLuong.integerValue];
                        NSLog(@"temp = %@",temp);
                        [dict setValue:temp forKey:@"QtyVail"];
                        
                    }
                    else
                    {
                        // EDIT
                        textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:textField.text.floatValue]];
                        
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSoLuong.text]] forKey:@"SL"];
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSLKM.text]] forKey:@"SLKM"];
                        [dict setValue:lblMaCTKM.text forKey:@"MaCTKM"];
                        
                        [dict setValue:@"1" forKey:@"color"];
                        
                        NSLog(@"EDIT Object withDict = %@",dict);
                        
                        contentView.backgroundColor = [UIColor greenColor];
                        
                        // - bot
                        NSString *OrigQtyVail = [dict objectForKey:@"OrigQtyVail"];
                        NSNumber *numberSoLuong = [numberFormatter numberFromString:lblSoLuong.text];
                        NSString *temp = [NSString stringWithFormat:@"%d",OrigQtyVail.integerValue - numberSoLuong.integerValue];
                        NSLog(@"temp = %@",temp);
                        [dict setValue:temp forKey:@"QtyVail"];
                        
                        
                    }
                    
                }
                else
                {
                    //UIView *contentView = [textField superview];
                    //UITableViewCell *cell = (UITableViewCell *)[contentView superview];
                    
                    NSIndexPath *index = [_tableView indexPathForCell:cell];
                    NSMutableDictionary *dict = [_arrSearching objectAtIndex:index.row];
                    
                    // lbl
                    UITextField *lblSoLuong = (UITextField *) [cell viewWithTag:102];
                    UITextField *lblSLKM = (UITextField *) [cell viewWithTag:103];
                    UITextField *lblMaCTKM = (UITextField *) [cell viewWithTag:104];
                    
                    // Color cell
                    
                    // add Dictionary
                    [dict setValue:lblSoLuong.text forKey:@"SL"];
                    [dict setValue:lblSLKM.text forKey:@"SLKM"];
                    [dict setValue:lblMaCTKM.text forKey:@"MaCTKM"];
                    
                    [dict setValue:@"2" forKey:@"color"];
                    cell.tag = 0;
                    
                    contentView.backgroundColor = [UIColor redColor];
                    
                    if ([_arrSanPhamSelected containsObject:dict])
                    {
                        [_arrSanPhamSelected removeObject:dict];
                        NSLog(@"Removed Dict = %@",dict);
                    }
                    
                }
            }
        }
    }
    
    [self checkTongSP];
    [_tableView reloadData];
    
    return YES;
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(BOOL) isNumbericAllCell:(UITableViewCell *) cell
{
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    NSDictionary *dict; 
    if (!isSearching)
        dict = [_arrSanPham objectAtIndex:indexPath.row];
    else
        dict = [_arrSearching objectAtIndex:indexPath.row];
    
    NSString *OrigQtyVail = [dict objectForKey:@"OrigQtyVail"];
    
    
    // lbl
    UITextField *lblSoLuong = (UITextField *) [cell viewWithTag:102];
    UITextField *lblSLKM = (UITextField *) [cell viewWithTag:103];
    
    if ([lblSoLuong.text isEqualToString:@""])
        lblSoLuong.text = @"0";
    if ([lblSLKM.text isEqualToString:@""])
        lblSLKM.text = @"0";
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    NSString *stringSoLuong = [NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSoLuong.text]];
    NSString *stringSLKM = [NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSLKM.text]];

    /*
    if ([self isNumberic:lblSoLuong.text] && [self isNumberic:lblSLKM.text] && [self isNumberic:lblMaCTKM.text] && (lblSoLuong.text.integerValue <= OrigQtyVail.integerValue))
        return YES;
    return NO;
     */
    
    if ([self isNumberic:stringSoLuong] && [self isNumberic:stringSLKM])
        return YES;
    return NO;
}

-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    isSearching = NO;
    
    
}
-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _searchBar.text = @"";
    isSearching = NO;
    [_tableView reloadData];
    [_searchBar resignFirstResponder];
}

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"**************");
    
    isSearching = YES;
    _arrSearching = [[NSMutableArray alloc] init];
    
    
    
    if (![searchText isEqualToString:@""])
    {
        for (NSMutableDictionary *dict in _arrSanPham)
        {
            NSString *invtID = [dict objectForKey:@"invtID"];
            NSString *desrc = [dict objectForKey:@"desrc"];

            if ([invtID rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [_arrSearching addObject:dict];
            }
            else if ([desrc rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [_arrSearching addObject:dict];
            }
        }
    }
    else
    {
        isSearching = NO;
        [_tableView reloadData];
    }
    [_tableView reloadData];
    
    [self checkTongSP];
}
-(void) checkTongSP
{
    CGFloat tongTien = 0;
    for (NSMutableDictionary *dict in _arrSanPhamSelected)
    {
        NSString *stkBasePrc = [dict objectForKey:@"stkBasePrc"];
        NSString *SL = [dict objectForKey:@"SL"];
        
        
        tongTien += stkBasePrc.floatValue * SL.integerValue;
        
        [dict setValue:[NSString stringWithFormat:@"%.2f",stkBasePrc.floatValue * SL.integerValue] forKey:@"TongTien"];
    }
    
    NSLog(@"Tong tien = %.2f",tongTien);
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    
    _lblTongTien.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:tongTien]];
}
@end
