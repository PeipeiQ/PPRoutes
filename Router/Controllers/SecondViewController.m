//
//  SecondViewController.m
//  Router
//
//  Created by peipei on 2018/4/4.
//  Copyright © 2018年 peipei. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()
@property(nonatomic,strong) NSString *name;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    self.name = @"second+++++";
}

+(void)secondPageMethod{
    NSLog(@"%@--%s",[self class],__func__);
}

@end
