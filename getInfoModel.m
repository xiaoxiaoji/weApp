//
//  getInfoModel.m
//  WeatherApp
//
//  Created by GMH on 5/4/16.
//  Copyright © 2016 com.zy.weather. All rights reserved.
//

#import "getInfoModel.h"
#import <CoreLocation/CoreLocation.h>
#import <AFNetworking.h>
@implementation getInfoModel

-(void)getWeInfo:(NSString *)requestUrl{
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    [manager GET:requestUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"succeed :%@",responseObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getWeInfo" object:self userInfo:@{@"InfoFromAPI":responseObject}];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error :%@",error);
    }];
}
-(void)getHotCityInfo:(NSString *)requestUrl{
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    [manager GET:requestUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"succeed :%@",responseObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getCityInfo" object:self userInfo:@{@"InfoFromAPI":responseObject}];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error :%@",error);
    }];
}
-(void)getweatherCategoryInfo:(NSString *)requestUrl{
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    [manager GET:requestUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"succeed :%@",responseObject);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getweatherCategoryInfo" object:self userInfo:@{@"InfoFromAPI":responseObject}];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error :%@",error);
    }];
}
@end
