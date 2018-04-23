//
//  FirstViewController.m
//  Router
//
//  Created by peipei on 2018/4/4.
//  Copyright © 2018年 peipei. All rights reserved.
//

#import "FirstViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
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
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 100, 375, 400)];
    [imageView sd_setImageWithURL:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1524030189873&di=9837a5146b03ff6f722d5b6f58af6111&imgtype=0&src=http%3A%2F%2Fwww.vsochina.com%2Fdata%2Fuploads%2Fresource%2Fbatch%2F12%2F132033371053a388c9641d1.jpg"] placeholderImage:nil options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        //NSLog(@"下载进度%@:%lu__%lu",targetURL,receivedSize,expectedSize);
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
    }];
    [self.view addSubview:imageView];
}

-(void)firstPageMethod{
    NSLog(@"%@--%s",[self class],__func__);
}



@end
