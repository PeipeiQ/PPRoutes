//
//  ViewController.m
//  Router
//
//  Created by peipei on 2018/4/4.
//  Copyright © 2018年 peipei. All rights reserved.
//

#import "ViewController.h"
#import "FirstViewController.h"
#import "ButtonView.h"



@interface ViewController ()<UIScrollViewDelegate>
@property(nonatomic,strong) NSString *name;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self routerDemo];
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self labelTest];
}

-(void)labelTest{
    NSArray *arr = @[@"aghfggkjdhghjhkjhkdlkfc",@"akdfsdfsdklk",@"asdhaksdjh",@"skajfjksdfhjdfhksdjfh",@"你好",@"00000123",@"啊啊啊啊",@"啊",@"啊",@"sajfskfhskfdjs",@"%$^%&*%^&"];
    ButtonView *bView = [[ButtonView alloc]initWithFrame:CGRectMake(0, 64, 375, 500) contentArray:arr fontSize:17 options:AutoAdjustHeightAndWidthStyle sizeBlock:^(CGSize newSize) {
        [bView reloadLabelView];
    }];
    bView.edge = 20;
    bView.space = 8;
    [self.view addSubview:bView];
}
-(void)tap:(UITapGestureRecognizer*)sender{
    NSLog(@"aaa");
}

-(void)routerDemo{
    NSMutableArray *btnArr = [NSMutableArray array];
    for (int i=0; i<3; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(120, 150+50*i, 100, 30)];
        [btn setTitle:[NSString stringWithFormat:@"btn:%d",i] forState:0];
        btn.backgroundColor = [UIColor redColor];
        btn.tag = i;
        [btn addTarget:self action:@selector(tapBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btnArr setObject:btn atIndexedSubscript:i];
        [self.view addSubview:btn];
    }
}

-(void)tapBtn:(UIButton*)sender{
    NSString *urlStr;
    switch (sender.tag) {
        case 0:urlStr=@"RouterOne://first/FirstViewController?userID=aaaa";break;
        case 1:urlStr=@"RouterOne://first/SecondViewController?userID=aaaa";break;
        case 2:urlStr=@"RouterOne://first/ThirdViewController?userID=aaaa";break;
        default:break;
    }
    NSURL *url = [NSURL URLWithString:urlStr];
    [[UIApplication sharedApplication] openURL:url options:nil completionHandler:nil];
}

-(void)demo1{
    
    //反射机制（发生在运行时）
    //获取class
    Class class1 = NSClassFromString(@"ViewController");
    Class class2 = NSClassFromString(@"SecondViewController");
    NSLog(@"%@", class1);
    NSLog(@"%@", class2);
    NSString *classStr1 = NSStringFromClass([self class]);
    NSString *classStr2 = NSStringFromClass(class2);
    NSLog(@"%@", classStr1);
    NSLog(@"%@", classStr2);
    
    //获取sel
    NSString *selStr = NSStringFromSelector(@selector(firstPageMethod));
    NSLog(@"%@",selStr);
    SEL firstSEL = NSSelectorFromString(@"secondPageMethod");
    [class2 performSelector:firstSEL];
    /*
     FOUNDATION_EXPORT NSString *NSStringFromSelector(SEL aSelector);
     FOUNDATION_EXPORT SEL NSSelectorFromString(NSString *aSelectorName);
     
     FOUNDATION_EXPORT NSString *NSStringFromClass(Class aClass);
     FOUNDATION_EXPORT Class _Nullable NSClassFromString(NSString *aClassName);
     
     FOUNDATION_EXPORT NSString *NSStringFromProtocol(Protocol *proto) API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
     FOUNDATION_EXPORT Protocol * _Nullable NSProtocolFromString(NSString *namestr) API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
     */
    
    //获取属性
    [self setValue:@"peipei" forKey:@"name"];
    NSString *str = [self valueForKey:@"name"];
    NSLog(@"%@",str);
    
    /*
     // 当前对象是否这个类或其子类的实例
     - (BOOL)isKindOfClass:(Class)aClass;
     // 当前对象是否是这个类的实例
     - (BOOL)isMemberOfClass:(Class)aClass;
     // 当前对象是否遵守这个协议
     - (BOOL)conformsToProtocol:(Protocol *)aProtocol;
     // 当前对象是否实现这个方法
     - (BOOL)respondsToSelector:(SEL)aSelector;
     */
    
    //
    
}



@end
