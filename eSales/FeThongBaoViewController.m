//
//  FeThongBaoViewController.m
//  eSales
//
//  Created by Nghia Tran on 8/23/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeThongBaoViewController.h"
#import "FeDatabaseManager.h"
#import <QuartzCore/QuartzCore.h>
#import "FeShowNews.h"

@interface FeThongBaoViewController () <FeShowNewsDelegate>
{
    BOOL isTabBangTinSelected;
    BOOL isTabPhanHoiSelected;
}
@property (strong, nonatomic) NSMutableArray *arrBangTin;
@property (strong, nonatomic) FeShowNews *show;
-(void) setupDefaultView;
@end

@implementation FeThongBaoViewController
@synthesize tabBangTin = _tabBangTin, tableView = _tableView, tabPhanHoi = _tabPhanHoi;
@synthesize arrBangTin = _arrBangTin, show = _show, dictNoticeBoardSubmit=_dictNoticeBoardSubmit, isPhanHoi=_isPhanHoi;
@synthesize viewBangTin = _viewBangTin, viewPhanHoi = _viewPhanHoi;

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
    
    if(self.isPhanHoi == YES)
    {
        
        NSUserDefaults *phanHoi = [NSUserDefaults standardUserDefaults];
        [phanHoi setObject:[self.dictNoticeBoardSubmit valueForKey:@"Code"] forKey:@"Code_PH"];
        [phanHoi setObject:[self.dictNoticeBoardSubmit valueForKey:@"RequestHeader"] forKey:@"RequestHeader"];
        [phanHoi setObject:[self.dictNoticeBoardSubmit valueForKey:@"RequestContent"] forKey:@"RequestContent"];
        
        [phanHoi setObject:[self.dictNoticeBoardSubmit valueForKey:@"ImageFileName1"] forKey:@"NoticeImageFileName1"];
        [phanHoi setObject:[self.dictNoticeBoardSubmit valueForKey:@"ImageFileName2"] forKey:@"NoticeImageFileName2"];
        [phanHoi setObject:[self.dictNoticeBoardSubmit valueForKey:@"ImageFileName3"] forKey:@"NoticeImageFileName3"];
        
        [phanHoi setObject:[self.dictNoticeBoardSubmit valueForKey:@"NoteID1"] forKey:@"NoticeNoteID1"];
        [phanHoi setObject:[self.dictNoticeBoardSubmit valueForKey:@"NoteID2"] forKey:@"NoticeNoteID2"];
        [phanHoi setObject:[self.dictNoticeBoardSubmit valueForKey:@"NoteID3"] forKey:@"NoticeNoteID3"];
        
        [phanHoi synchronize];
         
        [self phanHoiTapped];
    }
}
-(void) setupDefaultView
{
    // set selected BangTin
    
    [_tabBangTin setStyle:UIBarButtonItemStyleDone];
    isTabBangTinSelected = YES;
    isTabPhanHoiSelected = NO;
    
    // Get data database
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    _arrBangTin = [db arrBangTinFromDatabase];
    
    // border table View
    _tableView.layer.borderWidth = 1;
    _tableView.layer.borderColor = [UIColor blackColor].CGColor;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger ) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger ) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrBangTin.count;
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idCell = @"cellBangTin";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:idCell];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idCell];
    
    UILabel *ID = (UILabel *) [cell viewWithTag:100];
    UILabel *descr = (UILabel *) [cell viewWithTag:101];
    UILabel *content = (UILabel *) [cell viewWithTag:102];
    
    ID.layer.borderColor = [UIColor blackColor].CGColor;
    ID.layer.borderWidth = 1;
    descr.layer.borderColor = [UIColor blackColor].CGColor;
    descr.layer.borderWidth = 1;
    content.layer.borderColor = [UIColor blackColor].CGColor;
    content.layer.borderWidth = 1;
    
    // set content
    NSDictionary *dict = [_arrBangTin objectAtIndex:indexPath.row];
    ID.text = [dict valueForKey:@"KnowledgeID"];
    descr.text = [dict valueForKey:@"Descr"];
    content.text = [dict valueForKey:@"Content"];
    
    return cell;
}
/*
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [_arrBangTin objectAtIndex:indexPath.row];
    NSString *content = [dict valueForKey:@"Content"];
    
    CGRect currentFrame = CGRectMake(383, 0, 345, 88);
    CGSize max = CGSizeMake(currentFrame.size.width, 1000);
    CGSize expert = [content sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:max];
    
    return expert.height + 20;
}
 */
