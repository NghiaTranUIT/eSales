//
//  FeTTPhanHoi.m
//  eSales
//
//  Created by MAC on 9/19/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeTTPhanHoi.h"
#import "FeDatabaseManager.h"
#import "FeTTPhanHoiCell.h"

@interface FeTTPhanHoi()

-(void) setupDefaultView;

@end

@implementation FeTTPhanHoi
@synthesize tableView=_tableView, arrTTPhanHoi=_arrTTPhanHoi, isType=_isType, indexSelected=_indexSelected, code=_code;
@synthesize delegate = _delegate;

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
    _isType = -1; // chua chon loai phan hoi
    _indexSelected = -1; // chua chon phan hoi can xoa
    
    // register View
    UINib *nib = [UINib nibWithNibName:@"TTPhanHoiCell" bundle:[NSBundle mainBundle]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"TTPhanHoiCell"];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 41;
    
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    _arrTTPhanHoi = [[ NSMutableArray alloc] init];
    _arrTTPhanHoi = [ db arrTTPhanHoiFromDatabase];
    
    
}

- (void)reloadData
{
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    _arrTTPhanHoi = [[ NSMutableArray alloc] init];
    _arrTTPhanHoi = [ db arrTTPhanHoiFromDatabase];
    
    [_tableView reloadData];
}
- (IBAction)btnXoaTapped
{
    if(_indexSelected < 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"Vui Lòng Chọn Thông Tin Phản Hồi Cần Xoá." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"Bạn Có Muốn Xoá Thông Tin Phản Hồi Này Không?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert setTag:1000];
        [alert show];
    } 

    
    
}
- (IBAction)btnDieuChinhTapped
{
    if(_isType == 0)
        [_delegate FeTTPhanHoiTypeTShouldPerformSegue:self];
    else
        [_delegate FeTTPhanHoiTypeYShouldPerformSegue:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000)
    {
        if (buttonIndex == 0)
        {
            // Cancel Tapped
        }
        else if (buttonIndex == 1)
        {
            // DELETE Tapped
            [self xoaPhanHoi];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"Xoá Thông Tin Phản Hồi Thành Công." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            [alert show];
        }
    }
}

-(void)xoaPhanHoi
{
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    
    if(_isType == 0)//Technical support
    {
        [db deletePPC_TechnicalSupportWithCode:self.code];
        [db deletePPC_OM_TechnicalSupport_ImageWithCode:self.code];
        [_arrTTPhanHoi removeObjectAtIndex:_indexSelected];
        [_tableView reloadData];
    }
    else // Noticeboard
    {
        [db deletePPC_NoticeBoardSubmitWithCode:self.code];
        [db deletePPC_NoticeBoardSubmitImageWithCode:self.code];
        [_arrTTPhanHoi removeObjectAtIndex:_indexSelected];
        [_tableView reloadData];
    }
}

-(NSInteger ) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Count = %d",_arrTTPhanHoi.count);
    return [ _arrTTPhanHoi count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idCell = @"TTPhanHoiCell";
    
    FeTTPhanHoiCell *cell =[_tableView dequeueReusableCellWithIdentifier:idCell forIndexPath:indexPath];
    
    if([_arrTTPhanHoi count] != 0)
    {
        NSDictionary *dictDSDH = [_arrTTPhanHoi objectAtIndex:indexPath.row];
        
        cell.txbSTT.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];
        cell.txbMoTa.text =[dictDSDH objectForKey:@"Description"];
        
        if([[dictDSDH objectForKey:@"Type"] isEqualToString:@"T"])
            cell.txbLoai.text = @"Thông Tin";
        else
            cell.txbLoai.text = @"Yêu Cầu";
    }else
    {
        cell.txbSTT.text = @"";
        cell.txbLoai.text = @"";
        cell.txbMoTa.text =@"";
    }
    
    return cell;
    
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictDSDH = [_arrTTPhanHoi objectAtIndex:indexPath.row];
    _code = [dictDSDH objectForKey:@"Code"];
    _indexSelected = indexPath.row;
    
    if([[dictDSDH objectForKey:@"Type"] isEqualToString:@"T"])
    {        
        _isType = 0; //Technical support
    }
    else
    {
        _isType = 1; // Noticeboard
    }
}

@end
