//
//  FeMainViewController.m
//  eSales
//
//  Created by Nghia Tran on 8/22/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeMainViewController.h"
#import "FeWebservice.h"
#import "FeSyncView.h"
#import "FeSettingViewController.h"

#import "FeDatabaseManager.h"
#import "FeWebservice.h"


@interface FeMainViewController () <FeSyncViewDelegate>
@property (strong, nonatomic) FeSyncView *syncView;
@end

@implementation FeMainViewController
@synthesize delegate = _delegate, statusSaler = _statusSaler;
@synthesize syncView = _syncView;

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
    
    // background
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    bg.frame = self.view.frame;
    bg.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view insertSubview:bg atIndex:0];
    
    // Save
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:[user valueForKey:@"Setting"]];
    
    NSString *ID = [dict objectForKey:@"SlsperID"];
    NSString *name = [dict objectForKey:@"CpnyName"];
    
    _statusSaler.text = [NSString stringWithFormat:@"%@ - %@",ID,name];
    
    //
    NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"FeSyncView" owner:self options:nil];
    _syncView = [arr lastObject];
    _syncView.frame =  CGRectMake(0, 0, _syncView.frame.size.width, _syncView.frame.size.height);
    _syncView.alpha = 0;
    _syncView.delegate = self;
    [self.view addSubview:_syncView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginTapped:(id)sender
{
    [_delegate FeMainViewDelegateLogOut:self];
}

- (IBAction)btnSyncTapped:(id)sender
{
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _syncView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    
    
    /*
    [ws loginWithCompletionHandler:^(BOOL success) {
        NSLog(@"dict = %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"HeaderSOAP"]);
    }];
    */
}
-(void) FeSyncViewDelegateDismissView:(FeSyncView *)sender
{
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _syncView.alpha = 0;
    } completion:^(BOOL finished) {
    }];
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *idSegue = segue.identifier;
    
    if ([idSegue isEqualToString:@"segueSetting"])
    {
        FeSettingViewController *settingViewController = segue.destinationViewController;
        settingViewController.delegate = _delegate;
    }
}
- (IBAction)syncImageTapped:(id)sender
{
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    NSMutableArray *arrPhotoName = [db arrNamePhotoFromDatabase];
    NSLog(@"arrPhotoname = %@",arrPhotoName);
    
    FeWebservice *ws = [FeWebservice shareInstance];
    
    for (NSString *namePhoto in arrPhotoName)
    {
        [ws syncPhotoName:namePhoto];
    }

}
@end
