//
//  FeDetailCustTradeViewController.m
//  eSales
//
//  Created by MAC on 10/3/13.
//  Copyright (c) 2013 Fe. All rights reserved.
//

#import "FeDetailCustTradeViewController.h"
#import "FeDatabaseManager.h"
#import "FeDetailCustTradeCell.h"

@interface FeDetailCustTradeViewController ()
{
    BOOL isSearching;
}
@property (strong, nonatomic) NSMutableArray *arrSearching;

@end

@implementation FeDetailCustTradeViewController
@synthesize tableViewCust=_tableViewCust, tableViewDetail=_tableViewDetail, arrCustNonTrade=_arrCustNonTrade, arrSurveyBrand=_arrSurveyBrand, searchBar=_searchBar, arrSearching=_arrSearching;

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
    
    // BG
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    bg.frame = self.view.frame;
    bg.contentMode = UIViewContentModeScaleAspectFill;
    //[self.view insertSubview:bg atIndex:0];
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
    _tableViewCust.dataSource = self;
    _tableViewCust.delegate = self;
    _tableViewDetail.dataSource = self;
    _tableViewDetail.delegate = self;
    
    //Register cell
    UINib *nib = [UINib nibWithNibName:@"FeDetailCustTradeCell" bundle:[NSBundle mainBundle]];
    [_tableViewCust registerNib:nib forCellReuseIdentifier:@"FeDetailCustTradeCell"];

    if (!_arrCustNonTrade || _arrCustNonTrade.count == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"Không tìm thấy khách hàng" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alertView show];
        [_tableViewCust reloadData];
    }else
    {
        [_tableViewCust reloadData];
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == _tableViewCust)
        return 1;
    else
        return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == _tableViewCust)
    {
        if (isSearching)
            return [_arrSearching count];
        else
            return [_arrCustNonTrade count];
    }        
    else
    {
        return [_arrSurveyBrand count];
    }
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *IDCell = @"FeDetailCustTradeCell";
    
    FeDetailCustTradeCell *cell = [_tableViewCust dequeueReusableCellWithIdentifier:IDCell forIndexPath:indexPath];

    if(tableView == _tableViewCust)
    {
        NSMutableDictionary *dictCust;
        
        if (isSearching)
        {
            dictCust = [_arrSearching objectAtIndex:indexPath.row];
        }
        else
        {
            dictCust = [_arrCustNonTrade objectAtIndex:indexPath.row];
        }

        cell.lblMaKH.text = [dictCust objectForKey:@"CustID"];
        cell.lblTenKH.text = [dictCust objectForKey:@"CustName"];
        cell.lblDiaChi.text = [dictCust objectForKey:@"Address"];
        
        return cell;
    }else
    {
        NSMutableDictionary *dictSurveyBrand = [_arrSurveyBrand objectAtIndex:indexPath.row];
        
        cell.lblMaKH.text = [dictSurveyBrand objectForKey:@"Brand"];
        cell.lblTenKH.text = [NSString stringWithFormat: @"%@", [dictSurveyBrand objectForKey:@"ThucTe"] ];
        cell.lblDiaChi.text = [NSString stringWithFormat: @"%@",[dictSurveyBrand objectForKey:@"ChiTieu"]];
        
        return cell;
    }
  
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dictCust;
    if(isSearching)
    {
        dictCust = [_arrSearching objectAtIndex:indexPath.row];
    }else
    {
        dictCust = [_arrCustNonTrade objectAtIndex:indexPath.row];
    }
    NSString *custID = [dictCust objectForKey:@"CustID"];
    
    // DB
    FeDatabaseManager *db = [FeDatabaseManager sharedInstance];
    _arrSurveyBrand = [[NSMutableArray alloc] init];
    _arrSurveyBrand = [db arrSurveyBrandFromDatabaseWithCustID:custID];
    
    if (!_arrSurveyBrand || _arrSurveyBrand.count == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thông Báo" message:@"Không tìm thấy nhãn hàng" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alertView show];
        [_tableViewDetail reloadData];
    }else
    {
        [_tableViewDetail reloadData];
    }    
}
-(void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    isSearching = NO;
    _searchBar.text = @"";
    [_searchBar resignFirstResponder];
    
    [_tableViewCust reloadData];
}
-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [_searchBar becomeFirstResponder];
}
-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // clear truoc khi search
    [_arrSurveyBrand removeAllObjects];
    [_tableViewDetail reloadData];
    
    _arrSearching = [[NSMutableArray alloc] init];
    
    if (![searchText isEqualToString:@""])
    {
        isSearching = YES;
        for (NSMutableDictionary *dict in _arrCustNonTrade)
        {
            NSString *custName = [dict valueForKey:@"CustName"];
            NSString *custID = [dict objectForKey:@"CustID"];
            NSString *addr = [dict objectForKey:@"Address"];
            
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
        [_tableViewCust reloadData];
    }
    else
    {
        isSearching = NO;
        [_tableViewCust reloadData];
    }
    
}
@end
