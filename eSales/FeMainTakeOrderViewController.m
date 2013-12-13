//
//  FeMainTakeOrderViewController.m
//  eSales
//
//  Created by Nghia Tran on 9/5/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeMainTakeOrderViewController.h"
#import "FeDatabaseManager.h"
#import "ActionSheetPicker.h"
#import <QuartzCore/QuartzCore.h>
#import "FeDetailCustomer.h"

@interface FeMainTakeOrderViewController () <FeDeTailViewDelegate>
{
    NSInteger indexTimTheo;
    BOOL isCheckBoxChecked;
    BOOL isSearching;
    
    // Index selected Cell
    NSIndexPath *selectedIndex;
}
@property (strong, nonatomic) NSMutableArray *arrDSKhachHang;
@property (strong, nonatomic) NSMutableArray *arrSearching;
@property (strong, nonatomic) NSMutableArray *arrTimKiem;
@property (strong, nonatomic) NSString *dateSelected;
@property (strong, nonatomic) FeDetailCustomer *detailCustomer;

-(void) setupDefaultView;
- (void)dateWasSelected:(NSDate *)selectedDate element:(id)element;
-(void) checkBoxTatCaKHChecked:(id) sender;
@end

@implementation FeMainTakeOrderViewController
@synthesize txbNgayVT = _txbNgayVT, txbTimTheo = _txbTimTheo, searchBar = _searchBar, mainViewDSKhachHang = _mainViewDSKhachHang, tableView = _tableView;
@synthesize arrDSKhachHang = _arrDSKhachHang, arrTimKiem = _arrTimKiem, dateSelected = _dateSelected;
@synthesize  checkBoxTatCaKH = _checkBoxTatCaKH, toolBar = _toolBar;
@synthesize arrSearching = _arrSearching, detailCustomer = _detailCustomer;

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

