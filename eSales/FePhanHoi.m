//
//  FePhanHoi.m
//  eSales
//
//  Created by Nghia Tran on 8/23/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FePhanHoi.h"
#import "ActionSheetPicker.h"
#import "FeUtility.h"
#import "FeDatabaseManager.h"
#import <QuartzCore/QuartzCore.h>
@interface FePhanHoi() <UIPopoverControllerDelegate, UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSInteger maAnhChup;
}
-(void) setupDefaultView;
@property (strong, nonatomic) NSArray *arrMaAnhChup;
@property (strong, nonatomic) UIPopoverController *popover;
@end
@implementation FePhanHoi
@synthesize txbMaAnh = _txbMaAnh, txbNoiDung = _txbNoiDung, txbTieuDe = _txbTieuDe, pic1 = _pic1, pic2 = _pic2, pic3 = _pic3, curCode=_curCode;
@synthesize arrMaAnhChup = _arrMaAnhChup;
@synthesize popover = _popover;

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
    _arrMaAnhChup = [NSArray arrayWithObjects:@"Ảnh 1",@"Ảnh 2",@"Ảnh 3", nil];
    maAnhChup = 0;
    _txbMaAnh.text = [_arrMaAnhChup objectAtIndex:maAnhChup];
    
    _txbNoiDung.layer.borderColor = [UIColor blackColor].CGColor;
    _txbNoiDung.layer.borderWidth = 1;
    
    // update phan hoi
    NSUserDefaults *phanhoi = [NSUserDefaults standardUserDefaults];
    //_curCode = [phanhoi objectForKey:@"Code_PH"];
    
    _txbTieuDe.text =[phanhoi objectForKey:@"RequestHeader"];
    _txbNoiDung.text = [phanhoi objectForKey:@"RequestContent"];
    
    // get direc document
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [array objectAtIndex:0];
    
    //pic 1
    NSString *thePath1 = [NSString stringWithFormat:@"%@/%@.jpg",  documentPath, [phanhoi objectForKey:@"NoticeImageFileName1"]];
    
    UIImage *img1 = [[UIImage alloc] initWithContentsOfFile:thePath1];
    _pic1.image = img1;
    if([[phanhoi objectForKey:@"NoticeImageFileName1"] length] == 0)
        _pic1.image = [UIImage imageNamed:@"default_profile"];
    
    
    //pic 2
    NSString *thePath2 = [NSString stringWithFormat:@"%@/%@.jpg",  documentPath, [phanhoi objectForKey:@"NoticeImageFileName2"]];
    
    UIImage *img2 = [[UIImage alloc] initWithContentsOfFile:thePath2];
    _pic2.image = img2;
    if([[phanhoi objectForKey:@"NoticeImageFileName2"] length] == 0)
        _pic2.image = [UIImage imageNamed:@"default_profile"];
    
    
    //pic 3
    NSString *thePath3 = [NSString stringWithFormat:@"%@/%@.jpg",  documentPath, [phanhoi objectForKey:@"NoticeImageFileName3"]];
    
    UIImage *img3 = [[UIImage alloc] initWithContentsOfFile:thePath3];
    _pic3.image = img3;
    if([[phanhoi objectForKey:@"NoticeImageFileName3"] length] == 0)
        _pic3.image = [UIImage imageNamed:@"default_profile"];
}

