//
//  selectCityTableViewController.m
//  WeatherApp
//
//  Created by GMH on 5/8/16.
//  Copyright © 2016 com.zy.weather. All rights reserved.
//

#import "selectCityTableViewController.h"

@interface selectCityTableViewController ()<UISearchBarDelegate,UISearchDisplayDelegate>
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplay;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property(nonatomic) NSMutableArray *cityArr;
@property(nonatomic) NSMutableArray *searchArr;
@end

@implementation selectCityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0]stringByAppendingPathComponent:@"cityInfo.plist"];
    NSArray *plistArray=[NSArray arrayWithContentsOfFile:path];
    self.cityArr=[[NSMutableArray alloc]init];
    for (NSDictionary *dict in plistArray) {
        [self.cityArr addObject:[dict objectForKey:@"city"]];
    }
    [self.tableView reloadData];
    NSLog(@"%@",self.cityArr);
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self addNav];
}

-(void)addNav{
    
    UILabel *labelBack=[[UILabel alloc]initWithFrame:CGRectMake(0, -20, [UIScreen mainScreen].bounds.size.width, self.navigationController.navigationBar.frame.size.height+20)];
    labelBack.backgroundColor=[UIColor blackColor];
    labelBack.text=@"选择城市";
    labelBack.textAlignment=NSTextAlignmentCenter;
    labelBack.textColor=[UIColor whiteColor];
    [self.navigationController.navigationBar addSubview:labelBack];
    
    UIBarButtonItem *cancleItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(addItemClick)];
    [cancleItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItems=@[cancleItem];
    
}
-(void)addItemClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    if (tableView==self.tableView) {
        return self.cityArr.count;
    }else if (tableView==self.searchDisplay.searchResultsTableView){
        return self.searchArr.count;
    }else{
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"resue"];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"reuse"];
    }
    if (tableView==self.tableView) {
        for (NSString *city in self.cityNameArr) {
            if ([city isEqualToString:self.cityArr[indexPath.row]]) {
                cell.detailTextLabel.text=@"已选择";
                cell.userInteractionEnabled=NO;
            }
        }
        cell.textLabel.text=self.cityArr[indexPath.row];
    }else if (tableView==self.searchDisplay.searchResultsTableView){
        for (NSString *city in self.cityNameArr) {
            if ([city isEqualToString:self.searchArr[indexPath.row]]) {
                cell.detailTextLabel.text=@"已选择";
                cell.userInteractionEnabled=NO;
            }
        }
        cell.textLabel.text=self.searchArr[indexPath.row];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==self.tableView) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddCity" object:self userInfo:@{@"cityName":self.cityArr[indexPath.row]}];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if (tableView==self.searchDisplay.searchResultsTableView){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddCity" object:self userInfo:@{@"cityName":self.searchArr[indexPath.row]}];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.searchArr=[[NSMutableArray alloc]init];
    for (NSString *city in self.cityArr) {
        if ([city containsString:searchBar.text]) {
            [self.searchArr addObject:city];
        }
    }
    if (!self.searchArr.count) {
        UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"出错了!" message:@"没有此城市！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action=[UIAlertAction actionWithTitle:@"OK" style:UIAlertControllerStyleAlert handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
        searchBar.text=@"";
    }
    [self.searchDisplay.searchResultsTableView reloadData];
    
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length) {
        self.searchArr=[[NSMutableArray alloc]init];
        for (NSString *city in self.cityArr) {
            if ([city containsString:searchBar.text]) {
                [self.searchArr addObject:city];
            }
        }
        [self.searchDisplay.searchResultsTableView reloadData];
    }
}
@end
