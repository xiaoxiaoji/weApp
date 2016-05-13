//
//  mainViewController.m
//  WeatherApp
//
//  Created by GMH on 5/7/16.
//  Copyright © 2016 com.zy.weather. All rights reserved.
//

#import "mainViewController.h"
#import "weInfoTableViewController.h"
#import "getInfoModel.h"
#import "UIImageView+WebCache.h"
#import <ViewDeck.h>
@interface mainViewController ()<UIScrollViewDelegate,IIViewDeckControllerDelegate>
@property(nonatomic) NSString *cityName;
@property(nonatomic) UIScrollView *scrollView;
@property(nonatomic) UIPageControl *pageControl;
@property(nonatomic) getInfoModel *model;
@property(nonatomic) UIImageView *backImageView;
@property(nonatomic) UILabel *titleLabel;
@end

@implementation mainViewController

- (void)viewDidLoad {
    
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc]init]];
    self.viewDeckController.delegate =self;
    self.pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-140, 25, 280, 30)];
    [super viewDidLoad];
    [self backImage];
    [self addNav];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddCity:) name:@"AddCityToMain" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedFromMenu:) name:@"select" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWeatherInfo:) name:@"getWeatherInfoToMain" object:nil];


}
-(void)getWeatherInfo:(NSNotification *)notification{
    self.scrollView.hidden=YES;
    self.scrollView=nil;
    self.cityNameArr=notification.userInfo[@"cityARR"];
    self.WEATHER_INFO_ARR=notification.userInfo[@"weatherInfoArr"];
    self.pageControl.numberOfPages=self.cityNameArr.count;
    self.pageControl.currentPage=0;
    self.titleLabel.text=self.cityNameArr[0];
    [self addScrollView];
    [self scrollViewAddTableView];
    
}
-(void)selectedFromMenu:(NSNotification *)notification{
    int index=[notification.userInfo[@"indexPath"] intValue];
    self.pageControl.currentPage=index;
    self.scrollView.contentOffset=CGPointMake(index*self.view.frame.size.width, 0);
}
-(void)AddCity:(NSNotification *)notification{
    self.cityNameArr=notification.userInfo[@"cityNameArr"];
    self.WEATHER_INFO_ARR=notification.userInfo[@"WEATHER_INFO_ARR"];
    self.scrollView.contentSize=CGSizeMake(self.view.frame.size.width*self.cityNameArr.count, self.view.frame.size.height);
    weInfoTableViewController *weInfoView=[[weInfoTableViewController alloc]initWithStyle:UITableViewStylePlain];
    weInfoView.WE_INFO_ARR=[[NSMutableArray alloc]init];
    weInfoView.WE_INFO_ARR=[self.WEATHER_INFO_ARR lastObject];
    weInfoView.tableView.frame=CGRectMake(self.view.frame.size.width*(self.cityNameArr.count-1), 0, self.view.frame.size.width, self.view.frame.size.height);
    // weInfoView.tableView.alpha=0.1;
    [self addChildViewController:weInfoView];
    [self.scrollView addSubview:weInfoView.tableView];
    self.pageControl.numberOfPages=self.cityNameArr.count;
    self.scrollView.contentOffset=CGPointMake(self.view.frame.size.width*(self.cityNameArr.count-1), 0);
    self.pageControl.currentPage=self.cityNameArr.count;
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"AddCityToMain" object:nil];
}
-(void)addNav{
    UIBarButtonItem *shareItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareItemClick)];
    UIBarButtonItem *menuItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(menuItemClick)];
    [shareItem setTintColor:[UIColor whiteColor]];
    [menuItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItems=@[menuItem];
    self.navigationItem.rightBarButtonItems=@[shareItem];
    [self.navigationController.navigationBar addSubview:self.pageControl];
    
    self.titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-140, 5, 280, 30)];
    self.titleLabel.textColor=[UIColor whiteColor];
    self.titleLabel.textAlignment=NSTextAlignmentCenter;
    //self.titleLabel.backgroundColor=[UIColor orangeColor];
    [self.navigationController.navigationBar addSubview:self.titleLabel];
    
}
-(void)shareItemClick{
    NSLog(@"shareItemClick");
}
-(void)menuItemClick{
    [self showMainMenuView];
}
//-(void)loadTables:(NSNotification *)notification{
//    self.cityNameArr=notification.userInfo[@"cityARR"];
//    self.WEATHER_INFO_ARR=notification.userInfo[@"WEATHER_INFO_ARR"];
//    self.titleLabel.text=self.cityNameArr[0];
//    if ([self.view.subviews lastObject]!=nil) {
//        [self.scrollView removeFromSuperview];
//    }
//    [self addScrollView];
//    [self scrollViewAddTableView];
//}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollView.contentOffset.x < 0)
    {
        self.scrollView.scrollEnabled=NO;
        [self showMainMenuView];
    }
    self.scrollView.scrollEnabled=YES;
    for (int i=0; i<self.cityNameArr.count; i++) {
        if (self.scrollView.contentOffset.x==i*self.view.frame.size.width) {
            int width=self.view.frame.size.width;
            int height=self.view.frame.size.height;
            [self.backImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://lorempixel.com/%d/%d/abstract",width,height]]];
    //self.backImageView.image=[UIImage imageNamed:@"splash"];
            self.selectViewIndex=i;
            self.titleLabel.text=self.cityNameArr[i];
            self.pageControl.currentPage=i;
        }
    }
}

- (void)showMainMenuView
{
    //self.scrollView.scrollEnabled =NO;
    [self.viewDeckController toggleLeftView];
}

- (void)viewDeckController:(IIViewDeckController*)viewDeckController willCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated
{
    self.scrollView.scrollEnabled =YES;
}
-(void)backImage{
    self.backImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.backImageView.image=[UIImage imageNamed:@"splash"];
    int width=self.view.frame.size.width;
    int height=self.view.frame.size.height;
    [self.backImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://lorempixel.com/%d/%d/abstract",width,height]]];
    [self.view addSubview:self.backImageView];
}
-(void)addScrollView{
    self.scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.hidden=NO;
    self.scrollView.delegate=self;
    self.scrollView.pagingEnabled=YES;
    self.scrollView.contentSize=CGSizeMake(self.view.frame.size.width*self.cityNameArr.count, self.view.frame.size.height);
    [self.scrollView flashScrollIndicators];
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.bounces=YES;
    self.scrollView.showsHorizontalScrollIndicator=YES;
    [self.view addSubview:self.scrollView];
}
-(void)scrollViewAddTableView{
    if (self.WEATHER_INFO_ARR.count==self.cityNameArr.count) {
    for (int i=0; i<self.cityNameArr.count; i++) {
        weInfoTableViewController *weInfoView=[[weInfoTableViewController alloc]initWithStyle:UITableViewStylePlain];
        weInfoView.WE_INFO_ARR=[[NSMutableArray alloc]init];
        weInfoView.WE_INFO_ARR=self.WEATHER_INFO_ARR[i];
        weInfoView.tableView.frame=CGRectMake(self.view.frame.size.width*i, 0, self.view.frame.size.width, self.view.frame.size.height);
        [self addChildViewController:weInfoView];
        [self.scrollView addSubview:weInfoView.tableView];
        self.pageControl.numberOfPages=self.cityNameArr.count;
        }
    }
}
@end
