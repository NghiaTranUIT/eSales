//
//  FeNhanDienBenNgoaiViewController.m
//  eSales
//
//  Created by Nghia Tran on 9/10/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeNhanDienBenNgoaiViewController.h"
#import "ActionSheetPicker.h"

@interface FeNhanDienBenNgoaiViewController ()
{
    NSInteger indexGhiChu;
    
    NSInteger isHasPhoto;
}
@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) NSArray *arrGhiChu;

-(void) setupDefaultView;
-(void) hideKeyboard;
@end

@implementation FeNhanDienBenNgoaiViewController
@synthesize txbChiTietGhiChu = _txbChiTietGhiChu, txbGhiChu = _txbGhiChu, arrGhiChu = _arrGhiChu,scrollView = _scrollView;
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
    [self setupDefaultView];
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    bg.frame = self.view.frame;
    bg.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:bg atIndex:0];
}
-(void) setupDefaultView
{
    _arrGhiChu = [NSMutableArray arrayWithObjects:@"Nhận diện bên ngoài",@"Hoạt động của đối thủ cạnh tranh",@"Tình trạng bảng hiệu", nil];
    indexGhiChu = 0;
    _txbGhiChu.text = [_arrGhiChu objectAtIndex:indexGhiChu];
    
    isHasPhoto = 0;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnChupHinhTapped:(id)sender
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
            UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            [popover presentPopoverFromRect:_txbChiTietGhiChu.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
            _popover = popover;
            _popover.delegate = self;

        
    }
}
-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [_popover dismissPopoverAnimated:YES];
}
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
        _avatar.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
        isHasPhoto = 1;
    
        [_popover dismissPopoverAnimated:YES];
}
- (IBAction)btnLuuTapped:(id)sender {
    
    if(isHasPhoto)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"Lưu hình ảnh thành công." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"Lưu hình ảnh không thành công. Vui lòng chọn hình ảnh cần lưu." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _txbGhiChu)
    {
        [self hideKeyboard];
        
        [ActionSheetStringPicker showPickerWithTitle:@"Mã ảnh" rows:_arrGhiChu initialSelection:indexGhiChu doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            _txbGhiChu.text = (NSString *) selectedValue;
            indexGhiChu = selectedIndex;
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:_txbGhiChu];

        
        return NO;
    }

    return YES;
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txbChiTietGhiChu)
    {
        [_txbChiTietGhiChu resignFirstResponder];
        return YES;
    }
    return YES;
}
-(void) hideKeyboard
{
    [_txbChiTietGhiChu resignFirstResponder];
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *idSegue = segue.identifier;
    if ([idSegue isEqualToString:@"segueOutsideChecking"])
    {
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSData *data = UIImageJPEGRepresentation(_avatar.image, 0.8f);
        NSString *note = _txbChiTietGhiChu.text;
        
        //NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:_txbChiTietGhiChu.text,@"Note",@"1","NoteID",UIImageJPEGRepresentation(_avatar.image, 0.8f),@"dataImage", nil];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:note,@"Note",@"1",@"NoteID",data,@"dataImage", nil];
        
        [user setObject:dict forKey:@"OutsideChecking"];
        [user setObject:[NSString stringWithFormat:@"%d",isHasPhoto] forKey:@"OutsideChecking_Available"];
        
        [user synchronize];
        
        NSLog(@"isHasPhoto = %d",isHasPhoto);
    }
}
@end
