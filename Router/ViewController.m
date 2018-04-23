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
#import <SDWebImage/UIImageView+WebCache.h>
#import "PPOperation.h"

@interface ViewController ()<UIScrollViewDelegate,ButtonViewDelegate>
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) ButtonView *bView;
@property(nonatomic,strong) NSCache *cache;
@property(nonatomic,strong) NSOperation *operation;
@property(nonatomic,strong) NSOperationQueue *operationQueue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self routerDemo];
    self.view.backgroundColor = [UIColor lightGrayColor];
    //[self labelTest];
    //[self cacheDemo];
    //[self sdDemo];
    [self operationDemo];

}

//operation探索(多线程)
-(void)operationDemo{
//如果没有加入新队列，任务在当前线程同步执行
    //    NSInvocationOperation *op = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(operationTap) object:nil];
    //    _operation = op;
    //    _operationQueue = [[NSOperationQueue alloc]init];
    //    //_operationQueue = queue;
    ////    [op main];
//串行队列和并行队列
    //    _operationQueue.maxConcurrentOperationCount = 2;
    //    [_operationQueue addOperation:op];
    //    [_operationQueue addOperationWithBlock:^{
    //        NSLog(@"inblock%@",[NSThread currentThread]);
    //    }];
    //    NSLog(@"aaaaa");
    
//实现一个自己的operation
//    PPOperation *op = [[PPOperation alloc]initWithTarget:self action:@selector(operationTap)];
//    _operation = op;
//    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
//    [queue addOperation:op];
//    //[op start];
    
//知识点补充
    /*
     dispatch_barrier_sync(queue,void(^block)())会将queue中barrier前面添加的任务block全部执行后,再执行barrier任务的block,再执行barrier后面添加的任务block.
     
     dispatch_barrier_async(queue,void(^block)())会将queue中barrier前面添加的任务block只添加不执行,继续添加barrier的block,再添加barrier后面的block,同时不影响主线程(或者操作添加任务的线程)中代码的执行!
     */
    dispatch_queue_t queue = dispatch_queue_create("thread", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t queue2 = dispatch_queue_create("thread", DISPATCH_QUEUE_SERIAL);

//    dispatch_async(queue, ^{
//        //[NSThread sleepForTimeInterval:2];
//        NSLog(@"1____%@",[NSThread currentThread]);
//    });
//    dispatch_async(queue, ^{
//        NSLog(@"2____%@",[NSThread currentThread]);
//    });
//    dispatch_async(queue, ^{
//        //[NSThread sleepForTimeInterval:0.5];
//        NSLog(@"3____%@",[NSThread currentThread]);
//    });
////    dispatch_barrier_sync(queue, ^{
////        [NSThread sleepForTimeInterval:1];
////        NSLog(@"____%@",[NSThread currentThread]);
////    });
//    dispatch_async(queue, ^{
//        //[NSThread sleepForTimeInterval:0.5];
//        NSLog(@"4____%@",[NSThread currentThread]);
//    });
//    NSLog(@"bbbbbbbb");
//    dispatch_async(queue, ^{
//        NSLog(@"5____%@",[NSThread currentThread]);
//    });
//    NSLog(@"ccccccc");
//    dispatch_async(queue, ^{
//        //[NSThread sleepForTimeInterval:0.5];
//        NSLog(@"6____%@",[NSThread currentThread]);
//    });
    
//会开启子线程
//    dispatch_async(queue2, ^{
//        [NSThread sleepForTimeInterval:1];
//        NSLog(@"1___%@",[NSThread currentThread]);
//    });
//    dispatch_async(queue2, ^{
//        NSLog(@"2___%@",[NSThread currentThread]);
//    });
//不会开启自线程，只会在当前线程同步执行任务
//    dispatch_sync(queue2, ^{
//        NSLog(@"2___%@",[NSThread currentThread]);
//    });
//    dispatch_sync(queue2, ^{
//        NSLog(@"2___%@",[NSThread currentThread]);
//    });
}

-(void)operationTap{
//    [NSThread sleepForTimeInterval:2];
//    NSLog(@"ttttoooooo%@",[NSThread currentThread]);
    for (int i=0; i<10; i++) {
        [NSThread sleepForTimeInterval:1];
        NSLog(@"是否取消任务%d",[_operation isCancelled]);
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"tap");
    [_operation cancel];
}

//sd库探索
-(void)sdDemo{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 100, 100, 100)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:@"https://img-blog.csdn.net/20160620203056390?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQv/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center"] placeholderImage:nil options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        //NSLog(@"下载进度%@:%lu__%lu",targetURL,receivedSize,expectedSize);
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
    }];
    [self.view addSubview:imageView];
}

//缓存
-(void)cacheDemo{
    UIButton *btn1 = [[UIButton alloc]initWithFrame:CGRectMake(30, 130, 30, 30)];
    btn1.backgroundColor = [UIColor redColor];
    [btn1 addTarget:self action:@selector(tapbtn1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [[UIButton alloc]initWithFrame:CGRectMake(230, 230, 30, 30)];
    btn2.backgroundColor = [UIColor greenColor];
    [btn2 addTarget:self action:@selector(tapbtn2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
}

-(void)tapbtn1{
    _cache = [[NSCache alloc]init];
    _cache.totalCostLimit = 1000000;
    _cache.countLimit = 5;
    [_cache setObject:[UILabel new] forKey:@"label"];
}

-(void)tapbtn2{
    
    NSLog(@"%@",[_cache objectForKey:@"label"]);
}

//标签视图
-(void)labelTest{
    NSArray *arr = @[@"aghfggkjdhghjhkjhkdlkfc",@"akdfsdfsdklk",@"asdhaksdjh",@"skajfjksdfhjdfhksdjfh",@"你好",@"00000123",@"啊啊啊啊",@"啊",@"啊",@"sajfskfhskfdjs",@"%$^%&*%^&"];
    _bView = [[ButtonView alloc]initWithFrame:CGRectMake(0, 64, 375, 500) contentArray:arr fontSize:16 options:AutoAdjustHeightAndWidthStyle sizeBlock:nil];
    _bView.delegate = self;
    [self.view addSubview:_bView];
    
    UILabel *lb = [[UILabel alloc]initWithFrame:CGRectMake(40, 230, 200, 30)];
    lb.text = @"aa嗷嗷";
    [self.view addSubview:lb];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(200, 400, 40, 40)];
    btn.backgroundColor = [UIColor orangeColor];
    [btn addTarget:self action:@selector(btntap) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}

-(void)touchLabelAtIndex:(NSUInteger)index content:(NSString *)content{
    NSLog(@"%lu____%@",index,content);
}

-(void)updateLabelViewFrame:(CGSize)frameSize{
    NSLog(@"%f___%f",frameSize.width,frameSize.height);
}

-(void)btntap{
    _bView.contentArr = @[@"safas",@"sdfaf"];
    [_bView reloadView];
}

-(void)tap:(UITapGestureRecognizer*)sender{
    NSLog(@"aaa");
}

//路由跳转
-(void)routerDemo{
    NSMutableArray *btnArr = [NSMutableArray array];
    for (int i=0; i<3; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(120, 350+50*i, 100, 30)];
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

//反射机制
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
