//
//  FeSanPhamDoiThu.m
//  eSales
//
//  Created by Nghia Tran on 9/11/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeSanPhamDoiThu.h"
#import "FeDatabaseManager.h"
#import "FeThongTinDoiThuCell.h"

@interface FeSanPhamDoiThu()
{
    BOOL isSearching;
}
@property (strong, nonatomic) NSMutableArray *arrSanPhamDoiThu;

@property (strong, nonatomic) NSMutableArray *arrSanPhamDoiThuSearching;
-(void) setupDefaultView;
@end
@implementation FeSanPhamDoiThu
@synthesize tableView = _tableView, searchBar = _searchBar, arrSanPhamDoiThu = _arrSanPhamDoiThu;
@synthesize arrSanPhamDoiThuSelected = _arrSanPhamDoiThuSelected, arrSanPhamDoiThuSearching = _arrSanPhamDoiThuSearching;

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
    isSearching = NO;
    UINib *nib = [UINib nibWithNibName:@"ThongTinDoiThuCell" bundle:[NSBundle mainBundle]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"ThongTinDoiThuCell"];
    
    // set coentet
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *activeCust = [user objectForKey:@"ActiveCustomer"];
    NSString *custID = [activeCust objectForKey:@"CustID"];
    
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    _arrSanPhamDoiThu = [db arrSanPhamDoiThuFromDatabaseWithCustID:custID];
    NSLog(@"_arrSanPhamDoiThu = %@",_arrSanPhamDoiThu);
    
    _arrSanPhamDoiThuSelected = [[NSMutableArray alloc] init];
    
}
- (IBAction)btnXoaTapped:(id)sender {
    if (isSearching)
    {
        [self searchBarCancelButtonClicked:_searchBar];
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
    
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isSearching)
        return _arrSanPhamDoiThuSearching.count;
    return _arrSanPhamDoiThu.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idCEll = @"ThongTinDoiThuCell";
    FeThongTinDoiThuCell *cell = [_tableView dequeueReusableCellWithIdentifier:idCEll forIndexPath:indexPath];
    
    NSDictionary *dict;
    if (isSearching)
        dict = [_arrSanPhamDoiThuSearching objectAtIndex:indexPath.row];
    else
        dict = [_arrSanPhamDoiThu objectAtIndex:indexPath.row];
    
    NSString *ghiChu = [dict objectForKey:@"GhiChu"];
    NSString *tenSP = [dict objectForKey:@"Descr"];
    NSString *giaban = [dict objectForKey:@"StkBasePrc"];
    NSString *SLTB = [dict objectForKey:@"SLTB"];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    
    cell.lblGhiChu.text = ghiChu;
    cell.lblGiaBan.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:giaban.floatValue]];
    cell.lblTenSP.text = tenSP;
    cell.lblSLTB.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:SLTB.floatValue]];
    
    // Set color
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
    
    // delegate
    [cell setAllDelegateTextField:self];
    
    return cell;
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

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    
    
    UIView *contentView = [textField superview];
    FeThongTinDoiThuCell *cell = (FeThongTinDoiThuCell *)[contentView superview];
    NSIndexPath *index = [_tableView indexPathForCell:cell];
    NSMutableDictionary *dict = [_arrSanPhamDoiThu objectAtIndex:index.row];
    
    NSString *codeColor = [dict valueForKey:@"color"];
    if(textField.tag != 103)
    {
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
        
        if ([textField.text isEqualToString:@"0"])
            textField.text = @"";

    }
        
    return YES;
}
-(BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    
    if (!isSearching)
    {
        if ([textField.text isEqualToString:@""] || [textField.text isEqualToString:@"0"])
        {
            if(textField.tag != 103)
                textField.text = @"0";
            
            UIView *contentView = [textField superview];
            FeThongTinDoiThuCell *cell = (FeThongTinDoiThuCell *)[contentView superview];
            NSIndexPath *index = [_tableView indexPathForCell:cell];
            NSMutableDictionary *dict = [_arrSanPhamDoiThu objectAtIndex:index.row];
            
            // lbl
            UITextField *lblGiaban = (UITextField *)[cell viewWithTag:101];
            UITextField *lblSLTB = (UITextField *)[cell viewWithTag:102];
            UITextField *lblGhiChu = (UITextField *)[cell viewWithTag:103];
            
            __weak NSMutableArray *arr = [NSMutableArray arrayWithObjects:lblSLTB, lblGiaban, nil];
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
                if (textField.tag != 103)
                    textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:textField.text.floatValue]];
                
                // add Dictionary
                [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblGiaban.text]] forKey:@"StkBasePrc"];
                [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSLTB.text]] forKey:@"SLTB"];
                [dict setObject:lblGhiChu.text forKey:@"GhiChu"];
                
                
                [dict setValue:@"1" forKey:@"color"];
                
                NSLog(@"EDIT Object withDict = %@",dict);
                
                contentView.backgroundColor = [UIColor greenColor];
                
                return YES;
            }
            
            //
            
            
            
            if ([_arrSanPhamDoiThuSelected containsObject:dict])
            {
                [_arrSanPhamDoiThuSelected removeObject:dict];
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
                FeThongTinDoiThuCell *cell = (FeThongTinDoiThuCell *)[contentView superview];
                
                // check error With Red Color
                if ([self isNumbericAllCell:cell])
                {
                    
                    NSIndexPath *index = [_tableView indexPathForCell:cell];
                    NSMutableDictionary *dict = [_arrSanPhamDoiThu objectAtIndex:index.row];
                    
                    // lbl
                    UITextField *lblGiaban = cell.lblGiaBan;
                    UITextField *lblSLTB = cell.lblSLTB;
                    UITextField *lblGhiChu = cell.lblGhiChu;
                    
                    if (![_arrSanPhamDoiThuSelected containsObject:dict])
                    {
                        if (textField.tag != 103)
                            textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:textField.text.floatValue]];
                        
                        // add Dictionary
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblGiaban.text]] forKey:@"StkBasePrc"];
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSLTB.text]] forKey:@"SLTB"];
                        [dict setObject:lblGhiChu.text forKey:@"GhiChu"];
                        
                        
                        [dict setValue:@"1" forKey:@"color"];
                        
                        [_arrSanPhamDoiThuSelected addObject:dict];
                        
                        NSLog(@"added Object withDict = %@",dict);
                        
                        contentView.backgroundColor = [UIColor greenColor];
                    }
                    else
                    {
                        if (textField.tag != 103)
                            textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:textField.text.floatValue]];
                        
                        // add Dictionary
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblGiaban.text]] forKey:@"StkBasePrc"];
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSLTB.text]] forKey:@"SLTB"];
                        [dict setObject:lblGhiChu.text forKey:@"GhiChu"];
                        
                        [dict setValue:@"1" forKey:@"color"];
                        
                        NSLog(@"EDIT Object withDict = %@",dict);
                        
                        contentView.backgroundColor = [UIColor greenColor];
                    }
                    
                    
                }
                else
                {
                    //UIView *contentView = [textField superview];
                    //UITableViewCell *cell = (UITableViewCell *)[contentView superview];
                    
                    NSIndexPath *index = [_tableView indexPathForCell:cell];
                    NSMutableDictionary *dict = [_arrSanPhamDoiThu objectAtIndex:index.row];
                    
                    UITextField *lblGiaban = cell.lblGiaBan;
                    UITextField *lblSLTB = cell.lblSLTB;

                    
                    // Color cell
                    
                    [dict setValue:lblGiaban.text forKey:@"StkBasePrc"];
                    [dict setValue:lblSLTB.text forKey:@"SLTB"];
                    [dict setValue:@"2" forKey:@"color"];
                    cell.tag = 0;
                    
                    contentView.backgroundColor = [UIColor redColor];
                    
                    if ([_arrSanPhamDoiThuSelected containsObject:dict])
                    {
                        [_arrSanPhamDoiThuSelected removeObject:dict];
                        NSLog(@"Removed Dict = %@",dict);
                    }
                    
                }
            }
        }
    }
    else
    {
        if ([textField.text isEqualToString:@""] || [textField.text isEqualToString:@"0"])
        {
            if(textField.tag != 103)
                textField.text = @"0";
            
            UIView *contentView = [textField superview];
            FeThongTinDoiThuCell *cell = (FeThongTinDoiThuCell *)[contentView superview];
            NSIndexPath *index = [_tableView indexPathForCell:cell];
            NSMutableDictionary *dict = [_arrSanPhamDoiThuSearching objectAtIndex:index.row];
            
            // lbl
            UITextField *lblGiaban = cell.lblGiaBan;
            UITextField *lblSLTB = cell.lblSLTB;
            UITextField *lblGhuChu = cell.lblGhiChu;
            
            __weak NSMutableArray *arr = [NSMutableArray arrayWithObjects:lblSLTB, lblGiaban, nil];
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
                if (textField.tag != 103)
                    textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:textField.text.floatValue]];
                
                // add Dictionary
                [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblGiaban.text]] forKey:@"StkBasePrc"];
                [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSLTB.text]] forKey:@"SLTB"];
                [dict setObject:lblGhuChu.text forKey:@"GhiChu"];
                
                
                [dict setValue:@"1" forKey:@"color"];
                
                NSLog(@"EDIT Object withDict = %@",dict);
                
                contentView.backgroundColor = [UIColor greenColor];
                
                return YES;
            }
            
            
            
            if ([_arrSanPhamDoiThuSelected containsObject:dict])
            {
                [_arrSanPhamDoiThuSelected removeObject:dict];
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
                FeThongTinDoiThuCell *cell = (FeThongTinDoiThuCell *)[contentView superview];
                
                // check error With Red Color
                if ([self isNumbericAllCell:cell])
                {
                    
                    NSIndexPath *index = [_tableView indexPathForCell:cell];
                    NSMutableDictionary *dict = [_arrSanPhamDoiThuSearching objectAtIndex:index.row];
                    
                    // lbl
                    UITextField *lblGiaban = cell.lblGiaBan;
                    UITextField *lblSLTB = cell.lblSLTB;
                    UITextField *lnlGhiChu = cell.lblGhiChu;
                    
                    if (![_arrSanPhamDoiThuSelected containsObject:dict])
                    {
                        if (textField.tag != 103)
                            textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:textField.text.floatValue]];
                        
                        // add Dictionary
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblGiaban.text]] forKey:@"StkBasePrc"];
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSLTB.text]] forKey:@"SLTB"];
                        [dict setObject:lnlGhiChu.text forKey:@"GhiChu"];
                        
                        [dict setValue:@"1" forKey:@"color"];
                        
                        [_arrSanPhamDoiThuSelected addObject:dict];
                        
                        NSLog(@"added Object withDict = %@",dict);
                        
                        contentView.backgroundColor = [UIColor greenColor];
                    }
                    else
                    {
                        if (textField.tag != 103)
                            textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:textField.text.floatValue]];
                        
                        // add Dictionary
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblGiaban.text]] forKey:@"StkBasePrc"];
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSLTB.text]] forKey:@"SLTB"];
                        
                        [dict setObject:lnlGhiChu.text forKey:@"GhiChu"];
                        
                        [dict setValue:@"1" forKey:@"color"];
                        
                        NSLog(@"EDIT Object withDict = %@",dict);
                        
                        contentView.backgroundColor = [UIColor greenColor];
                    }
                    
                }
                else
                {
                    //UIView *contentView = [textField superview];
                    //UITableViewCell *cell = (UITableViewCell *)[contentView superview];
                    
                    NSIndexPath *index = [_tableView indexPathForCell:cell];
                    NSMutableDictionary *dict = [_arrSanPhamDoiThuSearching objectAtIndex:index.row];
                    
                    UITextField *lblGiaban = cell.lblGiaBan;
                    UITextField *lblSLTB = cell.lblSLTB;
                    
                    
                    // Color cell
                    
                    [dict setValue:lblGiaban.text forKey:@"StkBasePrc"];
                    [dict setValue:lblSLTB.text forKey:@"SLTB"];

                    
                    [dict setValue:@"2" forKey:@"color"];
                    cell.tag = 0;
                    
                    contentView.backgroundColor = [UIColor redColor];
                    
                    if ([_arrSanPhamDoiThuSelected containsObject:dict])
                    {
                        [_arrSanPhamDoiThuSelected removeObject:dict];
                        NSLog(@"Removed Dict = %@",dict);
                    }
                    
                }
            }
        }
    }
    return YES;
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(BOOL) isNumbericAllCell:(FeThongTinDoiThuCell *) cell
{
    // lbl
    UITextField *lblGiaban = cell.lblGiaBan;
    UITextField *lblSLTB = cell.lblSLTB;
    
    if ([lblGiaban.text isEqualToString:@""])
        lblGiaban.text = @"0";
    if ([lblSLTB.text isEqualToString:@""])
        lblSLTB.text = @"0";
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    NSString *stringGiaBan = [NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblGiaban.text]];
    NSString *stringSLTB = [NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSLTB.text]];

    
    if ([self isNumberic:stringGiaBan] && [self isNumberic:stringSLTB])
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
    _arrSanPhamDoiThuSearching = [[NSMutableArray alloc] init];
    
    
    
    if (![searchText isEqualToString:@""])
    {
        for (NSMutableDictionary *dict in _arrSanPhamDoiThu)
        {
            NSString *title = [dict valueForKey:@"Descr"];
            if ([title rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [_arrSanPhamDoiThuSearching addObject:dict];
                NSLog(@"add Dict title = %@",title);
            }
        }
    }
    else
    {
        isSearching = NO;
        [_tableView reloadData];
    }
    [_tableView reloadData];
    
    
}

@end
