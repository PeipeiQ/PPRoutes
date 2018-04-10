//
//  AppDelegate.m
//  Router
//
//  Created by peipei on 2018/4/4.
//  Copyright © 2018年 peipei. All rights reserved.
//

#import "AppDelegate.h"
#import <JLRoutes.h>
#import <objc/runtime.h>
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[[ViewController alloc]init]];
    [self.window makeKeyWindow];
    
    //JLRoutes *routes = [JLRoutes globalRoutes];
    JLRoutes *routes = [JLRoutes routesForScheme:@"pp"];
    [routes addRoute:@"/first/:controller" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        
        UIViewController *currentVC = [self getCurrentVC];
        UIViewController *vc = [[NSClassFromString(parameters[@"controller"]) alloc]init];
        [self passVC:vc withParameters:parameters];
        [currentVC.navigationController pushViewController:vc animated:YES];
        return YES;
    }];
    [routes addRoute:@"/second" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        return NO;
    }];
    //NSLog(@"%@", [JLRoutes allRoutes]);
    return YES;
}

//通过runtime的方法传递参数
-(void)passVC:(UIViewController*)vc withParameters:(NSDictionary*)parameters{
    unsigned int count;
    objc_property_t *pro = class_copyPropertyList([vc class], &count);
    for (unsigned int i=0; i<count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(pro[i])];
        NSString *value = parameters[key];
        if (value) {
            [vc setValue:value forKey:key];
        }
    }
}

//获取当前vc
-(UIViewController *)getCurrentVC{
    UIViewController * currVC = nil;
    UIViewController * Rootvc = self.window.rootViewController ;
    do {
        if ([Rootvc isKindOfClass:[UINavigationController class]]) {
            UINavigationController * nav = (UINavigationController *)Rootvc;
            UIViewController * v = [nav.viewControllers lastObject];
            currVC = v;
            Rootvc = v.presentedViewController;
            continue;
        }else if([Rootvc isKindOfClass:[UITabBarController class]]){
            UITabBarController * tabVC = (UITabBarController *)Rootvc;
            currVC = tabVC;
            Rootvc = [tabVC.viewControllers objectAtIndex:tabVC.selectedIndex];
            continue;
        }
    } while (Rootvc!=nil);
    
    return currVC;
}

-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    [[JLRoutes routesForScheme:@"pp"] routeURL:url];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
