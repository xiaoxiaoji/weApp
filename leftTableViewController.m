//
//  leftTableViewController.m
//  WeatherApp
//
//  Created by GMH on 5/7/16.
//  Copyright © 2016 com.zy.weather. All rights reserved.
//

#import "leftTableViewController.h"
#import "mainViewController.h"
#import "navViewController.h"
#import "selectCityTableViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "UIImageView+WebCache.h"
#import <ViewDeck.h>
#import <AFNetworking.h>
#import "getInfoModel.h"

@interface leftTableViewController ()<CLLocationManagerDelegate,IIViewDeckControllerDelegate>
@property(nonatomic) NSMutableArray *cityNameArr;
@property(nonatomic) NSMutableArray *WEATHER_INFO_ARR;
@property(nonatomic,strong) CLLocationManager *locationManager;
@property(nonatomic) NSString *cityName;
@property(nonatomic) NSUserDefaults *defaults;
@property(nonatomic) getInfoModel *model;
@end

@implementation leftTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.WEATHER_INFO_ARR=[[NSMutableArray alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddCity:) name:@"AddCity" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetWeatherInfomation:) name:@"getWeInfo" object:nil];
    self.viewDeckController.delegate =self;
    self.defaults=[NSUserDefaults standardUserDefaults];
    [self addNav];
    self.cityNameArr=[[NSMutableArray alloc]init];
    NSMutableArray *arr=[[self.defaults objectForKey:@"CityNameArr"] mutableCopy];
    self.cityNameArr=arr;
    [self creatPlist];
    //[self startLocation];
    //[self getWeInfomation];
    //[self creatPlist];
    // self.clearsSelectionOnViewWillAppear = NO;
}
-(void)getWeInfomation{
    self.model=[[getInfoModel alloc]init];
    for (NSString *city in self.cityNameArr) {
        
        
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0]stringByAppendingPathComponent:@"cityInfo.plist"];
        NSArray *plistArray=[NSArray arrayWithContentsOfFile:path];
        NSString *cityId;
        for (NSDictionary *dict in plistArray) {
            if ([city isEqualToString:[dict objectForKey:@"city"]]) {
                cityId=[dict objectForKey:@"id"];
            }
        }
