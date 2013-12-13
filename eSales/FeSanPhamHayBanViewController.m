//
//  FeSanPhamHayBanViewController.m
//  eSales
//
//  Created by Nghia Tran on 8/23/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeSanPhamHayBanViewController.h"
#import "FeDatabaseManager.h"
#import <QuartzCore/QuartzCore.h>
#import "FeNhaPhanPhoiViewController.h"

@interface FeSanPhamHayBanViewController ()
{
    UITableViewCell *cellActived;
    BOOL isSearching;
}
@property (strong, nonatomic) NSMutableArray *arrSanPham;
@property (strong, nonatomic) NSMutableArray *arrSanPhamSelected;
@property (strong, nonatomic) NSMutableArray *arrSearching;
-(void) setupDefaultView;
-(BOOL) isNumberic:(NSString *) string;

// Keyboard
-(void) keyboardWillShow:(id) sender;
-(void) keyboardWillHide:(id) sender;
@end

@implementation FeSanPhamHayBanViewController
@synthesize tableView = _tableView, searchBar = _searchBar, arrSanPham = _arrSanPham, dictKHMoi=_dictKHMoi;
@synthesize arrSearching = _arrSearching;
@synthesize arrSanPhamSelected = _arrSanPhamSelected;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) setupDefaultView
{
    
    
    isSearching = NO;
    _arrSanPhamSelected = [[NSMutableArray alloc] init];
    
    // Database
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    _arrSanPham = [db arrSanPhamFromDatabase];
    
    [_tableView reloadData];
}
- (IBAction)timKiemTapped:(id)sender
{
    
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}
-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (IBAction)xoaTapped:(id)sender
{
    _searchBar.text = @"";
    [self searchBar:_searchBar textDidChange:@""];
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
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
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];

    
    static NSString *idCell = @"cellSanPhamHayBan";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:idCell forIndexPath:indexPath];
    
    NSInteger row = 0;
    if (isSearching)
    {
        row = cell.accessibilityHint.integerValue;
         NSLog(@"YES - Row Dict = %d",row);
    }
    else
    {
        row = indexPath.row;
       
    }
    
    if (!isSearching)
    {
        UILabel *tenSP = (UILabel *) [cell viewWithTag:100];
        UILabel *donVi= (UILabel *) [cell viewWithTag:101];
        UILabel *giaBan= (UILabel *) [cell viewWithTag:102];
        UITextField *soLuong = (UITextField *) [cell viewWithTag:103];
        UITextField *ghiChu = (UITextField *) [cell viewWithTag:104];
        
        // Delegate
        soLuong.delegate =self;
        ghiChu.delegate = self;
        NSMutableDictionary *dict = [_arrSanPham objectAtIndex:row];
        NSString *stringGiaBan = [dict valueForKey:@"stkBasePrc"];
        NSString *stringSoLuong = [dict valueForKey:@"soLuong"];
        
        tenSP.text = [dict valueForKey:@"desrc"];
        donVi.text = [dict valueForKey:@"stkUnit"];
        giaBan.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:stringGiaBan.floatValue]];
        
        // border
        tenSP.layer.borderColor = [UIColor blackColor].CGColor;
        tenSP.layer.borderWidth = 1;
        donVi.layer.borderColor = [UIColor blackColor].CGColor;
        donVi.layer.borderWidth = 1;
        giaBan.layer.borderColor = [UIColor blackColor].CGColor;
        giaBan.layer.borderWidth = 1;
        
        // Set value for So Luong, Ghi Chu
        soLuong.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:stringSoLuong.floatValue]];
        ghiChu.text = [dict valueForKey:@"ghiChu"];

        // Set color
        NSString *codeColor = (NSString *)[dict valueForKey:@"color"];
        switch (codeColor.integerValue)
        {
            case 0:
            {
                cell.contentView.backgroundColor = [UIColor whiteColor];
                break;
            }
            case 1:
            {
                cell.contentView.backgroundColor = [UIColor greenColor];
                break;
            }
            case 2:
            {
                cell.contentView.backgroundColor = [UIColor redColor];
                break;
            }
            default:
                break;
        }
        if (!isSearching)
            cell.accessibilityHint = [NSString stringWithFormat:@"%d",indexPath.row];
        
        return cell;
    }
    else
    {
        UILabel *tenSP = (UILabel *) [cell viewWithTag:100];
        UILabel *donVi= (UILabel *) [cell viewWithTag:101];
        UILabel *giaBan= (UILabel *) [cell viewWithTag:102];
        UITextField *soLuong = (UITextField *) [cell viewWithTag:103];
        UITextField *ghiChu = (UITextField *) [cell viewWithTag:104];
        
        // Delegate
        soLuong.delegate =self;
        ghiChu.delegate = self;
        
        NSMutableDictionary *dict = [_arrSearching objectAtIndex:indexPath.row];
        NSString *stringGiaBan = [dict valueForKey:@"stkBasePrc"];
        NSString *stringSoLuong = [dict valueForKey:@"soLuong"];

        
        tenSP.text = [dict valueForKey:@"desrc"];
        donVi.text = [dict valueForKey:@"stkUnit"];
        giaBan.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:stringGiaBan.floatValue]];
        
        // border
        tenSP.layer.borderColor = [UIColor blackColor].CGColor;
        tenSP.layer.borderWidth = 1;
        donVi.layer.borderColor = [UIColor blackColor].CGColor;
        donVi.layer.borderWidth = 1;
        giaBan.layer.borderColor = [UIColor blackColor].CGColor;
        giaBan.layer.borderWidth = 1;
        
        // Set value for So Luong, Ghi Chu
        soLuong.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:stringSoLuong.floatValue]];
        ghiChu.text = [dict valueForKey:@"ghiChu"];
        
        // Set color
        NSString *codeColor = (NSString *)[dict valueForKey:@"color"];
        switch (codeColor.integerValue)
        {
            case 0:
            {
                cell.contentView.backgroundColor = [UIColor whiteColor];
                break;
            }
            case 1:
            {
                cell.contentView.backgroundColor = [UIColor greenColor];
                break;
            }
            case 2:
            {
                cell.contentView.backgroundColor = [UIColor redColor];
                break;
            }
            default:
                break;
        }
        
        return cell;

    }
    
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
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    //[self textFieldShouldEndEditing:textField];
    [textField resignFirstResponder];
    return YES;
}
-(BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    
    if (textField.tag == 103 ) // So Luong
    {
        if (!isSearching)
        {
            
            if ([textField.text isEqualToString:@""] || [textField.text isEqualToString:@"0"])
            {
                textField.text = @"0";
                
                UIView *contentView = [textField superview];
                UITableViewCell *cell = (UITableViewCell *)[contentView superview];
                NSIndexPath *index = [_tableView indexPathForCell:cell];
                NSMutableDictionary *dict = [_arrSanPham objectAtIndex:index.row];
                
                
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
                    // check error With Red Color
                    if ([self isNumberic:textField.text])
                    {
                        UIView *contentView = [textField superview];
                        UITableViewCell *cell = (UITableViewCell *)[contentView superview];
                        NSIndexPath *index = [_tableView indexPathForCell:cell];
                        NSMutableDictionary *dict = [_arrSanPham objectAtIndex:index.row];
                        UITextField *ghiChu = (UITextField *) [cell viewWithTag:104];
                        
                         if (![_arrSanPhamSelected containsObject:dict])
                         {
                             textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:textField.text.floatValue]];
                             
                             // add Dictionary
                             [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:textField.text]] forKey:@"soLuong"];
                             [dict setValue:ghiChu.text forKey:@"ghiChu"];
                             [dict setValue:@"1" forKey:@"color"];
                             
                             [_arrSanPhamSelected addObject:dict];
                             
                             NSLog(@"added Object withDict = %@",dict);
                             
                             contentView.backgroundColor = [UIColor greenColor];
                             
                             
                             
                             
                         }
                        else // EDIT
                        {
                            textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:textField.text.floatValue]];
                            
                            // add Dictionary
                            [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:textField.text]] forKey:@"soLuong"];
                            [dict setValue:ghiChu.text forKey:@"ghiChu"];
                            [dict setValue:@"1" forKey:@"color"];
                            
                            NSLog(@"EDIT Object withDict = %@",dict);
                            
                            contentView.backgroundColor = [UIColor greenColor];
                        }
                        
                        
                    }
                    else
                    {
                        UIView *contentView = [textField superview];
                        UITableViewCell *cell = (UITableViewCell *)[contentView superview];
                        NSIndexPath *index = [_tableView indexPathForCell:cell];
                        NSMutableDictionary *dict = [_arrSanPham objectAtIndex:index.row];
                        UITextField *ghiChu = (UITextField *) [cell viewWithTag:104];
                        
                        // Color cell
                        [dict setValue:textField.text forKey:@"soLuong"];
                        [dict setValue:ghiChu.text forKey:@"ghiChu"];
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
        else
        {
            if ([textField.text isEqualToString:@""] || [textField.text isEqualToString:@"0"])
            {
                textField.text = @"0";
                
                UIView *contentView = [textField superview];
                UITableViewCell *cell = (UITableViewCell *)[contentView superview];
                NSIndexPath *index = [_tableView indexPathForCell:cell];
                NSMutableDictionary *dict = [_arrSearching objectAtIndex:index.row];
                
                
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
                    // check error With Red Color
                    if ([self isNumberic:textField.text])
                    {
                        UIView *contentView = [textField superview];
                        UITableViewCell *cell = (UITableViewCell *)[contentView superview];
                        NSIndexPath *index = [_tableView indexPathForCell:cell];
                        NSMutableDictionary *dict = [_arrSearching objectAtIndex:index.row];
                        UITextField *ghiChu = (UITextField *) [cell viewWithTag:104];
                        
                        if (![_arrSanPhamSelected containsObject:dict])
                        {
                            textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:textField.text.floatValue]];
                            
                            // add Dictionary
                            [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:textField.text]] forKey:@"soLuong"];
                            [dict setValue:ghiChu.text forKey:@"ghiChu"];
                            [dict setValue:@"1" forKey:@"color"];
                            
                            [_arrSanPhamSelected addObject:dict];
                            
                            NSLog(@"added Object withDict = %@",dict);
                            
                            contentView.backgroundColor = [UIColor greenColor];
                        }
                        else // EDIT
                        {
                            textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:textField.text.floatValue]];
                            
                            // add Dictionary
                            [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:textField.text]] forKey:@"soLuong"];
                            [dict setValue:ghiChu.text forKey:@"ghiChu"];
                            [dict setValue:@"1" forKey:@"color"];
                            
                            NSLog(@"EDIT Object withDict = %@",dict);
                            
                            contentView.backgroundColor = [UIColor greenColor];
                        }

                        
                    }
                    else
                    {
                        UIView *contentView = [textField superview];
                        UITableViewCell *cell = (UITableViewCell *)[contentView superview];
                        NSIndexPath *index = [_tableView indexPathForCell:cell];
                        NSMutableDictionary *dict = [_arrSearching objectAtIndex:index.row];
                        UITextField *ghiChu = (UITextField *) [cell viewWithTag:104];
                        
                        // Color cell
                        [dict setValue:textField.text forKey:@"soLuong"];
                        [dict setValue:ghiChu.text forKey:@"ghiChu"];
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
    }

    
    return YES;
}
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag == 103)
    {
        UIView *contentView = [textField superview];
        UITableViewCell *cell = (UITableViewCell *)[contentView superview];
        NSIndexPath *index = [_tableView indexPathForCell:cell];
        NSMutableDictionary *dict = [_arrSanPham objectAtIndex:index.row];
        
        NSString *codeColor = [dict valueForKey:@"color"];
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
        
        cellActived = cell;
        
        
        
    }
    return YES;
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    /*
    UITextField *soLuong = (UITextField *) [cellActived viewWithTag:103];
    UITextField *ghiChu = (UITextField *) [cellActived viewWithTag:104];
    
    [soLuong resignFirstResponder];
    [ghiChu resignFirstResponder];
     */

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
    isSearching = YES;
    _arrSearching = [[NSMutableArray alloc] init];
    
    
    
    if (![searchText isEqualToString:@""])
    {
        for (NSMutableDictionary *dict in _arrSanPham)
        {
            NSString *title = [dict valueForKey:@"desrc"];
            if ([title rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound)
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
    NSLog(@"reload data");
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *idSegue = segue.identifier;
    if ([idSegue isEqualToString:@"pushNhaPhanPhoi"])
    {
        
        //NSLog(@"save data with Ditc = %@",_arrSanPhamSelected);
        // Save to UserDefault
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:_arrSanPhamSelected forKey:@"5_arrSanPhamSelected"];        
        
        [userDefault synchronize];
        
        // Update
        FeNhaPhanPhoiViewController *feNguoiDD = (FeNhaPhanPhoiViewController*)segue.destinationViewController;
        feNguoiDD.dictKHMoi = _dictKHMoi;
    }
}
-(void) keyboardWillHide:(id)sender
{
    NSLog(@"Will Hide");
    [UIView animateWithDuration:0.35f animations:^{
        _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, 870);
    } completion:^(BOOL finished) {
        
    }];
    
    
}
-(void) keyboardWillShow:(id)sender
{
    NSLog(@"will Show");
    [UIView animateWithDuration:0.35f animations:^{
        _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, 600);
    } completion:^(BOOL finished) {
        
    }];
    //_tableView.contentOffset = CGPointMake(_tableView.contentOffset.x, _tableView.contentOffset.y + 300);
}
@end
