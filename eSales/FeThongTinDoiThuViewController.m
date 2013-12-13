//
//  FeThongTinDoiThuViewController.m
//  eSales
//
//  Created by Nghia Tran on 9/10/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeThongTinDoiThuViewController.h"
#import "FeDatabaseManager.h"
#import <QuartzCore/QuartzCore.h>
#import "FeGhiNhanSanPhamViewController.h"
#import "FeCongViecThucHienViewController.h"

@interface FeThongTinDoiThuViewController ()
{
    BOOL isSearching;
    
    BOOL isSanPhamIFVSelected;
    BOOL isSanPhamDoiThuSelected;
    
    BOOL isTxb_1_OK;
    BOOL isTxb_2_OK;
}
@property (strong, nonatomic) NSMutableArray *arrBrand;

@property (strong, nonatomic) NSMutableArray *arrSearching;
-(void) setupDefaultView;
@end

@implementation FeThongTinDoiThuViewController
@synthesize txbDSTB = _txbDSTB , txbSLTB = _txbSLTB, mainViewSanPhamIVF = _mainViewSanPhamIVF, tabSanPhamDoiThu = _tabSanPhamDoiThu, tabSanPhamIVF = _tabSanPhamIVF, arrBrand = _arrBrand, tableView = _tableView;
@synthesize arrBrandSelected = _arrBrandSelected, mainViewSanPhamDoiThu = _mainViewSanPhamDoiThu;

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
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
}
-(void) setupDefaultView
{
    isSearching = NO;
    FeDatabaseManager *db  = [FeDatabaseManager sharedInstance];
    _arrBrand = [db arrBrancdFromDatabase];
    _arrBrandSelected = [[NSMutableArray alloc] init];
    _arrSearching = [[NSMutableArray alloc] init];
    
    isSanPhamIFVSelected = YES;
    isSanPhamDoiThuSelected = NO;
    isTxb_1_OK = YES;
    isTxb_2_OK = YES;
    
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"FeSanPhamDoiThu" owner:self options:nil];
    _mainViewSanPhamDoiThu = [arr lastObject];
    _mainViewSanPhamDoiThu.frame = CGRectMake(0, 44, 768, 916);
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (IBAction)tabSanPhamIVFTapped:(id)sender
{
    if (isSanPhamIFVSelected)
        return;
    
    // remove
    [_mainViewSanPhamDoiThu removeFromSuperview];
    [self.view addSubview:_mainViewSanPhamIVF];
    
    // tab bar
    _tabSanPhamDoiThu.style = UIBarButtonItemStyleBordered;
    _tabSanPhamIVF.style = UIBarButtonItemStyleDone;
    
    isSanPhamDoiThuSelected = NO;
    isSanPhamIFVSelected = YES;
    
}

