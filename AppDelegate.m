//
//  AppDelegate.m
//  WeatherApp
//
//  Created by GMH on 5/4/16.
//  Copyright © 2016 com.zy.weather. All rights reserved.
//

#import "AppDelegate.h"
#import "mainViewController.h"
#import "navViewController.h"
#import "menuNavViewController.h"
#import "leftTableViewController.h"
#import <ViewDeck.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];  
    mainViewController *mainView=[[mainViewController alloc]init];
    navViewController *navView=[[navViewController alloc]initWithRootViewController:mainView];
    leftTableViewController *leftView=[[leftTableViewController alloc]initWithStyle:UITableViewStylePlain];
    menuNavViewController *menuNav=[[menuNavViewController alloc]initWithRootViewController:leftView];
   // menuNav.navigationBar.frame=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-40, navView.navigationBar.frame.size.height);
    IIViewDeckController *viewDeck=[[IIViewDeckController alloc]initWithCenterViewController:navView leftViewController:menuNav];
    
    [self.window setRootViewController:viewDeck];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
