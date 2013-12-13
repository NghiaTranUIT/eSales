//
//  FeNhaPhanPhoiViewController.m
//  eSales
//
//  Created by Nghia Tran on 8/23/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeNhaPhanPhoiViewController.h"
#import "FeDatabaseManager.h"
@interface FeNhaPhanPhoiViewController () <UIAlertViewDelegate>

@end

@implementation FeNhaPhanPhoiViewController
@synthesize txbNhaPhanPhoi1 = _txbNhaPhanPhoi1, txbNhaPhanPhoi2 = _txbNhaPhanPhoi2, txbNhaPhanPhoi3 = _txbNhaPhanPhoi3, txbNhaPhanPhoi4 = _txbNhaPhanPhoi4, txbNhaPhanPhoi5 = _txbNhaPhanPhoi5, dictKHMoi=_dictKHMoi;

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

- (IBAction)luuTapped:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"Bạn có muốn lưu lại toàn bộ dự liệu KH hay không ?" delegate:self cancelButtonTitle:@"Quay lại" otherButtonTitles:@"Lưu", nil];
    
    [alert show];
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (_txbNhaPhanPhoi1 == textField)
        [_txbNhaPhanPhoi2 becomeFirstResponder];
    if (_txbNhaPhanPhoi2 == textField)
        [_txbNhaPhanPhoi3 becomeFirstResponder];
    if (_txbNhaPhanPhoi3 == textField)
        [_txbNhaPhanPhoi4 becomeFirstResponder];
    if (_txbNhaPhanPhoi4 == textField)
        [_txbNhaPhanPhoi5 becomeFirstResponder];
    if (_txbNhaPhanPhoi5 == textField)
        [_txbNhaPhanPhoi5 resignFirstResponder];
    return YES;
}
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag != 100)
    {
        switch (buttonIndex) {
            case 1:
            {
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                [user setObject:_txbNhaPhanPhoi1.text forKey:@"6_Dis1"];
                [user setObject:_txbNhaPhanPhoi2.text forKey:@"6_Dis2"];
                [user setObject:_txbNhaPhanPhoi3.text forKey:@"6_Dis3"];
                [user setObject:_txbNhaPhanPhoi4.text forKey:@"6_Dis4"];
                [user setObject:_txbNhaPhanPhoi5.text forKey:@"6_Dis5"];
                
                FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
                
                NSString *custID = [self.dictKHMoi objectForKey:@"CustID"];
                if(custID != nil) //Update KH
                {
                    [db updateNewCustomerWithDict:_dictKHMoi UsingNSUserDefaultWithCompletionHandler:^(BOOL success)
                     {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông báo " message:@"Lưu Thành Công" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                         alert.tag = 100;
                         
                         [alert show];
                     }];
                    
                }else // Them Moi
                {
                    [db saveNewCustomerUsingNSUserDefaultWithCompletionHandler:^(BOOL success)
                     {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thông báo " message:@"Lưu Thành Công" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                         alert.tag = 100;
                         
                         [alert show];
                     }];
                }
        
                break;
            }
                
            default:
                break;
        }
    }
    else if (alertView.tag == 100)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
