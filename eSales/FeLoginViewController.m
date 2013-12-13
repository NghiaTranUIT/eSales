//
//  FeLoginViewController.m
//  eSales
//
//  Created by Nghia Tran on 8/22/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeLoginViewController.h"
#import "FeMainViewController.h"
#import "FeDatabaseManager.h"
#import "FeSettingViewController.h"

@interface FeLoginViewController () <FeMainViewDelegate,FeSettingDelegate>
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *idUserName;
@end

@implementation FeLoginViewController
@synthesize txbPassword = _txbPassword, txbUsername = _txbUsername;
@synthesize userName = _userName, idUserName = _idUserName;

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
    
    // Load Name
    NSString *docsDir;
    NSArray *dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    NSString *Path = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"TempLogin.data"]];
    NSData *data = [[NSData alloc] initWithContentsOfFile:Path];

    NSMutableDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSLog(@"dict = %@",dict);
    _txbUsername.text = [dict objectForKey:@"SlsperID"];
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _txbPassword.text = @"";
}
-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_txbPassword resignFirstResponder];
    [_txbUsername resignFirstResponder];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginTapped:(id)sender
{
    // request from WS
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    if ([db loginWithUsername:_txbUsername.text password:_txbPassword.text])
    {
        [self performSegueWithIdentifier:@"segueMainScreen" sender:self];
        
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"Đăng Nhập không thành công" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alertView show];
    }
    
    
}

- (IBAction)aboutUsTapped:(id)sender
{
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txbUsername)
        {
            [_txbUsername resignFirstResponder];
            
            [_txbPassword becomeFirstResponder];
        }
    
    if (textField == _txbPassword)
        [self loginTapped:self];
    
    return YES;
    
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *idSuege = segue.identifier;
    
    if ([idSuege isEqualToString:@"segueMainScreen"])
    {
        UINavigationController *navi = segue.destinationViewController;
        FeMainViewController *mainView = [navi.viewControllers objectAtIndex:0];
        
        mainView.delegate = self;
        mainView.userName = _userName;
        mainView.idUserName = _idUserName;
    }
}
-(void) FeMainViewDelegateLogOut:(FeMainViewController *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void) FeSettingDelegateShouldLogout:(FeSettingViewController *)sender
{
     [self dismissViewControllerAnimated:YES completion:nil];
    
    // Delete All table
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    [db deleteAllTableForLogout];
}
@end
