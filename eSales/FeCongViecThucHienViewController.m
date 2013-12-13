//
//  FeCongViecThucHienViewController.m
//  eSales
//
//  Created by MAC on 10/2/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeCongViecThucHienViewController.h"
#import "FeDatabaseManager.h"
#import "FeCongViecThucHienCell.h"
#import <QuartzCore/QuartzCore.h>
#import "FeGhiNhanSanPhamViewController.h"

@interface FeCongViecThucHienViewController ()<UIPopoverControllerDelegate>
{
    NSInteger indexRow;
    NSString *custID;
}
@property (strong, nonatomic) NSMutableArray *arrTask;
@property (strong, nonatomic) NSMutableArray *arrTaskDone;
@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) UIImage *imageTask;
@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) UIButton *btnIndex;
@end

@implementation FeCongViecThucHienViewController
@synthesize tableView=_tableView, arrTask=_arrTask,arrTaskDone=_arrTaskDone, popover=_popover, imageTask=_imageTask, imageName=_imageName, btnIndex=_btnIndex, feThongTinDoiThu=_feThongTinDoiThu;

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
    
    // delegate table view
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 44;
    
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

    //UINib *nib = [UINib nibWithNibName:@"FeCongViecThucHienCell" bundle:[NSBundle mainBundle]];
    //[_tableView registerNib:nib forCellReuseIdentifier:@"FeCongViecThucHienCell"];
    
    //Get CustID
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSDictionary *activeCust = [user objectForKey:@"ActiveCustomer"];
    custID = [activeCust objectForKey:@"CustID"];
    
    // DB
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    _arrTask = [db arrOM_DefineWorksFromDatabase];
    _arrTaskDone = [[NSMutableArray alloc] init];
    
    
    
    for(int i = 0; i< _arrTask.count; i++)
    {
        NSMutableDictionary *dictTask= [_arrTask objectAtIndex:i];
        NSMutableDictionary *dict= [[NSMutableDictionary alloc] init];
        [dict setObject:[dictTask objectForKey:@"TaskID"] forKey:@"TaskID"];
        [dict setObject:[dictTask objectForKey:@"Name"]  forKey:@"Name"];
        [dict setObject:[dictTask objectForKey:@"Required"]  forKey:@"Required"];
        [dict setObject:[dictTask objectForKey:@"Shooting"]  forKey:@"Shooting"];
        
        [dict setObject:@"" forKey:@"ImageName"];
        [dict setObject:@"" forKey:@"Note"];
        [dict setObject:@"" forKey:@"CustID"];
        
        [_arrTaskDone addObject:dict];
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_arrTask count];
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *IDCell = @"CongViecThucHienCell";
    
    //FeCongViecThucHienCell *cell = [_tableView dequeueReusableCellWithIdentifier:IDCell forIndexPath:indexPath];
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:IDCell forIndexPath:indexPath];
    
    //DB
    NSMutableDictionary *dictTask= [_arrTask objectAtIndex:indexPath.row];
    NSString *taskID = [dictTask objectForKey:@"TaskID"];
    
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    BOOL isTaskExist = [db checkTaskExistInDatabaseWithCustID:custID AndTaskID:taskID];
    NSMutableDictionary *dictTaskExist = [db arrTaskExistInDatabaseWithCustID:custID AndTaskID:taskID];
    
    // add control
    UILabel *lblCheckbox = (UILabel *) [cell viewWithTag:1000];
    UILabel *lblName = (UILabel *) [cell viewWithTag:1002];
    UITextField *txfNote = (UITextField *) [cell viewWithTag:1004];
    UIImageView *imgCheckbox = (UIImageView *) [cell viewWithTag:1001];
    UIButton *btnShooting = (UIButton *) [cell viewWithTag:1003];
    [btnShooting addTarget:self action:@selector(takeImage:) forControlEvents:UIControlEventTouchUpInside];
    
    // Border
    txfNote.layer.borderColor = [UIColor blackColor].CGColor;
    txfNote.layer.borderWidth = 1;
    btnShooting.layer.borderColor = [UIColor blackColor].CGColor;
    btnShooting.layer.borderWidth = 1;
    lblName.layer.borderColor = [UIColor blackColor].CGColor;
    lblName.layer.borderWidth = 1;
    lblCheckbox.layer.borderColor = [UIColor blackColor].CGColor;
    lblCheckbox.layer.borderWidth = 1;
    //
    if(isTaskExist)
    {
        imgCheckbox.image = [UIImage imageNamed:@"cb_green_on.png"];
        if(![[dictTaskExist objectForKey:@"ImageName"] isEqualToString:@""])
            [btnShooting setBackgroundImage:[UIImage imageNamed:@"imageTask.jpeg"] forState:UIControlStateNormal];
        else
            [btnShooting setBackgroundImage:[UIImage imageNamed:@"Camera.png"] forState:UIControlStateNormal];
        
        NSMutableDictionary *dict = [_arrTaskDone objectAtIndex:indexPath.row];
        [dict setObject:[dictTaskExist objectForKey:@"Note"] forKey:@"Note"];
        [dict setObject:[dictTaskExist objectForKey:@"ImageName"] forKey:@"ImageName"];
    } 
    else
    {
        imgCheckbox.image = [UIImage imageNamed:@"cb_green_off.png"];
        [btnShooting setBackgroundImage:[UIImage imageNamed:@"Camera.png"] forState:UIControlStateNormal];
    }
        
    
    
    
    NSMutableDictionary *dict = [_arrTask objectAtIndex:indexPath.row];
    lblName.text = [dict objectForKey:@"Name"];
    txfNote.text = [dictTaskExist objectForKey:@"Note"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

-(IBAction)btnSaveTapped:(id)sender
{
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    BOOL isTaskOK = YES;
    
    for(int i = 0; i< _arrTaskDone.count; i++)
    {
        NSMutableDictionary *dictTask= [_arrTaskDone objectAtIndex:i];
        
        NSString *name = [dictTask objectForKey:@"Name"];
        int required = [[dictTask objectForKey:@"Required"] intValue];
        int shooting = [[dictTask objectForKey:@"Shooting"] intValue];
        NSString *imageName= [dictTask objectForKey:@"ImageName"];
        NSString *note = [dictTask objectForKey:@"Note"];
        //NSString *taskID= [dictTask objectForKey:@"TaskID"];
        //NSString *custID = [dictTask objectForKey:@"CustID"];
        
        if(![imageName isEqualToString:@""] || ![note isEqualToString:@""])
        {
            if(required ==1 )
            {
                if([imageName isEqualToString:@""] && [note isEqualToString:@""])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:[NSString stringWithFormat:@"Tên Công Việc: %@ Yêu Cầu Phải Có Ghi Chú Hoặc Chụp Hình", name] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    isTaskOK = NO;
                }
            }
            if(shooting == 1)
            {
                if([imageName isEqualToString:@""])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:[NSString stringWithFormat:@"Tên Công Việc: %@ Yêu Cầu Phải Chụp Hình", name] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    isTaskOK = NO;
                }
            }
        }

    }
    
    if(isTaskOK)
    {
        BOOL isSaveOK = NO;
        
        for(int i = 0; i< _arrTaskDone.count; i++)
        {
            NSMutableDictionary *dictTask= [_arrTaskDone objectAtIndex:i];

            NSString *imageName= [dictTask objectForKey:@"ImageName"];
            NSString *note = [dictTask objectForKey:@"Note"];
            NSString *taskID= [dictTask objectForKey:@"TaskID"];
            
            if(![imageName isEqualToString:@""] || ![note isEqualToString:@""])
            {
                BOOL isTaskExist =[db checkTaskExistInDatabaseWithCustID:custID AndTaskID:taskID];
                
                if(isTaskExist)
                {
                    [db updateTaskWithDict:dictTask WithCompletionHandler:^(BOOL success) {
                        
                    }];
                    isSaveOK = YES;
                }else
                {
                    [db saveTaskDictionary:dictTask WithCompletionHandler:^(BOOL success) {
                        
                    }];
                    isSaveOK = YES;
                }
            }
        }
        
        if(isSaveOK)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:[NSString stringWithFormat:@"Lưu Thành Công"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            [alert show];
            
            _arrTask = [db arrOM_DefineWorksFromDatabase];
            [_tableView reloadData];
        }else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:[NSString stringWithFormat:@"Lưu Không Thành Công. Vui Lòng Nhập Nội Dung Công Việc."] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            [alert show];
        }
    }
}
-(void)takeImage:(UIButton*)sender
{
    _btnIndex = sender;
    UIView *contentView = [sender superview];
    UITableViewCell *cell = (UITableViewCell *)[contentView superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    indexRow= indexPath.row;
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    else
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    imagePicker.allowsEditing = NO;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [popover presentPopoverFromRect:CGRectMake(336, 695, 94, 44) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        _popover = popover;
        _popover.delegate = self;
 
    }
}
-(void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    
}
-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_popover dismissPopoverAnimated:YES];
}
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    NSString *index = [db lastIDForTable:@"PPC_Task" columnName:@"rowid"];
    
    NSMutableDictionary *dict = [_arrTaskDone objectAtIndex:indexRow];
    NSMutableDictionary *dictTaskExist = [db arrTaskExistInDatabaseWithCustID:custID AndTaskID:[dict objectForKey:@"TaskID"]];
    
    if(dictTaskExist && [dictTaskExist objectForKey:@"ImageName"])
        _imageName = [dictTaskExist objectForKey:@"ImageName"];
    else
        _imageName = [NSString stringWithFormat:@"imageTask%d_%@", indexRow, index];
    
    _imageTask = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    
    [dict setObject:UIImageJPEGRepresentation(_imageTask, 0.7f) forKey:@"HT_Pic"];
    [dict setObject:_imageName forKey:@"ImageName"];
    [dict setObject:custID forKey:@"CustID"];
    
    
    UIView *contentView = [_btnIndex superview];
    UITableViewCell *cell =(UITableViewCell *) [contentView superview];
    UIButton *btnShooting = (UIButton*) [cell viewWithTag:1003];
    [btnShooting setBackgroundImage:[UIImage imageNamed:@"imageTask.jpeg"] forState:UIControlStateNormal];
    
    [_popover dismissPopoverAnimated:YES];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    UIView *contentView = [textField superview];
    UITableViewCell *cell = (UITableViewCell *)[contentView superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
    UITextField *txfNote = (UITextField *) [cell viewWithTag:1004];
    NSString *note = txfNote.text;
    //NSLog(@"Note: %@", txfNote.text);
    NSMutableDictionary *dict = [_arrTaskDone objectAtIndex:indexPath.row];
    [dict setObject:note forKey:@"Note"];
    [dict setObject:custID forKey:@"CustID"];
    
    return YES;
}
-(IBAction)pushSegue:(id)sender
{
    [self performSegueWithIdentifier:@"segueGhiNhanSanPham" sender:self];
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *idSegue = segue.identifier;
    
     if ([idSegue isEqualToString:@"segueGhiNhanSanPham"])
     {
     // Save to NSUser
     
     FeGhiNhanSanPhamViewController *ghiNhanSP = segue.destinationViewController;
     ghiNhanSP.feThongTinDoiThu = _feThongTinDoiThu;
     }
     
}
@end
