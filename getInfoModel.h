//
//  getInfoModel.h
//  WeatherApp
//
//  Created by GMH on 5/4/16.
//  Copyright © 2016 com.zy.weather. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface getInfoModel : NSObject


-(void)getWeInfo:(NSString *)requestUrl;
-(void)getHotCityInfo:(NSString *)requestUrl;
-(void)getweatherCategoryInfo:(NSString *)requestUrl;
@end