//        NSMutableString *cityOne=[city mutableCopy];
//        CFStringTransform((__bridge CFMutableStringRef)cityOne, NULL, kCFStringTransformMandarinLatin, NO);
//        CFStringTransform((__bridge CFMutableStringRef)cityOne, NULL, kCFStringTransformStripCombiningMarks, NO);
//        NSString *cityFinal=[cityOne stringByReplacingOccurrencesOfString:@" " withString:@""];
//        NSLog(@"%@", cityFinal);
        NSString *getWeInfoUrl=[NSString stringWithFormat:@"https://api.heweather.com/x3/weather?cityid=%@&key=811180bf663341619d76ded7863e5e27",cityId];
        [self.model getWeInfo:getWeInfoUrl];
    }
}
-(void)AddCity:(NSNotification *)notification{
    NSString *city=notification.userInfo[@"cityName"];
    [self.cityNameArr addObject:city];
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0]stringByAppendingPathComponent:@"cityInfo.plist"];
    NSArray *plistArray=[NSArray arrayWithContentsOfFile:path];
    NSString *cityId;
    for (NSDictionary *dict in plistArray) {
        if ([city isEqualToString:[dict objectForKey:@"city"]]) {
            cityId=[dict objectForKey:@"id"];
        }
    }
    NSString *requestUrl=[NSString stringWithFormat:@"https://api.heweather.com/x3/weather?cityid=%@&key=811180bf663341619d76ded7863e5e27",cityId];
    [manager GET:requestUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"succeed :%@",responseObject);
        NSDictionary *weatherInfomationDic=responseObject;
        NSArray *weatherInfomationArr=[weatherInfomationDic objectForKey:@"HeWeather data service 3.0"];
        [self.WEATHER_INFO_ARR addObject:weatherInfomationArr];
        [self.defaults setObject:self.cityNameArr forKey:@"CityNameArr"];
        [self.defaults synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddCityToMain" object:self userInfo:@{@"cityNameArr":self.cityNameArr,@"WEATHER_INFO_ARR":self.WEATHER_INFO_ARR}];
        [self.viewDeckController closeLeftViewAnimated:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error :%@",error);
    }];
   // [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AddCity" object:nil];
}
-(void)creatPlist{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@"cityInfo.plist"];
    NSString *pathTwo = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@"weatherCategoryInfo.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path] == NO)
    {
        self.model=[[getInfoModel alloc]init];
        NSString *getCityUrl=@"https://api.heweather.com/x3/citylist?search=allchina&key=811180bf663341619d76ded7863e5e27";
        [self.model getHotCityInfo:getCityUrl];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetCity:) name:@"getCityInfo" object:nil];
    }else{
        [self startLocation];

    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathTwo] == NO)
    {
        self.model=[[getInfoModel alloc]init];
        NSString *getWeatherCategoryUrl=@"https://api.heweather.com/x3/condition?search=allcond&key=811180bf663341619d76ded7863e5e27";
        [self.model getweatherCategoryInfo:getWeatherCategoryUrl];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GerWeatherCategory:) name:@"getweatherCategoryInfo" object:nil];
    }
}
-(void)startLocation{
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager=[[CLLocationManager alloc]init];
        _locationManager.delegate=self;
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        _locationManager.distanceFilter=10.0f;
        [_locationManager requestAlwaysAuthorization];
        [_locationManager startUpdatingLocation];
    }
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    [_locationManager stopUpdatingLocation];
    CLLocation *currentLocation=[locations lastObject];
    CLGeocoder *geoCoder=[[CLGeocoder alloc]init];
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        for(CLPlacemark *place in placemarks)
        {
            NSLog(@"latitude : %f,longitude: %f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude);
            NSDictionary *dict = [place addressDictionary];
            self.cityName=[dict objectForKey:@"City"];
            if ([self.cityName containsString:@"市"]) {
                self.cityName=[self.cityName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"市"]];
            }
            if (self.cityNameArr.count) {
                if (![[self.cityNameArr firstObject] isEqualToString:self.cityName]) {
                    //[self.cityNameArr replaceObjectAtIndex:0 withObject:self.cityName];
                    [self.cityNameArr insertObject:self.cityName atIndex:0];
                    [self.defaults setObject:self.cityNameArr forKey:@"CityNameArr"];
                    [self.defaults synchronize];
                    [self getWeInfomation];
                }else{
                    [self getWeInfomation];
                }
            }else{
                self.cityNameArr=[[NSMutableArray alloc]init];
                [self.cityNameArr addObject:self.cityName];
                [self.defaults setObject:self.cityNameArr forKey:@"CityNameArr"];
                [self.defaults synchronize];
                [self getWeInfomation];
            }
        }
    }];
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"error is :%@",error);
}
-(void)addNav{
    
    
    UILabel *labelBack=[[UILabel alloc]initWithFrame:CGRectMake(0, -20, self.view.frame.size.width, self.navigationController.navigationBar.frame.size.height+20)];
    labelBack.backgroundColor=[UIColor blackColor];
    [self.navigationController.navigationBar addSubview:labelBack];
    
    UIBarButtonItem *addItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemClick)];
    [addItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItems=@[addItem];
    
}
-(void)addItemClick{
    selectCityTableViewController *selectCityView=[[selectCityTableViewController alloc]initWithNibName:@"selectCityTableViewController" bundle:nil];
    navViewController *navView=[[navViewController alloc]initWithRootViewController:selectCityView];
    selectCityView.cityNameArr=self.cityNameArr;
    [self presentViewController:navView animated:YES completion:nil];
}
-(void)GetCity:(NSNotification *)notification{
    NSDictionary *cityInfo=notification.userInfo[@"InfoFromAPI"];
    NSArray *cityInfoArr=[cityInfo objectForKey:@"city_info"];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0]stringByAppendingPathComponent:@"cityInfo.plist"];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:path contents:nil attributes:nil];
    [cityInfoArr writeToFile:path atomically:YES];
    [self startLocation];
}
-(void)GerWeatherCategory:(NSNotification *)notification{
    NSDictionary *weatherCategoryInfo=notification.userInfo[@"InfoFromAPI"];
    NSArray *weatherCategoryInfoArr=[weatherCategoryInfo objectForKey:@"cond_info"];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0]stringByAppendingPathComponent:@"weatherCategoryInfo.plist"];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:path contents:nil attributes:nil];
    [weatherCategoryInfoArr writeToFile:path atomically:YES];
}
-(void)GetWeatherInfomation:(NSNotification *)notification{
    NSDictionary *weatherInfomationDic=notification.userInfo[@"InfoFromAPI"];
    NSArray *weatherInfomationArr=[weatherInfomationDic objectForKey:@"HeWeather data service 3.0"];
    [self.WEATHER_INFO_ARR addObject:weatherInfomationArr];
    if (self.WEATHER_INFO_ARR.count==self.cityNameArr.count) {
        NSMutableArray *arr=[[NSMutableArray alloc]init];
        for (NSString *city in self.cityNameArr) {
            for (int i=0; i<self.WEATHER_INFO_ARR.count; i++) {
                if ([[[[self.WEATHER_INFO_ARR[i] lastObject] objectForKey:@"basic"] objectForKey:@"city"] isEqualToString:city]) {
                    [arr addObject:self.WEATHER_INFO_ARR[i]];
                }
            }
        }
        self.WEATHER_INFO_ARR=arr;
        [self.tableView reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getWeatherInfoToMain" object:self userInfo:@{@"cityARR":self.cityNameArr,@"weatherInfoArr":self.WEATHER_INFO_ARR}];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.cityNameArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"resue"];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reuse"];
    }
    if (tableView==self.tableView) {
        if (indexPath.row==0) {
            cell.editing=NO;
        }
        cell.textLabel.text=self.cityNameArr[indexPath.row];
        
        if (self.WEATHER_INFO_ARR.count) {
            UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(100, 5, 50, 40)];
            imageView.center=CGPointMake(125, 25);
            NSDictionary *weInfoDic=self.WEATHER_INFO_ARR[indexPath.row][0];
            
           
            
            NSString *weCategory=[[[weInfoDic objectForKey:@"now"] objectForKey:@"cond"] objectForKey:@"code"];
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0]stringByAppendingPathComponent:@"weatherCategoryInfo.plist"];
            NSArray *plistArray=[NSArray arrayWithContentsOfFile:path];
            for (NSDictionary *dict in plistArray) {
                if ([[dict objectForKey:@"code"] isEqualToString:weCategory]) {
                    [imageView sd_setImageWithURL:[dict objectForKey:@"icon"]];
                    [cell.contentView addSubview:imageView];
                }
            }
            NSString *maxTmp=[[[weInfoDic objectForKey:@"daily_forecast"][0] objectForKey:@"tmp"] objectForKey:@"max"];
            NSString *minTmp=[[[weInfoDic objectForKey:@"daily_forecast"][0] objectForKey:@"tmp"] objectForKey:@"min"];
            NSString *tmpRange=[NSString stringWithFormat:@"%@℃~%@℃",minTmp,maxTmp];
            UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(200, 5, 100, 40)];
            label.text=tmpRange;
            [cell.contentView addSubview:label];
        }
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
        return 50;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *index=[NSString stringWithFormat:@"%ld",(long)indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"select" object:self userInfo:@{@"indexPath":index}];
    [self.viewDeckController closeLeftViewAnimated:YES];
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.cityNameArr removeObjectAtIndex:[indexPath row]];
        [self.WEATHER_INFO_ARR removeObjectAtIndex:[indexPath row]];
        [self.defaults setObject:self.cityNameArr forKey:@"CityNameArr"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getWeatherInfoToMain" object:self userInfo:@{@"cityARR":self.cityNameArr,@"weatherInfoArr":self.WEATHER_INFO_ARR}];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView reloadData];
        [self.viewDeckController closeLeftViewAnimated:YES];
    }
    
    //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除                                                                             ";
}
//-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"  " handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
//    }];
//    UITableViewRowAction *editRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
//        
//    }];
//   //editRowAction.backgroundColor = [UIColor colorWithRed:0 green:124/255.0 blue:223/255.0 alpha:1];
//    return @[deleteRoWAction, editRowAction];
//}
//-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//}
//-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//}
@end
