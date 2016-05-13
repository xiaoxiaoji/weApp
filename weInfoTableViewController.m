//
//  weInfoTableViewController.m
//  WeatherApp
//
//  Created by GMH on 5/7/16.
//  Copyright © 2016 com.zy.weather. All rights reserved.
//

#import "weInfoTableViewController.h"
#import "UIImageView+WebCache.h"
#import <PNChart.h>
#import <AFNetworking.h>
@interface weInfoTableViewController ()
@end

@implementation weInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIRefreshControl *control=[[UIRefreshControl alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    control.tintColor=[UIColor whiteColor];
    [control addTarget:self action:@selector(refreshStateChange:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:control];
    [control beginRefreshing];
    [self refreshStateChange:control];
    
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.delaysContentTouches = NO;
    self.tableView.backgroundColor=[UIColor clearColor];
    self.clearsSelectionOnViewWillAppear = NO;
    
}
-(void)refreshStateChange:(UIRefreshControl *)control{
    self.title=@"";
    NSString *cityId=[[self.WE_INFO_ARR[0] objectForKey:@"basic"] objectForKey:@"id"];
    NSString *requestUrl=[NSString stringWithFormat:@"https://api.heweather.com/x3/weather?cityid=%@&key=811180bf663341619d76ded7863e5e27",cityId];
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    [manager GET:requestUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"succeed :%@",responseObject);
        
        self.WE_INFO_ARR=[responseObject objectForKey:@"HeWeather data service 3.0"];
        [control endRefreshing];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            self.title=[[self.WE_INFO_ARR[0] objectForKey:@"basic"] objectForKey:@"city"];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error :%@",error);
        [control endRefreshing];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 6;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"resue"];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuse"];
    }
    
    cell.backgroundColor=[UIColor clearColor];
    cell.userInteractionEnabled=NO;
    NSDictionary *weInfoDic=self.WE_INFO_ARR[0];
    if (indexPath.row==0) {
        NSString *weCategory=[NSString stringWithFormat:@"%@°",[[weInfoDic objectForKey:@"now"] objectForKey:@"tmp"]];
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(40, 90, self.view.frame.size.width, 150)];
        label.text=weCategory;
        label.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:160];
        label.textColor=[UIColor whiteColor];
        [cell.contentView addSubview:label];
    }else if (indexPath.row==1){
        UIImageView *cellImageView=[[UIImageView alloc]initWithFrame:CGRectMake(30, 10, 60, 60)];
        NSString *categoryCode=[[[weInfoDic objectForKey:@"now"] objectForKey:@"cond"] objectForKey:@"code"];
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0]stringByAppendingPathComponent:@"weatherCategoryInfo.plist"];
        NSArray *plistArray=[NSArray arrayWithContentsOfFile:path];
        for (NSDictionary *dict in plistArray) {
            if ([[dict objectForKey:@"code"] isEqualToString:categoryCode]) {
                [cellImageView sd_setImageWithURL:[dict objectForKey:@"icon"]];
                [cell.contentView addSubview:cellImageView];
            }
        }
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(100, 10, self.view.frame.size.width-100, 60)];
        NSString *min=[[[weInfoDic objectForKey:@"daily_forecast"][0] objectForKey:@"tmp"] objectForKey:@"min"];
        NSString *max=[[[weInfoDic objectForKey:@"daily_forecast"][0] objectForKey:@"tmp"] objectForKey:@"max"];
        NSString *tmpStr=[NSString stringWithFormat:@"%@~%@℃",min,max];
        NSString *weCategory=[[[weInfoDic objectForKey:@"now"] objectForKey:@"cond"] objectForKey:@"txt"];
        label.text=[NSString stringWithFormat:@"%@  %@",weCategory,tmpStr];
        label.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        label.textColor=[UIColor whiteColor];
        [cell.contentView addSubview:label];
        
        UILabel *labelFl=[[UILabel alloc]initWithFrame:CGRectMake(40, 75, 150, 40)];
        NSString *flTmp=[[weInfoDic objectForKey:@"now"] objectForKey:@"fl"];
        NSString *hum=[[weInfoDic objectForKey:@"now"] objectForKey:@"hum"];
        labelFl.text=[NSString stringWithFormat:@"体感 %@℃  湿度 %@％",flTmp,hum];
        labelFl.textColor=[UIColor whiteColor];
        labelFl.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:15];
        [cell.contentView addSubview:labelFl];
        
        UILabel *labelTime=[[UILabel alloc]initWithFrame:CGRectMake(40, 120, 150, 20)];
        NSString *loc=[[[weInfoDic objectForKey:@"basic"] objectForKey:@"update"] objectForKey:@"loc"];
        labelTime.text=[NSString stringWithFormat:@"于 %@ 发布",loc];
        labelTime.textColor=[UIColor whiteColor];
        labelTime.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:10];
        [cell.contentView addSubview:labelTime];
    }else if (indexPath.row==2){
        UILabel *lineLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
        lineLabel.backgroundColor=[UIColor whiteColor];
        [cell.contentView addSubview:lineLabel];
        
        UILabel *labeTomo=[[UILabel alloc]initWithFrame:CGRectMake(0, 5, self.view.frame.size.width/3, 30)];
        labeTomo.textAlignment=NSTextAlignmentCenter;
        labeTomo.textColor=[UIColor whiteColor];
        labeTomo.text=@"明天";
        [cell.contentView addSubview:labeTomo];
        
        UILabel *labeTomoo=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/3, 5, self.view.frame.size.width/3, 30)];
        labeTomoo.textAlignment=NSTextAlignmentCenter;
        labeTomoo.textColor=[UIColor whiteColor];
        labeTomoo.text=@"后天";
        [cell.contentView addSubview:labeTomoo];
        
        UILabel *labeTomooo=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/3)*2, 5, self.view.frame.size.width/3, 30)];
        labeTomooo.textAlignment=NSTextAlignmentCenter;
        labeTomooo.textColor=[UIColor whiteColor];
        labeTomooo.text=@"大后天";
        [cell.contentView addSubview:labeTomooo];
        
        UILabel *labelTeTomo=[[UILabel alloc]initWithFrame:CGRectMake(0, 35, self.view.frame.size.width/3, 30)];
        labelTeTomo.textAlignment=NSTextAlignmentCenter;
        labelTeTomo.textColor=[UIColor whiteColor];
        NSString *maxTmp=[[[weInfoDic objectForKey:@"daily_forecast"][1] objectForKey:@"tmp"] objectForKey:@"max"];
        NSString *minTmp=[[[weInfoDic objectForKey:@"daily_forecast"][1] objectForKey:@"tmp"] objectForKey:@"min"];
        NSString *tmpRange=[NSString stringWithFormat:@"%@/%@℃",minTmp,maxTmp];
        labelTeTomo.text=tmpRange;
        [cell.contentView addSubview:labelTeTomo];
        
        UILabel *labelTeTomoo=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/3, 35, self.view.frame.size.width/3, 30)];
        labelTeTomoo.textAlignment=NSTextAlignmentCenter;
        labelTeTomoo.textColor=[UIColor whiteColor];
        NSString *maxTmpp=[[[weInfoDic objectForKey:@"daily_forecast"][2] objectForKey:@"tmp"] objectForKey:@"max"];
        NSString *minTmpp=[[[weInfoDic objectForKey:@"daily_forecast"][2] objectForKey:@"tmp"] objectForKey:@"min"];
        NSString *tmpRangee=[NSString stringWithFormat:@"%@/%@℃",minTmpp,maxTmpp];
        labelTeTomoo.text=tmpRangee;
        [cell.contentView addSubview:labelTeTomoo];
        
        UILabel *labelTeTomooo=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/3)*2, 35, self.view.frame.size.width/3, 30)];
        labelTeTomooo.textAlignment=NSTextAlignmentCenter;
        labelTeTomooo.textColor=[UIColor whiteColor];
        NSString *maxTmppp=[[[weInfoDic objectForKey:@"daily_forecast"][3] objectForKey:@"tmp"] objectForKey:@"max"];
        NSString *minTmppp=[[[weInfoDic objectForKey:@"daily_forecast"][3] objectForKey:@"tmp"] objectForKey:@"min"];
        NSString *tmpRangeee=[NSString stringWithFormat:@"%@/%@℃",minTmppp,maxTmppp];
        labelTeTomooo.text=tmpRangeee;
        [cell.contentView addSubview:labelTeTomooo];
        
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0]stringByAppendingPathComponent:@"weatherCategoryInfo.plist"];

        UIImageView *cellImageViewOne=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/6-25, 65, 50, 50)];
        NSString *categoryCodeOne=[[[weInfoDic objectForKey:@"daily_forecast"][1] objectForKey:@"cond"] objectForKey:@"code_d"];
        
        UIImageView *cellImageViewTwo=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-25, 65, 50, 50)];
        NSString *categoryCodeTwo=[[[weInfoDic objectForKey:@"daily_forecast"][2] objectForKey:@"cond"] objectForKey:@"code_d"];
        
        UIImageView *cellImageViewThree=[[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width/6)*5-25, 65, 50, 50)];
        NSString *categoryCodeThree=[[[weInfoDic objectForKey:@"daily_forecast"][3] objectForKey:@"cond"] objectForKey:@"code_d"];
        NSArray *plistArray=[NSArray arrayWithContentsOfFile:path];
        
        for (NSDictionary *dict in plistArray) {
            if ([[dict objectForKey:@"code"] isEqualToString:categoryCodeOne]) {
                [cellImageViewOne sd_setImageWithURL:[dict objectForKey:@"icon"]];
                [cell.contentView addSubview:cellImageViewOne];
            }
            if ([[dict objectForKey:@"code"] isEqualToString:categoryCodeTwo]) {
                [cellImageViewTwo sd_setImageWithURL:[dict objectForKey:@"icon"]];
                [cell.contentView addSubview:cellImageViewTwo];
            }
            if ([[dict objectForKey:@"code"] isEqualToString:categoryCodeThree]) {
                [cellImageViewThree sd_setImageWithURL:[dict objectForKey:@"icon"]];
                [cell.contentView addSubview:cellImageViewThree];
            }
        }
        
        UILabel *labelCaTomo=[[UILabel alloc]initWithFrame:CGRectMake(0, 115, self.view.frame.size.width/3, 30)];
        labelCaTomo.textAlignment=NSTextAlignmentCenter;
        labelCaTomo.textColor=[UIColor whiteColor];
        NSString *txt_d=[[[weInfoDic objectForKey:@"daily_forecast"][1] objectForKey:@"cond"] objectForKey:@"txt_d"];
        NSString *txt_n=[[[weInfoDic objectForKey:@"daily_forecast"][1] objectForKey:@"cond"] objectForKey:@"txt_n"];
        NSString *txt_all;
        if ([txt_d isEqualToString:txt_n]) {
            txt_all=txt_d;
        }else{
            txt_all=[NSString stringWithFormat:@"%@转%@",txt_d,txt_n];
        }
        labelCaTomo.text=txt_all;
        [cell.contentView addSubview:labelCaTomo];
        
        UILabel *labelCaTomoo=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/3, 115, self.view.frame.size.width/3, 30)];
        labelCaTomoo.textAlignment=NSTextAlignmentCenter;
        labelCaTomoo.textColor=[UIColor whiteColor];
        NSString *txt_dd=[[[weInfoDic objectForKey:@"daily_forecast"][2] objectForKey:@"cond"] objectForKey:@"txt_d"];
        NSString *txt_nn=[[[weInfoDic objectForKey:@"daily_forecast"][2] objectForKey:@"cond"] objectForKey:@"txt_n"];
        NSString *txt_alll;
        if ([txt_dd isEqualToString:txt_nn]) {
            txt_alll=txt_dd;
        }else{
            txt_alll=[NSString stringWithFormat:@"%@转%@",txt_dd,txt_nn];
        }
        labelCaTomoo.text=txt_alll;
        [cell.contentView addSubview:labelCaTomoo];
        
        UILabel *labelCaTomooo=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/3)*2, 115, self.view.frame.size.width/3, 30)];
        labelCaTomooo.textAlignment=NSTextAlignmentCenter;
        labelCaTomooo.textColor=[UIColor whiteColor];
        NSString *txt_ddd=[[[weInfoDic objectForKey:@"daily_forecast"][3] objectForKey:@"cond"] objectForKey:@"txt_d"];
        NSString *txt_nnn=[[[weInfoDic objectForKey:@"daily_forecast"][3] objectForKey:@"cond"] objectForKey:@"txt_n"];
        NSString *txt_allll;
        if ([txt_ddd isEqualToString:txt_nnn]) {
            txt_allll=txt_ddd;
        }else{
            txt_allll=[NSString stringWithFormat:@"%@转%@",txt_ddd,txt_nnn];
        }
        labelCaTomooo.text=txt_allll;
        [cell.contentView addSubview:labelCaTomooo];
        
    }else if (indexPath.row==3){
        
        UILabel *lineLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
        lineLabel.backgroundColor=[UIColor whiteColor];
        [cell.contentView addSubview:lineLabel];
        
        for (int i=0; i<[[weInfoDic objectForKey:@"hourly_forecast"] count]; i++) {
            UILabel *labelTime=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/[[weInfoDic objectForKey:@"hourly_forecast"] count])*i, 5, self.view.frame.size.width/[[weInfoDic objectForKey:@"hourly_forecast"] count], 30)];
            labelTime.textAlignment=NSTextAlignmentCenter;
            labelTime.textColor=[UIColor whiteColor];
            labelTime.font=[UIFont systemFontOfSize:15.0f];
            NSString *strTime=[[[weInfoDic objectForKey:@"hourly_forecast"][i] objectForKey:@"date"] substringFromIndex:11];
            NSString *strTimee=[strTime substringToIndex:2];
            NSString *strTimeFinal=[NSString stringWithFormat:@"%@时",strTimee];
            labelTime.text=strTimeFinal;
            [cell.contentView addSubview:labelTime];
            
            UILabel *popLabel=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/[[weInfoDic objectForKey:@"hourly_forecast"] count])*i, 35, self.view.frame.size.width/[[weInfoDic objectForKey:@"hourly_forecast"] count], 30)];
            popLabel.textAlignment=NSTextAlignmentCenter;
            popLabel.textColor=[UIColor whiteColor];
            popLabel.font=[UIFont systemFontOfSize:15.0f];
            NSString *popStr=[[weInfoDic objectForKey:@"hourly_forecast"][i] objectForKey:@"pop"];
            NSString *percent=@"%";
            popLabel.text=[NSString stringWithFormat:@"%@%@",popStr,percent];
            [cell.contentView addSubview:popLabel];
            
            UILabel *labelTmp=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/[[weInfoDic objectForKey:@"hourly_forecast"] count])*i, 65, self.view.frame.size.width/[[weInfoDic objectForKey:@"hourly_forecast"] count], 30)];
            labelTmp.textAlignment=NSTextAlignmentCenter;
            labelTmp.textColor=[UIColor whiteColor];
            labelTmp.font=[UIFont systemFontOfSize:15.0f];
            NSString *strTmp=[[weInfoDic objectForKey:@"hourly_forecast"][i] objectForKey:@"tmp"];
            labelTmp.text=[NSString stringWithFormat:@"%@℃",strTmp];
            [cell.contentView addSubview:labelTmp];
        }
    }else if (indexPath.row==4){
        cell.contentView.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        
        UILabel *lineLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
        lineLabel.backgroundColor=[UIColor whiteColor];
        [cell.contentView addSubview:lineLabel];
        
        NSMutableArray *TMP_MAX_ARR=[[NSMutableArray alloc]init];
        NSMutableArray *TMP_MIN_ARR=[[NSMutableArray alloc]init];
        for (int i=0; i<6; i++) {
            
            UILabel *labelTime=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/6)*i, 10, self.view.frame.size.width/6, 30)];
            labelTime.textAlignment=NSTextAlignmentCenter;
            labelTime.textColor=[UIColor whiteColor];
            //labelTime.font=[UIFont systemFontOfSize:15.0f];
            NSString *strTime=[[[weInfoDic objectForKey:@"daily_forecast"][i] objectForKey:@"date"] substringFromIndex:5];
            NSString *strTimee=[strTime substringToIndex:5];
            NSString *strTimeFinal=[NSString stringWithFormat:@"%@",strTimee];
            labelTime.text=strTimeFinal;
            [cell.contentView addSubview:labelTime];
            
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0]stringByAppendingPathComponent:@"weatherCategoryInfo.plist"];
            UIImageView *cellImageView_d=[[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width/12)*(i*2+1)-15, 40, 30, 30)];
            UIImageView *cellImageView_n=[[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width/12)*(i*2+1)-15, 330, 30, 30)];
            NSString *categoryCode_d=[[[weInfoDic objectForKey:@"daily_forecast"][i] objectForKey:@"cond"] objectForKey:@"code_d"];
            NSString *categoryCode_n=[[[weInfoDic objectForKey:@"daily_forecast"][i] objectForKey:@"cond"] objectForKey:@"code_n"];
            NSArray *plistArray=[NSArray arrayWithContentsOfFile:path];
            for (NSDictionary *dict in plistArray) {
                if ([[dict objectForKey:@"code"] isEqualToString:categoryCode_d]) {
                    [cellImageView_d sd_setImageWithURL:[dict objectForKey:@"icon"]];
                    [cell.contentView addSubview:cellImageView_d];
                }
                if ([[dict objectForKey:@"code"] isEqualToString:categoryCode_n]) {
                    [cellImageView_n sd_setImageWithURL:[dict objectForKey:@"icon"]];
                    [cell.contentView addSubview:cellImageView_n];
                }
            }
            
            UILabel *labelCa_d=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/6)*i, 70, self.view.frame.size.width/6, 30)];
            UILabel *labelCa_n=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/6)*i, 300, self.view.frame.size.width/6, 30)];
            labelCa_d.textAlignment=NSTextAlignmentCenter;
            labelCa_d.textColor=[UIColor whiteColor];
            labelCa_n.textAlignment=NSTextAlignmentCenter;
            labelCa_n.textColor=[UIColor whiteColor];
            labelCa_d.font=[UIFont systemFontOfSize:15];
            labelCa_n.font=[UIFont systemFontOfSize:15];
            NSString *txt_d=[[[weInfoDic objectForKey:@"daily_forecast"][i] objectForKey:@"cond"] objectForKey:@"txt_d"];
            NSString *txt_n=[[[weInfoDic objectForKey:@"daily_forecast"][i] objectForKey:@"cond"] objectForKey:@"txt_n"];
            labelCa_d.text=txt_d;
            labelCa_n.text=txt_n;
            [cell.contentView addSubview:labelCa_d];
            [cell.contentView addSubview:labelCa_n];
            
            UILabel *labelWind=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/6)*i, 360, self.view.frame.size.width/6, 30)];
            labelWind.textAlignment=NSTextAlignmentCenter;
            labelWind.textColor=[UIColor whiteColor];
            //labelTime.font=[UIFont systemFontOfSize:15.0f];
            NSString *strWind=[[[weInfoDic objectForKey:@"daily_forecast"][i] objectForKey:@"wind"] objectForKey:@"dir"];
            if ([strWind isEqualToString:@"无持续风向"]) {
                strWind=@"无常风";
            }
            labelWind.text=strWind;
            [cell.contentView addSubview:labelWind];
            
            UILabel *labelWindSc=[[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width/6)*i, 390, self.view.frame.size.width/6, 15)];
            labelWindSc.textAlignment=NSTextAlignmentCenter;
            labelWindSc.textColor=[UIColor whiteColor];
            labelWindSc.font=[UIFont systemFontOfSize:12.0f];
            NSString *strWindSc=[[[weInfoDic objectForKey:@"daily_forecast"][i] objectForKey:@"wind"] objectForKey:@"sc"];
            labelWindSc.text=[NSString stringWithFormat:@"%@级",strWindSc];
            [cell.contentView addSubview:labelWindSc];
            
            NSString *strTmp_max=[[[weInfoDic objectForKey:@"daily_forecast"][i] objectForKey:@"tmp"] objectForKey:@"max"] ;
            NSString *strTmp_min=[[[weInfoDic objectForKey:@"daily_forecast"][i] objectForKey:@"tmp"] objectForKey:@"min"] ;
            
            [TMP_MAX_ARR addObject:strTmp_max];
            [TMP_MIN_ARR addObject:strTmp_min];
        }
        NSString *tmp_max=TMP_MAX_ARR[0];
        NSString *tmp_min=TMP_MIN_ARR[0];

        for (int i=1; i<TMP_MAX_ARR.count; i++) {
            if ([TMP_MAX_ARR[i] intValue]>[tmp_max intValue]) {
                tmp_max=TMP_MAX_ARR[i];
            }
        }
        for (int i=1; i<TMP_MIN_ARR.count; i++) {
            if ([TMP_MIN_ARR[i] intValue]<[tmp_min intValue]) {
                tmp_min=TMP_MIN_ARR[i];
            }
        }
        
        
        PNLineChart *lineChart=[[PNLineChart alloc]initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, 200)];
        lineChart.yLabelColor=[UIColor whiteColor];
        [lineChart setXLabels:@[@" ",@" ",@" ",@" ",@" ",@" "]];
        lineChart.axisColor=[UIColor whiteColor];
        NSArray * data01Array =TMP_MAX_ARR;
        PNLineChartData *data01 = [PNLineChartData new];
        data01.color = PNFreshGreen;
        data01.itemCount = lineChart.xLabels.count;
        data01.getData = ^(NSUInteger index) {
            CGFloat yValue = [data01Array[index] floatValue];
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        // Line Chart No.2
        NSArray * data02Array = TMP_MIN_ARR;
        PNLineChartData *data02 = [PNLineChartData new];
        data02.color = PNTwitterColor;
        data02.itemCount = lineChart.xLabels.count;
        data02.getData = ^(NSUInteger index) {
            CGFloat yValue = [data02Array[index] floatValue];
            return [PNLineChartDataItem dataItemWithY:yValue];
        };
        lineChart.chartData = @[data01, data02];
        [lineChart strokeChart];
        lineChart.backgroundColor=[UIColor clearColor];
        [cell.contentView addSubview:lineChart];
        
    }else if (indexPath.row==5){
//        UILabel *lineLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
//        lineLabel.backgroundColor=[UIColor whiteColor];
//        [cell.contentView addSubview:lineLabel];
        
        //
        
        UILabel *labelTitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 1, self.view.frame.size.width, 28)];
        labelTitle.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        labelTitle.textColor=[UIColor whiteColor];
        labelTitle.font=[UIFont systemFontOfSize:15];
        labelTitle.text=@"  生活指数";
        [cell.contentView addSubview:labelTitle];
        
        //
        
        UILabel *labelStatu=[[UILabel alloc]initWithFrame:CGRectMake(1, 30, self.view.frame.size.width/2-1, 45)];
        labelStatu.textColor=[UIColor whiteColor];
        labelStatu.font=[UIFont systemFontOfSize:25];
        labelStatu.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        labelStatu.textAlignment=NSTextAlignmentCenter;
        labelStatu.text=[NSString stringWithFormat:@"%@",[[[weInfoDic objectForKey:@"suggestion"] objectForKey:@"comf"] objectForKey:@"brf"]];
        [cell.contentView addSubview:labelStatu];
        
        UILabel *labelStatuu=[[UILabel alloc]initWithFrame:CGRectMake(1, 75, self.view.frame.size.width/2-1, 44)];
        labelStatuu.textAlignment=NSTextAlignmentCenter;
        labelStatuu.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        labelStatuu.textColor=[UIColor whiteColor];
        labelStatuu.font=[UIFont systemFontOfSize:15];
        labelStatuu.text=@"天气状况";
        [cell.contentView addSubview:labelStatuu];
        
        UIButton *buttonStatu=[UIButton buttonWithType:UIButtonTypeCustom];
        buttonStatu.frame=CGRectMake(0, 30, self.view.frame.size.width/2-1, 89);
        //buttonStatu.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [buttonStatu setTitle:@" " forState:UIControlStateNormal];
        [buttonStatu addTarget:self action:@selector(buttonStatuClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:buttonStatu];
        
        //
        
        UILabel *labelWashCar=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2+1, 30, self.view.frame.size.width/2-2, 45)];
        labelWashCar.textColor=[UIColor whiteColor];
        labelWashCar.font=[UIFont systemFontOfSize:25];
        labelWashCar.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        labelWashCar.textAlignment=NSTextAlignmentCenter;
        labelWashCar.text=[NSString stringWithFormat:@"%@",[[[weInfoDic objectForKey:@"suggestion"] objectForKey:@"cw"] objectForKey:@"brf"]];
        [cell.contentView addSubview:labelWashCar];
        
        UILabel *labelWashCarr=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2+1, 75, self.view.frame.size.width/2-2, 44)];
        labelWashCarr.textAlignment=NSTextAlignmentCenter;
        labelWashCarr.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        labelWashCarr.textColor=[UIColor whiteColor];
        labelWashCarr.font=[UIFont systemFontOfSize:15];
        labelWashCarr.text=@"洗车建议";
        [cell.contentView addSubview:labelWashCarr];
        
        UIButton *buttonWashCar=[UIButton buttonWithType:UIButtonTypeCustom];
        buttonWashCar.frame=CGRectMake(self.view.frame.size.width/2, 30, self.view.frame.size.width/2, 89);
        //buttonWashCar.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [buttonWashCar setTitle:@" " forState:UIControlStateNormal];
        [buttonWashCar addTarget:self action:@selector(buttonStatuClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:buttonWashCar];
        
        //
        
        UILabel *labelSport=[[UILabel alloc]initWithFrame:CGRectMake(1, 120, self.view.frame.size.width/2-1, 45)];
        labelSport.textColor=[UIColor whiteColor];
        labelSport.font=[UIFont systemFontOfSize:25];
        labelSport.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        labelSport.textAlignment=NSTextAlignmentCenter;
        labelSport.text=[NSString stringWithFormat:@"%@",[[[weInfoDic objectForKey:@"suggestion"] objectForKey:@"sport"] objectForKey:@"brf"]];
        [cell.contentView addSubview:labelSport];
        
        UILabel *labelSportt=[[UILabel alloc]initWithFrame:CGRectMake(1, 165, self.view.frame.size.width/2-1, 44)];
        labelSportt.textAlignment=NSTextAlignmentCenter;
        labelSportt.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        labelSportt.textColor=[UIColor whiteColor];
        labelSportt.font=[UIFont systemFontOfSize:15];
        labelSportt.text=@"运动建议";
        [cell.contentView addSubview:labelSportt];
        
        UIButton *buttonSport=[UIButton buttonWithType:UIButtonTypeCustom];
        buttonSport.frame=CGRectMake(0, 120, self.view.frame.size.width/2-1, 89);
        //buttonSport.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [buttonSport setTitle:@" " forState:UIControlStateNormal];
        [buttonSport addTarget:self action:@selector(buttonStatuClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:buttonSport];
        
        //
        
        UILabel *labelFlu=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2+1, 120, self.view.frame.size.width/2-2, 45)];
        labelFlu.textColor=[UIColor whiteColor];
        labelFlu.font=[UIFont systemFontOfSize:25];
        labelFlu.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        labelFlu.textAlignment=NSTextAlignmentCenter;
        labelFlu.text=[NSString stringWithFormat:@"%@",[[[weInfoDic objectForKey:@"suggestion"] objectForKey:@"flu"] objectForKey:@"brf"]];
        [cell.contentView addSubview:labelFlu];
        
        UILabel *labelFluu=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2+1, 165, self.view.frame.size.width/2-2, 44)];
        labelFluu.textAlignment=NSTextAlignmentCenter;
        labelFluu.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        labelFluu.textColor=[UIColor whiteColor];
        labelFluu.font=[UIFont systemFontOfSize:15];
        labelFluu.text=@"感冒指数";
        [cell.contentView addSubview:labelFluu];
        
        UIButton *buttonFlu=[UIButton buttonWithType:UIButtonTypeCustom];
        buttonFlu.frame=CGRectMake(self.view.frame.size.width/2, 120, self.view.frame.size.width/2, 89);
        //buttonFlu.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [buttonFlu setTitle:@" " forState:UIControlStateNormal];
        [buttonFlu addTarget:self action:@selector(buttonStatuClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:buttonFlu];
        
        //
        
        UILabel *labeltrav=[[UILabel alloc]initWithFrame:CGRectMake(1, 210, self.view.frame.size.width/2-1, 45)];
        labeltrav.textColor=[UIColor whiteColor];
        labeltrav.font=[UIFont systemFontOfSize:25];
        labeltrav.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        labeltrav.textAlignment=NSTextAlignmentCenter;
        labeltrav.text=[NSString stringWithFormat:@"%@",[[[weInfoDic objectForKey:@"suggestion"] objectForKey:@"trav"] objectForKey:@"brf"]];
        [cell.contentView addSubview:labeltrav];
        
        UILabel *labeltravv=[[UILabel alloc]initWithFrame:CGRectMake(1, 255, self.view.frame.size.width/2-1, 44)];
        labeltravv.textAlignment=NSTextAlignmentCenter;
        labeltravv.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        labeltravv.textColor=[UIColor whiteColor];
        labeltravv.font=[UIFont systemFontOfSize:15];
        labeltravv.text=@"旅游指数";
        [cell.contentView addSubview:labeltravv];
        
        UIButton *buttontrav=[UIButton buttonWithType:UIButtonTypeCustom];
        buttontrav.frame=CGRectMake(0, 210, self.view.frame.size.width/2-1, 89);
        //buttontrav.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [buttontrav setTitle:@" " forState:UIControlStateNormal];
        [buttontrav addTarget:self action:@selector(buttonStatuClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:buttontrav];
        
        //
        
        UILabel *labelUv=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2+1, 210, self.view.frame.size.width/2-2, 45)];
        labelUv.textColor=[UIColor whiteColor];
        labelUv.font=[UIFont systemFontOfSize:25];
        labelUv.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        labelUv.textAlignment=NSTextAlignmentCenter;
        labelUv.text=[NSString stringWithFormat:@"%@",[[[weInfoDic objectForKey:@"suggestion"] objectForKey:@"uv"] objectForKey:@"brf"]];
        [cell.contentView addSubview:labelUv];
        
        UILabel *labelUvv=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2+1, 255, self.view.frame.size.width/2-2, 44)];
        labelUvv.textAlignment=NSTextAlignmentCenter;
        labelUvv.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        labelUvv.textColor=[UIColor whiteColor];
        labelUvv.font=[UIFont systemFontOfSize:15];
        labelUvv.text=@"紫外线指数";
        [cell.contentView addSubview:labelUvv];
        
        UIButton *buttonUv=[UIButton buttonWithType:UIButtonTypeCustom];
        buttonUv.frame=CGRectMake(self.view.frame.size.width/2, 210, self.view.frame.size.width/2-1, 89);
        //buttonUv.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [buttonUv setTitle:@" " forState:UIControlStateNormal];
        [buttonUv addTarget:self action:@selector(buttonStatuClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:buttonUv];
    }else{
        cell.textLabel.text=@"ssss";
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 250;
    }else if (indexPath.row==1){
        return self.view.frame.size.height-400;
    }else if (indexPath.row==2){
        return 150;
    }else if (indexPath.row==3){
        return 100;
    }else if (indexPath.row==4){
        return 415;
    }else if (indexPath.row==5){
        return 300;
    }else{
        return 40;
    }
}
-(void)buttonStatuClick:(UIButton *)sender{
    NSLog(@"statuButtonClick:%@",sender);
}

@end