-(void) setupDefaultView
{
    isSearching = NO;
    _arrSearching = [[NSMutableArray alloc] init];
    
    // Init SubView with checkBox
    _checkBoxTatCaKH = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(223, 4, 35, 35) style:kSSCheckBoxViewStyleGreen checked:NO];
    [_checkBoxTatCaKH setStateChangedTarget:self selector:@selector(checkBoxTatCaKHChecked:)];
    [_toolBar addSubview:_checkBoxTatCaKH];
    isCheckBoxChecked = NO;
    
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    _dateSelected = [db stringMaxDateFromDatabase];
    NSLog(@"_dateSelected = %@",_dateSelected);
    
    // Set text Ngay VT
    // **********************
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd 00:00:00"];
    NSDate *date = [format dateFromString:_dateSelected];
    NSLog(@"date = %@",date);
    
    NSDateFormatter *newFormat = [[NSDateFormatter alloc] init];
    [newFormat setDateFormat:@"yyy-MM-dd"];
    _txbNgayVT.text = [newFormat stringFromDate:date];
    NSLog(@"_txbNgayVT = %@",_txbNgayVT);
    
    // Arr DS KH
    // **********************
    //_arrDSKhachHang = [db arrGSPDSKhachHangFromDatabaseAtDate:_dateSelected];
    _arrDSKhachHang = [db arrDSKhachHangFromDatabaseAtDate:_dateSelected];
    if (!_arrDSKhachHang || _arrDSKhachHang.count == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"Không tìm thấy khách hàng" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alertView show];
        
    }
    
    NSLog(@"original = %@",_arrDSKhachHang);
    
    _arrTimKiem = [[NSMutableArray alloc] initWithObjects:@"Tất cả", nil];
    indexTimTheo = 0;
    _txbTimTheo.text = [_arrTimKiem objectAtIndex:indexTimTheo];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    // remove Keyboard
    if (isSearching || _searchBar.isFirstResponder )
    {
        [_searchBar resignFirstResponder];
        [self searchBarCancelButtonClicked:_searchBar];
    }
    
    if (textField == _txbNgayVT)
    {
        NSLog(@"_dateSelected = %@",_dateSelected);
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd 00:00:00"];
        NSDate *date = [format dateFromString:_dateSelected];
        
        ActionSheetDatePicker *actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Ngày VT" datePickerMode:UIDatePickerModeDate selectedDate:date target:self action:@selector(dateWasSelected:element:) origin:_txbNgayVT];
        
        [actionSheetPicker showActionSheetPicker];
        
        return NO;
        
    }
    if (textField == _txbTimTheo)
    {
        ActionSheetStringPicker *stringPicker = [[ActionSheetStringPicker alloc] initWithTitle:@"Tìm theo ?" rows:_arrTimKiem initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
         {
             _txbTimTheo.text = (NSString *) selectedValue;
         } cancelBlock:^(ActionSheetStringPicker *picker)
         {
             
         } origin:_txbTimTheo];
        
        [stringPicker showActionSheetPicker];
        
        return NO;
    }
    return YES;

    
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [_txbTimTheo resignFirstResponder];
    
    return YES;
}
-(void) dateWasSelected:(NSDate *)selectedDate element:(id)element
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd 00:00:00"];
    NSString *date = [format stringFromDate:selectedDate];
    _dateSelected = date;
    
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    //_arrDSKhachHang = [db arrGSPDSKhachHangFromDatabaseAtDate:date];
     _arrDSKhachHang = [db arrDSKhachHangFromDatabaseAtDate:_dateSelected];
    NSLog(@"_arr DSKH after filter by Date = %@",_arrDSKhachHang);
    if (!_arrDSKhachHang || _arrDSKhachHang.count == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"Không tìm thấy khách hàng" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alertView show];
        [_tableView reloadData];
    }
    else
    {
        [_tableView reloadData];
    }
    
    // Set title
    [format setDateFormat:@"yyyy-MM-dd"];
    _txbNgayVT.text = [format stringFromDate:selectedDate];
    
    // uncheck textBox
    _checkBoxTatCaKH.checked = NO;

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
        return _arrDSKhachHang.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idCell = @"KhachHangCell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:idCell forIndexPath:indexPath];
    
    // SubView
    UILabel *maKH = (UILabel *) [cell viewWithTag:100];
    UILabel *tenKH = (UILabel *) [cell viewWithTag:101];
    UILabel *diaChi = (UILabel *) [cell viewWithTag:102];
    
    // Set Layer
    maKH.layer.borderColor = [UIColor blackColor].CGColor;
    maKH.layer.borderWidth =1 ;
    tenKH.layer.borderColor = [UIColor blackColor].CGColor;
    tenKH.layer.borderWidth =1 ;
    diaChi.layer.borderColor = [UIColor blackColor].CGColor;
    diaChi.layer.borderWidth =1 ;
    
    // Set content
    NSMutableDictionary *dict;
    
    if (isSearching)
    {
        dict = [_arrSearching objectAtIndex:indexPath.row];
    }
    else
    {
        dict = [_arrDSKhachHang objectAtIndex:indexPath.row];
    }
    NSString *stringMaKH = [dict objectForKey:@"CustID"];
    NSString *stringTenKH = [dict objectForKey:@"CustName"];
    NSString *stringDiaChi = [dict objectForKey:@"Addr1"];
    NSString *stringColor = [dict objectForKey:@"Color"];
    
    maKH.text = stringMaKH;
    tenKH.text = stringTenKH;
    diaChi.text = stringDiaChi;
    
    switch (stringColor.integerValue) {
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
        default:
            break;
    }
    return cell;
}
-(void) checkBoxTatCaKHChecked:(id)sender
{
    isCheckBoxChecked = _checkBoxTatCaKH.checked;
    if (isCheckBoxChecked)
    {
        FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
        _arrDSKhachHang = [db arrALLDSKhachHangFromDatabase];
        NSLog(@"Arr ALL = %@",_arrDSKhachHang);
        
        [_tableView reloadData];
    }
    else
    {
        FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
        _arrDSKhachHang = [db arrDSKhachHangFromDatabaseAtDate:_dateSelected];
        
        [_tableView reloadData];
    }
}
-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{ 
    isSearching = NO;
    _searchBar.text = @"";
    [_searchBar resignFirstResponder];
    
    [_tableView reloadData];
}
-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [_searchBar becomeFirstResponder];
}
-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _arrSearching = [[NSMutableArray alloc] init];
    
    if (![searchText isEqualToString:@""])
    {
        isSearching = YES;
        for (NSMutableDictionary *dict in _arrDSKhachHang)
        {
            NSString *title = [dict valueForKey:@"CustName"];
            NSString *custID = [dict objectForKey:@"CustID"];
            NSString *addr = [dict objectForKey:@"Addr1"];
            
            if ([title rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [_arrSearching addObject:dict];
            }
            else if ([custID rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [_arrSearching addObject:dict];
            }
            else if ([addr rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [_arrSearching addObject:dict];
            }
        }
        [_tableView reloadData];
    }
    else
    {
        isSearching = NO;
        [_tableView reloadData];
    }

}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Dismiss Keyboard
    [_searchBar resignFirstResponder];
    
    NSDictionary *dict;
    if (isSearching)
    {
        dict = [_arrSearching objectAtIndex:indexPath.row];
    }
    else
        dict = [_arrDSKhachHang objectAtIndex:indexPath.row];
    
    if (!_detailCustomer)
    {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"FeDetailCustomer" owner:self options:nil];
        _detailCustomer = [arr lastObject];
        _detailCustomer.alpha = 0;
        _detailCustomer.delegate = self;
        _detailCustomer.frame = CGRectMake(0, 0, _detailCustomer.frame.size.width, _detailCustomer.frame.size.height);
        [self.view addSubview:_detailCustomer];
    }
    
    [_detailCustomer reSetupViewWithCustomer:dict];
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _detailCustomer.alpha = 1;
    } completion:^(BOOL finished) {
        selectedIndex = indexPath;
    }];
    
    
    
}

-(void) FeDetailViewShouldDismiss:(FeDetailCustomer *)sender
{
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _detailCustomer.alpha = 0;
    } completion:^(BOOL finished) {
        
        // Deselect Cell
        [_tableView deselectRowAtIndexPath:selectedIndex animated:YES];
        
        // Show search bar again
        if (isSearching)
        {
            [self searchBarTextDidBeginEditing:_searchBar];
        }
    }];

}
-(void) FeDetailViewDidStart:(FeDetailCustomer *)sender withCustomer:(NSDictionary *)dict
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:dict forKey:@"ActiveCustomer"];
    
    [self performSegueWithIdentifier:@"segueOption" sender:self];
}
@end
