//
//  mainViewController.h
//  WeatherApp
//
//  Created by GMH on 5/7/16.
//  Copyright © 2016 com.zy.weather. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface mainViewController : UIViewController
@property(nonatomic) NSMutableArray *cityNameArr;
@property(nonatomic) NSMutableArray *viewArr;
@property(nonatomic) NSMutableArray *WEATHER_INFO_ARR;
@property(nonatomic) int selectViewIndex;
@end
