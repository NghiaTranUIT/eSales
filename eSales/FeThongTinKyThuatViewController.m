//
//  FeThongTinKyThuatViewController.m
//  eSales
//
//  Created by Nghia Tran on 8/23/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeThongTinKyThuatViewController.h"
#import "FeDatabaseManager.h"
#import "ActionSheetPicker.h"
#import <QuartzCore/QuartzCore.h>
#import "FeShowTechnical.h"

@interface FeThongTinKyThuatViewController () <FeShowTechnicalDelegate>
{
    NSInteger isLoaiYCSelected;
}
@property (strong, nonatomic) NSMutableArray *arrLoaiYC;
@property (strong, nonatomic) NSMutableArray *arrThongTinKyThuat;
@property (strong, nonatomic) FeShowTechnical *show;
-(void) setupDefaultView;

@end

@implementation FeThongTinKyThuatViewController
@synthesize txbLoaiYC = _txbLoaiYC, tableView = _tableView;
@synthesize arrLoaiYC = _arrLoaiYC, arrThongTinKyThuat = _arrThongTinKyThuat,show = _show;

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
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    _arrLoaiYC = [db arrLoaiYCFromDatabase];
    isLoaiYCSelected = 0;
    NSDictionary *dic = [_arrLoaiYC objectAtIndex:isLoaiYCSelected];
    _txbLoaiYC.text = [dic valueForKey:@"Descr"];
    
    // thong tinky thuat on tableView
    NSDictionary *dict = [_arrLoaiYC objectAtIndex:isLoaiYCSelected];
    _arrThongTinKyThuat = [db arrThongTinKyThuatWithIDLoaiYC:[dict valueForKey:@"Code"]];
    NSLog(@"arrThongTinKyThuat = %@",_arrThongTinKyThuat);
    
    // border
    _tableView.layer.borderColor = [UIColor blackColor].CGColor;
    _tableView.layer.borderWidth = 1;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _txbLoaiYC)
    {
        NSMutableArray *loaiYC = [[NSMutableArray alloc] initWithCapacity:_arrLoaiYC.count];
        for (NSDictionary *dict in _arrLoaiYC)
        {
            [loaiYC addObject:[dict valueForKey:@"Descr"]];
        }
        
        [ActionSheetStringPicker showPickerWithTitle:@"Loại Yêu Cầu" rows:loaiYC initialSelection:isLoaiYCSelected doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            _txbLoaiYC.text = (NSString *) selectedValue;
            isLoaiYCSelected = selectedIndex;
            
            FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
            NSDictionary *dict = [_arrLoaiYC objectAtIndex:isLoaiYCSelected];
            _arrThongTinKyThuat = [db arrThongTinKyThuatWithIDLoaiYC:[dict valueForKey:@"Code"]];
            [_tableView reloadData];
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:_txbLoaiYC];
        
        return NO;
    }
    return YES;
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrThongTinKyThuat.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idCell = @"cellThongTinHoTroKyThuat";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:idCell];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idCell];
    
    UILabel *ID = (UILabel *) [cell viewWithTag:100];
    UILabel *descr = (UILabel *) [cell viewWithTag:101];
    
    ID.layer.borderColor = [UIColor blackColor].CGColor;
    ID.layer.borderWidth = 1;
    descr.layer.borderColor = [UIColor blackColor].CGColor;
    descr.layer.borderWidth = 1;
    
    // set content
    NSDictionary *dict = [_arrThongTinKyThuat objectAtIndex:indexPath.row];
    NSLog(@"Technical Dict = %@",dict);
    ID.text = [dict valueForKey:@"Code"];
    descr.text = [dict valueForKey:@"IssueHeader"];
    
    return cell;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [_arrThongTinKyThuat objectAtIndex:indexPath.row];
    
    
    if (!_show)
    {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"FeShowTechnical" owner:self options:nil];
        _show = [arr lastObject];
        _show.delegate = self;
            
        _show.frame = CGRectMake(0, 0, 768, 1004);
    }
    _show.lblNoiDung.text = [dict objectForKey:@"IssueContent"];
    _show.lblSTT.text = [dict objectForKey:@"Code"];
    
    
    // load image
    [_show loadImageForDict:[_arrThongTinKyThuat objectAtIndex:indexPath.row]];
    
    [self.view addSubview:_show];
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
-(void) FeShowTechnicalDelegateShouldClose:(id)sender
{
    [_show removeFromSuperview];
}
@end
