//
//  FeQueryViewController.m
//  eSales
//
//  Created by MAC on 10/3/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeQueryViewController.h"
#import "FeDatabaseManager.h"
#import "FeQueryCell.h"
#import "FeDetailCustTradeViewController.h"
#import "FeDetailCustNonTradeViewController.h"

@interface FeQueryViewController ()
{
    BOOL isSearching;
}
@property(strong, nonatomic)NSMutableArray *arrCust;
@property(strong, nonatomic)NSMutableArray *arrCustNonTrade;
@property(strong, nonatomic)NSMutableArray *arrCustTrade;
@property (strong, nonatomic) NSMutableArray *arrSearching;

@end

@implementation FeQueryViewController
@synthesize tableView=_tableView, arrCust=_arrCust, arrCustNonTrade=_arrCustNonTrade, arrCustTrade=_arrCustTrade, searchBar=_searchBar, arrSearching=_arrSearching;

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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setupDefaultView
{
    isSearching = NO;
    _arrSearching = [[NSMutableArray alloc] init];

    // delegate table view
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    //Register cell
    UINib *nib = [UINib nibWithNibName:@"FeQueryCell" bundle:[NSBundle mainBundle]];
    [_tableView registerNib:nib forCellReuseIdentifier:@"FeQueryCell"];
    
    // DB
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    _arrCust = [[NSMutableArray alloc] init];
    _arrCust = [db arrPPC_ARCustomerInfoFromDatabase];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isSearching)
        return [_arrSearching count];
    else
        return [_arrCust count];
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *IDCell = @"FeQueryCell";
    
    FeQueryCell *cell = [_tableView dequeueReusableCellWithIdentifier:IDCell forIndexPath:indexPath];
    
    NSMutableDictionary *dictCust;
    
    if (isSearching)
    {
        dictCust = [_arrSearching objectAtIndex:indexPath.row];
    }
    else
    {
        dictCust = [_arrCust objectAtIndex:indexPath.row];
    }
    
    cell.lblMaKH.text = [dictCust objectForKey:@"CustID"];
    cell.lblTenKH.text = [dictCust objectForKey:@"CustName"];
    cell.lblDiaChi.text = [dictCust objectForKey:@"Addr1"];
                           
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dictCust = [_arrCust objectAtIndex:indexPath.row];
    NSString *tradeType = [dictCust objectForKey:@"TradeType"];
    NSString *custID = [dictCust objectForKey:@"CustID"];
    
    // DB
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    
    if([tradeType isEqualToString:@"T"])
    {
        NSLog(@"Trade");
        _arrCustNonTrade = [db arrCustomerNonTradeFromDatabaseWithCustID:custID];
        [self performSegueWithIdentifier:@"segueCustTrade" sender:self];
    }else
    {
        NSLog(@"Non Trade");
        _arrCustTrade = [db arrCustomerTradeFromDatabaseWithCustID:custID];
        [self performSegueWithIdentifier:@"segueCustNonTrade" sender:self];
    }
}

-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    isSearching = NO;
    _searchBar.text = @"";
    [_searchBar resignFirstResponder];
    
    [_tableView reloadData];
}
-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [_searchBar becomeFirstResponder];
}
-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _arrSearching = [[NSMutableArray alloc] init];
    
    if (![searchText isEqualToString:@""])
    {
        isSearching = YES;
        for (NSMutableDictionary *dict in _arrCust)
        {
            NSString *custName = [dict valueForKey:@"CustName"];
            NSString *custID = [dict objectForKey:@"CustID"];
            NSString *addr = [dict objectForKey:@"Addr1"];
            
            if ([custName rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [_arrSearching addObject:dict];
            }
            else if ([custID rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [_arrSearching addObject:dict];
            }
            else if ([addr rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [_arrSearching addObject:dict];
            }
        }
        [_tableView reloadData];
    }
    else
    {
        isSearching = NO;
        [_tableView reloadData];
    }
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueCustTrade"])
    {
		FeDetailCustTradeViewController *cust = (FeDetailCustTradeViewController*)segue.destinationViewController;
        cust.arrCustNonTrade = _arrCustNonTrade;
        
    }
    if ([segue.identifier isEqualToString:@"segueCustNonTrade"])
    {
		FeDetailCustNonTradeViewController *cust = (FeDetailCustNonTradeViewController*)segue.destinationViewController;
        cust.arrCustTrade = _arrCustTrade;
    }
}
@end
