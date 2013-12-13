//
//  FeCustomerViewController.m
//  eSales
//
//  Created by Nghia Tran on 8/22/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeCustomerViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "FeThongTinKHViewController.h"

@interface FeCustomerViewController () <CLLocationManagerDelegate,UIPopoverControllerDelegate>
-(void) setupDefault;

@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) CLLocationManager *location;
@end

@implementation FeCustomerViewController
@synthesize avatarCusttomer = _avatarCusttomer, lat = _lat, lng = _lng, dictKHMoi=_dictKHMoi;
@synthesize location = _location;
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
    
    [self setupDefault];
}
-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [_location stopUpdatingLocation];
}
-(void) setupDefault
{
    NSString *custID = [_dictKHMoi objectForKey:@"CustID"];
    if(custID != nil) //Update KH
    {
        _lat.text = [_dictKHMoi objectForKey:@"Lat"];
        _lng.text = [_dictKHMoi objectForKey:@"Lng"];
        
        // get direc document
        NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [array objectAtIndex:0];
        
        //pic 1
        NSString *thePath = [NSString stringWithFormat:@"%@/%@.jpg",  documentPath, [_dictKHMoi objectForKey:@"ImageFileName"]];
        
        UIImage *img = [[UIImage alloc] initWithContentsOfFile:thePath];
        _avatarCusttomer.image = img;
        
    }else // Them Moi KH
    {
        
        // get current locaton
        _location = [[CLLocationManager alloc] init];
        
        _location.delegate = self;
        _location.desiredAccuracy = kCLLocationAccuracyBest;
        _location.distanceFilter = kCLDistanceFilterNone;
        
        [_location startUpdatingLocation];
    }
    
    // background
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    bg.frame = self.view.frame;
    bg.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view insertSubview:bg atIndex:0];
    
    _avatarCusttomer.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takeAvatar:)];
    [_avatarCusttomer addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takeAvatar:(id)sender
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
    
    
    _avatarCusttomer.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [_popover dismissPopoverAnimated:YES];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *errorType = (error.code == kCLErrorDenied) ? @"Access Denied" : @"Unknown Error";
    if ([errorType isEqualToString:@"Access Denied"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You should allow eSales use Core Location." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unknown Error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
    }
}
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CGFloat lat = _location.location.coordinate.latitude;
    CGFloat lng = _location.location.coordinate.longitude;
    
    _lat.text = [NSString stringWithFormat:@"%f",lat];
    _lng.text = [NSString stringWithFormat:@"%f",lng];
    
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *idSegue = segue.identifier;
    if ([idSegue isEqualToString:@"pushThongTinKH"])
    {
        
        // Save to UserDefault
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        [userDefault setObject:UIImageJPEGRepresentation(_avatarCusttomer.image, 0.8) forKey:@"1_avatarCustomer"];
        [userDefault setObject:_lat.text forKey:@"1_lat"];
        [userDefault setObject:_lng.text forKey:@"1_lng"];
        
        [userDefault synchronize];
        
        // Update
        FeThongTinKHViewController *feTTKH = (FeThongTinKHViewController*)segue.destinationViewController;
        feTTKH.dictKHMoi = self.dictKHMoi;
        
    }
}
@end