- (IBAction)tabSanPhamDoiThuTapped:(id)sender
{
    if (isSanPhamDoiThuSelected)
        return;
    if (!_mainViewSanPhamDoiThu)
    {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"FeSanPhamDoiThu" owner:self options:nil];
        _mainViewSanPhamDoiThu = [arr lastObject];
        _mainViewSanPhamDoiThu.frame = CGRectMake(0, 44, 768, 916);
    }
    
    // remove
    [_mainViewSanPhamIVF removeFromSuperview];
    [self.view addSubview:_mainViewSanPhamDoiThu];
    
    // tab bar
    _tabSanPhamIVF.style = UIBarButtonItemStyleBordered;
    _tabSanPhamDoiThu.style = UIBarButtonItemStyleDone;
    
    isSanPhamDoiThuSelected = YES;
    isSanPhamIFVSelected = NO;
}
- (IBAction)btnXoaTapped:(id)sender
{
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
        return _arrSearching.count;
    else
        return _arrBrand.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idCell = @"cellSanPhamIVF";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:idCell forIndexPath:indexPath];
    
    // Label
    UILabel *lblTenSanPham = (UILabel *)[cell viewWithTag:100];
    UITextField *lblGiaban = (UITextField *)[cell viewWithTag:101];
    UITextField *lblSLTB = (UITextField *)[cell viewWithTag:102];
    UITextField *lblTonKho = (UITextField *)[cell viewWithTag:103];
    UITextField *lblGhiChu = (UITextField *)[cell viewWithTag:104];
    
    // Border
    lblGiaban.layer.borderColor = [UIColor blackColor].CGColor;
    lblGiaban.layer.borderWidth = 1;
    lblTenSanPham.layer.borderColor = [UIColor blackColor].CGColor;
    lblTenSanPham.layer.borderWidth = 1;
    lblSLTB.layer.borderColor = [UIColor blackColor].CGColor;
    lblSLTB.layer.borderWidth = 1;
    lblTonKho.layer.borderColor = [UIColor blackColor].CGColor;
    lblTonKho.layer.borderWidth = 1;
    lblGhiChu.layer.borderColor = [UIColor blackColor].CGColor;
    lblGhiChu.layer.borderWidth = 1;
    
    // Content
    NSDictionary *dict;
    if (isSearching)
        dict = [_arrSearching objectAtIndex:indexPath.row];
    else
        dict = [_arrBrand objectAtIndex:indexPath.row];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    NSString *stringGiaBan = [dict objectForKey:@"GiaBan"];
    NSString *stringSLTB = [dict objectForKey:@"SLTB"];
    NSString *stringTonKho = [dict objectForKey:@"TonKho"];
    
    lblTenSanPham.text = [dict objectForKey:@"Descr"];
    lblGiaban.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:stringGiaBan.floatValue]];
    lblSLTB.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:stringSLTB.floatValue]];
    lblTonKho.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:stringTonKho.floatValue]];
    lblGhiChu.text = [dict objectForKey:@"GhiChu"];
    
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
    UITableViewCell *cell = (UITableViewCell *)[contentView superview];
    NSIndexPath *index = [_tableView indexPathForCell:cell];
    NSMutableDictionary *dict = [_arrBrand objectAtIndex:index.row];
    
    NSString *codeColor = [dict valueForKey:@"color"];
    if(textField.tag != 104)
    {
        switch (codeColor.integerValue)
        {
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
    NSLog(@"text ghi chu = %@",textField.text);
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    
    [textField resignFirstResponder];
    if (textField == _txbDSTB)
    {
        [_txbDSTB resignFirstResponder];
        
        if ([self isNumberic:_txbDSTB.text])
            isTxb_1_OK = YES;
        else
        {
            _txbDSTB.text = @"0";
            isTxb_1_OK = NO;
        }
        
        return YES;
    }
    if (textField == _txbSLTB)
    {
        [_txbSLTB resignFirstResponder];
        
        if ([self isNumberic:_txbSLTB.text])
            isTxb_2_OK = YES;
        else
        {
            isTxb_2_OK = NO;
            _txbSLTB.text = @"0";
        }
        
        return YES;
    }
    
   if (!isSearching)
   {
        if ([textField.text isEqualToString:@""] || [textField.text isEqualToString:@"0"])
        {
            if(textField.tag != 104)
                textField.text = @"0";
            
            UIView *contentView = [textField superview];
            UITableViewCell *cell = (UITableViewCell *)[contentView superview];
            NSIndexPath *index = [_tableView indexPathForCell:cell];
            NSMutableDictionary *dict = [_arrBrand objectAtIndex:index.row];
            
            // lbl
            UITextField *lblGiaban = (UITextField *)[cell viewWithTag:101];
            UITextField *lblSLTB = (UITextField *)[cell viewWithTag:102];
            UITextField *lblTonKho = (UITextField *)[cell viewWithTag:103];
            UITextField *lblGhiChu = (UITextField *)[cell viewWithTag:104];
            
            
            __weak NSMutableArray *arr = [NSMutableArray arrayWithObjects:lblSLTB, lblGiaban,lblTonKho, nil];
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
                if (textField.tag != 104)
                    textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:textField.text.floatValue]];
                
                // add Dictionary
                [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblGiaban.text]] forKey:@"GiaBan"];
                [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSLTB.text]] forKey:@"SLTB"];
                [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblTonKho.text]] forKey:@"TonKho"];
                
                [dict setValue:lblGhiChu.text forKey:@"GhiChu"];
                
                [dict setValue:@"1" forKey:@"color"];
                
                NSLog(@"EDIT Object withDict = %@",dict);
                
                contentView.backgroundColor = [UIColor greenColor];
                return YES;
            }
            
            //
            
            
            
            if ([_arrBrandSelected containsObject:dict])
            {
                [_arrBrandSelected removeObject:dict];
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
                    NSMutableDictionary *dict = [_arrBrand objectAtIndex:index.row];
                    
                    // lbl
                    UITextField *lblGiaban = (UITextField *)[cell viewWithTag:101];
                    UITextField *lblSLTB = (UITextField *)[cell viewWithTag:102];
                    UITextField *lblTonKho = (UITextField *)[cell viewWithTag:103];
                    UITextField *lblGhiChu = (UITextField *)[cell viewWithTag:104];
                    
                    if (![_arrBrandSelected containsObject:dict])
                    {
                        if (textField.tag != 104)
                            textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:textField.text.doubleValue]];
                        
                        // add Dictionary
                        /*
                        [dict setValue:lblGiaban.text forKey:@"GiaBan"];
                        [dict setValue:lblSLTB.text forKey:@"SLTB"];
                        [dict setValue:lblTonKho.text forKey:@"TonKho"];
                        [dict setValue:lblGhiChu.text forKey:@"GhiChu"];
                        */
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblGiaban.text]] forKey:@"GiaBan"];
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSLTB.text]] forKey:@"SLTB"];
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblTonKho.text]] forKey:@"TonKho"];
                        
                        NSLog(@"ghi chu = %@",lblGhiChu.text);
                        
                        [dict setValue:lblGhiChu.text forKey:@"GhiChu"];
                        
                        
                        [dict setValue:@"1" forKey:@"color"];
                        
                        [_arrBrandSelected addObject:dict];
                        
                        NSLog(@"added Object withDict = %@",dict);
                        
                        contentView.backgroundColor = [UIColor greenColor];
                    }
                    else
                    {
                        if (textField.tag != 104)
                            textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:textField.text.floatValue]];
                        
                        // add Dictionary
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblGiaban.text]] forKey:@"GiaBan"];
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSLTB.text]] forKey:@"SLTB"];
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblTonKho.text]] forKey:@"TonKho"];
                        
                        [dict setValue:lblGhiChu.text forKey:@"GhiChu"];
                        
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
                    NSMutableDictionary *dict = [_arrBrand objectAtIndex:index.row];
                    
                    UITextField *lblGiaban = (UITextField *)[cell viewWithTag:101];
                    UITextField *lblSLTB = (UITextField *)[cell viewWithTag:102];
                    UITextField *lblTonKho = (UITextField *)[cell viewWithTag:103];
                    UITextField *lblGhiChu = (UITextField *)[cell viewWithTag:104];
                    
                    // Color cell
                    
                    [dict setValue:lblGiaban.text forKey:@"GiaBan"];
                    [dict setValue:lblSLTB.text forKey:@"SLTB"];
                    [dict setValue:lblTonKho.text forKey:@"TonKho"];
                    [dict setValue:lblGhiChu.text forKey:@"GhiChu"];
                    [dict setValue:@"2" forKey:@"color"];
                    cell.tag = 0;
                     
                    contentView.backgroundColor = [UIColor redColor];
                    
                    if ([_arrBrandSelected containsObject:dict])
                    {
                        [_arrBrandSelected removeObject:dict];
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
            if(textField.tag != 104)
                textField.text = @"0";
            
            UIView *contentView = [textField superview];
            UITableViewCell *cell = (UITableViewCell *)[contentView superview];
            NSIndexPath *index = [_tableView indexPathForCell:cell];
            NSMutableDictionary *dict = [_arrSearching objectAtIndex:index.row];
            
            // lbl
            UITextField *lblGiaban = (UITextField *)[cell viewWithTag:101];
            UITextField *lblSLTB = (UITextField *)[cell viewWithTag:102];
            UITextField *lblTonKho = (UITextField *)[cell viewWithTag:103];
            UITextField *lblGhiChu = (UITextField *)[cell viewWithTag:104];
            
            __weak NSMutableArray *arr = [NSMutableArray arrayWithObjects:lblSLTB, lblGiaban,lblTonKho, nil];
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
                
                if (textField.tag != 104)
                    textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:textField.text.floatValue]];
                
                // add Dictionary
                [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblGiaban.text]] forKey:@"GiaBan"];
                [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSLTB.text]] forKey:@"SLTB"];
                [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblTonKho.text]] forKey:@"TonKho"];
                
                [dict setValue:lblGhiChu.text forKey:@"GhiChu"];
                
                [dict setValue:@"1" forKey:@"color"];
                
                NSLog(@"EDIT Object withDict = %@",dict);
                
                contentView.backgroundColor = [UIColor greenColor];
                return YES;
            }

            
            //
            
            
            
            if ([_arrBrandSelected containsObject:dict])
            {
                [_arrBrandSelected removeObject:dict];
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
                    UITextField *lblGiaban = (UITextField *)[cell viewWithTag:101];
                    UITextField *lblSLTB = (UITextField *)[cell viewWithTag:102];
                    UITextField *lblTonKho = (UITextField *)[cell viewWithTag:103];
                    UITextField *lblGhiChu = (UITextField *)[cell viewWithTag:104];
                    
                    if (![_arrBrandSelected containsObject:dict])
                    {
                        if (textField.tag != 104)
                            textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:textField.text.floatValue]];
                        
                        // add Dictionary
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblGiaban.text]] forKey:@"GiaBan"];
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSLTB.text]] forKey:@"SLTB"];
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblTonKho.text]] forKey:@"TonKho"];
                        
                        [dict setValue:lblGhiChu.text forKey:@"GhiChu"];
                        
                        [dict setValue:@"1" forKey:@"color"];
                        
                        [_arrBrandSelected addObject:dict];
                        
                        NSLog(@"added Object withDict = %@",dict);
                        
                        contentView.backgroundColor = [UIColor greenColor];
                    }
                    else
                    {
                        if (textField.tag != 104)
                            textField.text = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:textField.text.floatValue]];
                        
                        // add Dictionary
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblGiaban.text]] forKey:@"GiaBan"];
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSLTB.text]] forKey:@"SLTB"];
                        [dict setValue:[NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblTonKho.text]] forKey:@"TonKho"];
                        
                        [dict setValue:lblGhiChu.text forKey:@"GhiChu"];
                        
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
                    NSMutableDictionary *dict = [_arrSearching objectAtIndex:index.row];
                    
                    UITextField *lblGiaban = (UITextField *)[cell viewWithTag:101];
                    UITextField *lblSLTB = (UITextField *)[cell viewWithTag:102];
                    UITextField *lblTonKho = (UITextField *)[cell viewWithTag:103];
                    UITextField *lblGhiChu = (UITextField *)[cell viewWithTag:104];
                    
                    // Color cell
                    
                    [dict setValue:lblGiaban.text forKey:@"GiaBan"];
                    [dict setValue:lblSLTB.text forKey:@"SLTB"];
                    [dict setValue:lblTonKho.text forKey:@"TonKho"];
                    [dict setValue:lblGhiChu.text forKey:@"GhiChu"];
                    
                    [dict setValue:@"2" forKey:@"color"];
                    cell.tag = 0;
                    
                    contentView.backgroundColor = [UIColor redColor];
                    
                    if ([_arrBrandSelected containsObject:dict])
                    {
                        [_arrBrandSelected removeObject:dict];
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
    if (textField == _txbDSTB)
    {
        [_txbDSTB resignFirstResponder];
        
        if ([self isNumberic:_txbDSTB.text])
            isTxb_1_OK = YES;
        else
        {
            _txbDSTB.text = @"0";
            isTxb_1_OK = NO;
        }
        
        return YES;
    }
    if (textField == _txbSLTB)
    {
        [_txbSLTB resignFirstResponder];
        
        if ([self isNumberic:_txbSLTB.text])
            isTxb_2_OK = YES;
        else
        {
            isTxb_2_OK = NO;
            _txbSLTB.text = @"0";
        }
        
        return YES;
    }
    
        //[self textFieldShouldEndEditing:textField];
    
    return YES;
}
-(BOOL) isNumbericAllCell:(UITableViewCell *) cell
{
    // lbl
    UITextField *lblGiaban = (UITextField *)[cell viewWithTag:101];
    UITextField *lblSLTB = (UITextField *)[cell viewWithTag:102];
    UITextField *lblTonKho = (UITextField *)[cell viewWithTag:103];
    
    if ([lblGiaban.text isEqualToString:@""])
        lblGiaban.text = @"0";
    if ([lblSLTB.text isEqualToString:@""])
        lblSLTB.text = @"0";
    if ([lblTonKho.text isEqualToString:@""])
        lblTonKho.text = @"0";
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    NSString *stringGiaBan = [NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblGiaban.text]];
    NSString *stringSLTB = [NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblSLTB.text]];
    NSString *stringTonKho = [NSString stringWithFormat:@"%@",[numberFormatter numberFromString:lblTonKho.text]];

    if ([self isNumberic:stringGiaBan] && [self isNumberic:stringSLTB] && [self isNumberic:stringTonKho])
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
        for (NSMutableDictionary *dict in _arrBrand)
        {
            NSString *title = [dict valueForKey:@"Descr"];
            if ([title rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [_arrSearching addObject:dict];
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
-(void) keyboardWillHide:(id)sender
{
    NSLog(@"Will Hide");
    [UIView animateWithDuration:0.35f animations:^{
        _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height + 300);
    } completion:^(BOOL finished) {
        
    }];
    
    
}
-(void) keyboardWillShow:(id)sender
{
    NSLog(@"will Show");
    [UIView animateWithDuration:0.35f animations:^{
        _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, _tableView.frame.size.height - 300);
    } completion:^(BOOL finished) {
        
    }];
    //_tableView.contentOffset = CGPointMake(_tableView.contentOffset.x, _tableView.contentOffset.y + 300);
}

- (IBAction)pushSegue:(id)sender
{
    [self textFieldShouldReturn:_txbDSTB];
    [self textFieldShouldReturn:_txbSLTB];
    [self keyboardWillHide:self];
    
    if (isTxb_1_OK && isTxb_2_OK)
    {
        //[self performSegueWithIdentifier:@"segueGhiNhanSanPham" sender:self];
        [self performSegueWithIdentifier:@"segueCongViecThucHien" sender:self];
        return ;
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"DSTB và SLTB không hợp lệ " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alertView show];
        return ;
    }
    
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *idSegue = segue.identifier;
    if ([idSegue isEqualToString:@"segueCongViecThucHien"])
    {
        // Save to NSUser
        
        FeCongViecThucHienViewController *cvThucHien = segue.destinationViewController;
        cvThucHien.feThongTinDoiThu = self;
    }
    /*
    if ([idSegue isEqualToString:@"segueGhiNhanSanPham"])
    {
        // Save to NSUser
        
        FeGhiNhanSanPhamViewController *ghiNhanSP = segue.destinationViewController;
        ghiNhanSP.feThongTinDoiThu = self;
    }
     */
}
@end
