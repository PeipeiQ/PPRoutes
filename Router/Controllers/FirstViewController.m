//
//  FirstViewController.m
//  Router
//
//  Created by peipei on 2018/4/4.
//  Copyright © 2018年 peipei. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()
@property(nonatomic,strong)NSString *userID;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *age;
@property(nonatomic,strong)NSString *sex;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
}

-(void)firstPageMethod{
    NSLog(@"%@--%s",[self class],__func__);
}



@end