- (IBAction)taoMoiTapped:(id)sender
{
    _txbTieuDe.text = @"";
    _txbNoiDung.text = @"";
    maAnhChup = 0;
    _isPhanHoi = NO;
    _txbMaAnh.text = [_arrMaAnhChup objectAtIndex:maAnhChup];
    
    _pic1.image = [UIImage imageNamed:@"default_profile"];
    _pic1.tag = 0;
    _pic2.image = [UIImage imageNamed:@"default_profile"];
    _pic2.tag = 0;
    _pic3.image = [UIImage imageNamed:@"default_profile"];
    _pic3.tag = 0;
    
    [_txbTieuDe becomeFirstResponder];
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
        if (maAnhChup == 0)
        {
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            [popover presentPopoverFromRect:_pic1.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
            _popover = popover;
            _popover.delegate = self;
        }
        if (maAnhChup == 1)
        {
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            [popover presentPopoverFromRect:_pic2.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
            _popover = popover;
            _popover.delegate = self;
        }
        if (maAnhChup == 2)
        {
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            [popover presentPopoverFromRect:_pic3.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
            _popover = popover;
            _popover.delegate = self;
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
    if (maAnhChup == 0)
    {
        _pic1.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        _pic1.tag = 1;
        [_popover dismissPopoverAnimated:YES];
    }
    if (maAnhChup == 1)
    {
        _pic2.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        _pic2.tag = 1;
        [_popover dismissPopoverAnimated:YES];
    }
    if (maAnhChup == 2)
    {
        _pic3.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        _pic3.tag = 1;
        [_popover dismissPopoverAnimated:YES];
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
        
        
        //NSDictionary *dict = [_arrLoaiYC objectAtIndex:indexLoaiYC];
        NSString *RequestType = @"";
        NSString *RequestHeader = _txbTieuDe.text;
        NSString *RequestContent = _txbNoiDung.text;
        NSString *RequestDate = [format stringFromDate:[NSDate date]];        
        NSString *Status = @"";
        
        
        // Save tp US
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        
        [user setObject:RequestType forKey:@"PH_RequestType"];
        [user setObject:RequestHeader forKey:@"PH_RequestHeader"];
        [user setObject:RequestContent forKey:@"PH_RequestContent"];
        [user setObject:RequestDate forKey:@"PH_RequestDate"];
        [user setObject:Status forKey:@"PH_Status"];
            //Update NoticBoard
        [user setObject:Status forKey:@"PH_Status"];
        
        // Photo
        //if (_pic1.tag == 1)
            [user setObject:UIImageJPEGRepresentation(_pic1.image, 0.7f) forKey:@"PH_Pic1"];
        //if (_pic2.tag == 1)
            [user setObject:UIImageJPEGRepresentation(_pic2.image, 0.7f) forKey:@"PH_Pic2"];
        //if (_pic3.tag == 1)
            [user setObject:UIImageJPEGRepresentation(_pic3.image, 0.7f) forKey:@"PH_Pic3"];
        
        
        if(_isPhanHoi == YES) // update
        {
            NSUserDefaults *userPhanHoi = [NSUserDefaults standardUserDefaults];
            
           NSString *curCode = [userPhanHoi objectForKey:@"Code_PH"];
            NSString *NoteID1 = [userPhanHoi objectForKey:@"NoticeNoteID1"];
            NSString *NoteID2 = [userPhanHoi objectForKey:@"NoticeNoteID2"];
            NSString *NoteID3 = [userPhanHoi objectForKey:@"NoticeNoteID3"];
            
            NSString *ImageFileName1 = [userPhanHoi objectForKey:@"NoticeImageFileName1"];
            NSString *ImageFileName2 = [userPhanHoi objectForKey:@"NoticeImageFileName2"];
            NSString *ImageFileName3 = [userPhanHoi objectForKey:@"NoticeImageFileName3"];
            
            
            [user setObject:curCode forKey:@"PH_Code"];            
            [user setObject:NoteID1 forKey:@"PH_NoticeNoteID1"];
            [user setObject:NoteID2 forKey:@"PH_NoticeNoteID2"];
            [user setObject:NoteID3 forKey:@"PH_NoticeNoteID3"];
            [user setObject:ImageFileName1 forKey:@"PH_NoticeImageFileName1"];
            [user setObject:ImageFileName2 forKey:@"PH_NoticeImageFileName2"];
            [user setObject:ImageFileName3 forKey:@"PH_NoticeImageFileName3"];
            
            [user synchronize];
            
            [db updatePhanHoiUsingNSUserDefaultWithCompletionHandler:^(BOOL success)
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Lưu Phản hồi Thành công" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                 [alert show];
                 
                 _pic1.tag = 0;
                 _pic2.tag = 0;
                 _pic3.tag = 0;
             }];
        }else // add new
        {
            NSString *Code = [db lastIDForTable:@"PPC_NoticeBoardSubmit" columnName:@"Code"];
            [user setObject:Code forKey:@"PH_Code"];
            
            [user synchronize];
            
            [db savePhanHoiUsingNSUserDefaultWithCompletionHandler:^(BOOL success)
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Lưu Phản hồi Thành công" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                 [alert show];
                 
                 _pic1.tag = 0;
                 _pic2.tag = 0;
                 _pic3.tag = 0;
             }];
        }
        
    }

}
- (IBAction)dongTapped:(id)sender
{
    [_delegate FePhanHoiCloseViewController:self];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txbTieuDe)
        [_txbNoiDung becomeFirstResponder];
    
    return YES;
}
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _txbMaAnh)
    {
        [ActionSheetStringPicker showPickerWithTitle:@"Mã ảnh chụp" rows:_arrMaAnhChup initialSelection:maAnhChup doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            _txbMaAnh.text = (NSString *) selectedValue;
            maAnhChup = selectedIndex;
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
    [self hideKeyboard];
}
- (void)isPhanHoi:(BOOL)phanhoi
{
    _isPhanHoi = phanhoi;
}

@end
