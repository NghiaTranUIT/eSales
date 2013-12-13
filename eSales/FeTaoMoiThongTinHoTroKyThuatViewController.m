//
//  FeTaoMoiThongTinHoTroKyThuatViewController.m
//  eSales
//
//  Created by Nghia Tran on 8/23/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeTaoMoiThongTinHoTroKyThuatViewController.h"
#import "FeDatabaseManager.h"
#import "ActionSheetPicker.h"
#import "FeUtility.h"
#import <QuartzCore/QuartzCore.h>

@interface FeTaoMoiThongTinHoTroKyThuatViewController () <UIAlertViewDelegate,UIPopoverControllerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSInteger indexLoaiYC;
    NSInteger indexMaAnd;
}
-(void) setupDafaultView;
-(void) hideKeyboard;
@property (strong, nonatomic) NSMutableArray *arrLoaiYC;
@property (strong, nonatomic) NSArray *arrMaAnh;
@property (strong, nonatomic) UIPopoverController *popover;
@end

@implementation FeTaoMoiThongTinHoTroKyThuatViewController
@synthesize txbLoaiYC = _txbLoaiYC, txbMaAnh = _txbMaAnh, txbNoiDung = _txbNoiDung, txbTieuDe = _txbTieuDe, pic1 = _pic1, pic2 = _pic2, pic3 = _pic3, isUpdate=_isUpdate, curCode=_curCode;
@synthesize arrLoaiYC = _arrLoaiYC, arrMaAnh = _arrMaAnh, dictNewTechnicalSupport=_dictNewTechnicalSupport;
@synthesize popover = _popover;
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
    
    [self setupDafaultView];
    
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    bg.frame = self.view.frame;
    bg.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:bg atIndex:0];
}
-(void) setupDafaultView
{
    // get database
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    
    _arrLoaiYC = [db arrLoaiYCFromDatabase];
    _arrMaAnh = [NSArray arrayWithObjects:@"Ảnh 1",@"Ảnh 2",@"Ảnh 3", nil];
    
    
    _curCode = [_dictNewTechnicalSupport objectForKey:@"Code"];
    
    if(_curCode.length != 0)// update TT Yeu Cau
    {
        indexLoaiYC = [[_dictNewTechnicalSupport objectForKey:@"IssueType"] intValue] -1 ;
        NSDictionary *dict = [_arrLoaiYC objectAtIndex:indexLoaiYC];
        _txbLoaiYC.text = [dict valueForKey:@"Descr"];
        
        
        _txbTieuDe.text = [_dictNewTechnicalSupport objectForKey:@"IssueHeader"];
        
        _txbNoiDung.text = [_dictNewTechnicalSupport objectForKey:@"IssueContent"];
        
        indexMaAnd = 0;
        _txbMaAnh.text = [_arrMaAnh objectAtIndex:indexMaAnd];
    
        // get direc document
        NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [array objectAtIndex:0];
        
        //pic 1
        NSString *thePath1 = [NSString stringWithFormat:@"%@/%@.jpg",  documentPath, [_dictNewTechnicalSupport objectForKey:@"ImageFileName1"]];
        
        UIImage *img1 = [[UIImage alloc] initWithContentsOfFile:thePath1];
        _pic1.image = img1;
        
        //pic 2
        NSString *thePath2 = [NSString stringWithFormat:@"%@/%@.jpg",  documentPath, [_dictNewTechnicalSupport objectForKey:@"ImageFileName2"]];
        
        UIImage *img2 = [[UIImage alloc] initWithContentsOfFile:thePath2];
        _pic2.image = img2;
        
        //pic 3
        NSString *thePath3 = [NSString stringWithFormat:@"%@/%@.jpg",  documentPath, [_dictNewTechnicalSupport objectForKey:@"ImageFileName3"]];
        
        UIImage *img3 = [[UIImage alloc] initWithContentsOfFile:thePath3];
        _pic3.image = img3;
        
    }else// tao moi
    {
        _txbNoiDung.layer.borderColor = [UIColor blackColor].CGColor;
        _txbNoiDung.layer.borderWidth = 1;
        
        // Loai YC
        indexLoaiYC = 0;
        NSDictionary *dict = [_arrLoaiYC objectAtIndex:indexLoaiYC];
        _txbLoaiYC.text = [dict valueForKey:@"Descr"];
        
        // Ma anh
        indexMaAnd = 0;
        _txbMaAnh.text = [_arrMaAnh objectAtIndex:indexMaAnd];
        
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)taoMoiTapped:(id)sender
{
    _txbTieuDe.text = @"";
    _txbNoiDung.text = @"";
    
    _isUpdate = NO;
    indexLoaiYC = 0;
    indexMaAnd = 0;
    NSDictionary *dict = [_arrLoaiYC objectAtIndex:indexLoaiYC];
    _txbLoaiYC.text = [dict valueForKey:@"Descr"];
    
    _txbMaAnh.text = [_arrMaAnh objectAtIndex:indexMaAnd];
    _pic1.image = [UIImage imageNamed:@"default_profile"];
    _pic1.tag = 0;
    _pic2.image = [UIImage imageNamed:@"default_profile"];
    _pic2.tag = 0;
    _pic3.image = [UIImage imageNamed:@"default_profile"];
    _pic3.tag = 0;
}

- (IBAction)chupHinhTapped:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    else
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    imagePicker.allowsEditing = NO;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if (indexMaAnd == 0)
        {
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            [popover presentPopoverFromRect:_pic1.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
            _popover = popover;
            _popover.delegate = self;
        }
        if (indexMaAnd == 1)
        {
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            [popover presentPopoverFromRect:_pic2.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
            _popover = popover;
            _popover.delegate = self;
        }
        if (indexMaAnd == 2)
        {
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            [popover presentPopoverFromRect:_pic3.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
            _popover = popover;
            _popover.delegate = self;
        }
    }

}

- (IBAction)luuTapped:(id)sender
{
    [self hideKeyboard];
    
    if ([_txbNoiDung.text isEqual: @""] || [_txbTieuDe.text isEqual: @""])
    {
        UIAlertView *alert = [FeUtility alertViewWithErrorTitle:@"Lỗi" message:@"Không thể lưu khi Nội dung hoặc Tiêu đề rỗng"];
        [alert show];
    }
    else
    {
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
        
        //Save Technical Support
        NSDictionary *dict = [_arrLoaiYC objectAtIndex:indexLoaiYC];
        NSString *RequestType = [dict valueForKey:@"Code"];
        NSLog(@"dict  - %@",dict);
        NSLog(@"Issue Type = %@",RequestType);
        NSString *RequestHeader = _txbTieuDe.text;
        NSString *RequestContent = _txbNoiDung.text;
        NSString *RequestDate = [format stringFromDate:[NSDate date]];
        NSString *Status = @"";
        
        // Update TechnicalSupport_Image
        NSString *NoteID1 = [_dictNewTechnicalSupport objectForKey:@"NoteID1"];
        NSString *NoteID2 = [_dictNewTechnicalSupport objectForKey:@"NoteID2"];
        NSString *NoteID3 = [_dictNewTechnicalSupport objectForKey:@"NoteID3"];
        
        NSString *ImageFileName1 = [_dictNewTechnicalSupport objectForKey:@"ImageFileName1"];
        NSString *ImageFileName2 = [_dictNewTechnicalSupport objectForKey:@"ImageFileName2"];
        NSString *ImageFileName3 = [_dictNewTechnicalSupport objectForKey:@"ImageFileName3"];
        
        
        // Save tp US
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        
        [user setObject:RequestType forKey:@"HT_RequestType"];
        [user setObject:RequestHeader forKey:@"HT_RequestHeader"];
        [user setObject:RequestContent forKey:@"HT_RequestContent"];
        [user setObject:RequestDate forKey:@"HT_RequestDate"];
        [user setObject:Status forKey:@"HT_Status"];
            // Update TechnicalSupport_Image
        [user setObject:NoteID1 forKey:@"HT_NoteID1"];
        [user setObject:NoteID2 forKey:@"HT_NoteID2"];
        [user setObject:NoteID3 forKey:@"HT_NoteID3"];
        [user setObject:ImageFileName1 forKey:@"ImageFileName1"];
        [user setObject:ImageFileName2 forKey:@"ImageFileName2"];
        [user setObject:ImageFileName3 forKey:@"ImageFileName3"];
        
        // Photo
        //if (_pic1.tag == 1)
            [user setObject:UIImageJPEGRepresentation(_pic1.image, 0.7f) forKey:@"HT_Pic1"];
        //if (_pic2.tag == 1)
            [user setObject:UIImageJPEGRepresentation(_pic2.image, 0.7f) forKey:@"HT_Pic2"];
        //if (_pic3.tag == 1)
            [user setObject:UIImageJPEGRepresentation(_pic3.image, 0.7f) forKey:@"HT_Pic3"];
        

        if(_isUpdate == YES) // Update
        {
            // Code hien tai de update
            _curCode = [_dictNewTechnicalSupport objectForKey:@"Code"];
            
            [user setObject:_curCode forKey:@"HT_Code"];
            [user synchronize];
        
            //code update
            [db updateHoTroKyThuatUsingNSUserDefaultWithCompletionHandler:^(BOOL success)
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Lưu Phản hồi Thành công" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                 [alert show];
                 
                 _pic1.tag = 0;
                 _pic2.tag = 0;
                 _pic3.tag =0;
             }];
        }
        else // Them moi 
        {
            // Retrun Code +1 de them moi
            NSString *Code = [db lastIDForTable:@"PPC_TechnicalSupport" columnName:@"Code"]; 
            [user setObject:Code forKey:@"HT_Code"];
            [user synchronize];
            // Insert
        [db saveHoTroKyThuatUsingNSUserDefaultWithCompletionHandler:^(BOOL success)
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Lưu Phản hồi Thành công" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alert show];
                          
             _pic1.tag = 0;
             _pic2.tag = 0;
             _pic3.tag =0;
         }];
    }
    
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
    if (indexMaAnd == 0)
    {
        _pic1.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        _pic1.tag = 1;
        [_popover dismissPopoverAnimated:YES];
    }
    if (indexMaAnd == 1)
    {
        _pic2.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        _pic2.tag = 1;
        [_popover dismissPopoverAnimated:YES];
    }
    if (indexMaAnd == 2)
    {
        _pic3.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        _pic3.tag = 1;
        [_popover dismissPopoverAnimated:YES];
    }
}
- (IBAction)dongTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txbTieuDe)
        [_txbNoiDung becomeFirstResponder];
    
    return YES;
}
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _txbLoaiYC)
    {
        [self hideKeyboard];
        NSMutableArray *loaiYC = [[NSMutableArray alloc] initWithCapacity:_arrLoaiYC.count];
        
        for (NSDictionary *dict in _arrLoaiYC)
        {
            NSString *yc = [dict valueForKey:@"Descr"];
            [loaiYC addObject:yc];
        }
        
        [ActionSheetStringPicker showPickerWithTitle:@"Loại Yêu Cầu" rows:loaiYC initialSelection:indexLoaiYC doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            _txbLoaiYC.text = (NSString *) selectedValue;
            indexLoaiYC = selectedIndex;
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:_txbLoaiYC];
        return NO;

        
    }
    if (textField == _txbMaAnh)
    {
        [self hideKeyboard];
        
        [ActionSheetStringPicker showPickerWithTitle:@"Mã ảnh" rows:_arrMaAnh initialSelection:indexMaAnd doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            _txbMaAnh.text = (NSString *) selectedValue;
            indexMaAnd = selectedIndex;
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:_txbMaAnh];
        return NO;

    }
    return YES;
}
-(void) hideKeyboard
{
    [_txbTieuDe resignFirstResponder];
    [_txbNoiDung resignFirstResponder];
}
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

}
@end