- (IBAction)bangTinTapped:(id)sender
{
    if (isTabBangTinSelected)
        return;
    else
    {
        [_viewPhanHoi hideKeyboard];
        _viewBangTin.hidden = NO;
        _viewPhanHoi.hidden = YES;
        
        isTabBangTinSelected = YES;
        isTabPhanHoiSelected = NO;
        
        [_tabBangTin setStyle:UIBarButtonItemStyleDone];
        [_tabPhanHoi setStyle:UIBarButtonItemStyleBordered];
    }
}

- (IBAction)phanHoiTapped:(id)sender
{
    // Them moi phan hoi
    NSUserDefaults *phanHoi = [NSUserDefaults standardUserDefaults];
    [phanHoi setObject:@"" forKey:@"Code_PH"];
    [phanHoi setObject:@"" forKey:@"RequestHeader"];
    [phanHoi setObject:@"" forKey:@"RequestContent"];
    [phanHoi setObject:@"" forKey:@"NoticeImageFileName1"];
    [phanHoi setObject:@"" forKey:@"NoticeImageFileName2"];
    [phanHoi setObject:@"" forKey:@"NoticeImageFileName3"];
    [phanHoi setObject:@"" forKey:@"NoticeNoteID1"];
    [phanHoi setObject:@"" forKey:@"NoticeNoteID2"];
    [phanHoi setObject:@"" forKey:@"NoticeNoteID3"];
    [phanHoi synchronize];
    
    [self phanHoiTapped];

}
-(void)phanHoiTapped
{
    
    if (isTabPhanHoiSelected)
        return;
    else
    {
        if (!_viewPhanHoi)
        {

            NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"PhanHoi" owner:self options:nil];
            _viewPhanHoi = [arr lastObject];
            _viewPhanHoi.delegate =self;
            _viewPhanHoi.frame = CGRectMake(20, 71, _viewPhanHoi.frame.size.width, _viewPhanHoi.frame.size.height);
            _viewPhanHoi.delegate = self;
            [_viewPhanHoi isPhanHoi:_isPhanHoi];
            
            // add subview
            UIScrollView *scrollView = (UIScrollView *)[self.view viewWithTag:999];
            [scrollView addSubview:_viewPhanHoi];
            
            
        }
        _viewPhanHoi.hidden = NO;
        _viewBangTin.hidden = YES;
        
        isTabBangTinSelected = NO;
        isTabPhanHoiSelected = YES;
        
        [_tabBangTin setStyle:UIBarButtonItemStyleBordered];
        [_tabPhanHoi setStyle:UIBarButtonItemStyleDone];
    }
}

-(void) FePhanHoiCloseViewController:(FePhanHoi *)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [_arrBangTin objectAtIndex:indexPath.row];
    NSLog(@"tapped Ditct= %@",dict);
    
    if (!_show)
    {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"FeShowNews" owner:self options:nil];
        _show = [arr lastObject];
        _show.delegate = self;
        
        _show.frame = CGRectMake(0, 0, 768, 1004);
    }
    _show.lblNoiDung.text = [dict objectForKey:@"Content"];
    _show.lblTieuDe.text = [dict objectForKey:@"Descr"];
    
    // Load Image
    [_show loadImageForID:[dict objectForKey:@"Code"]];
    
    [self.view addSubview:_show];
    
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(void) FeShowNewShouldClose:(id)sender
{
    [_show removeFromSuperview];
    
}
@end
