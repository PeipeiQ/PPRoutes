//
//  PPOperation.m
//  Router
//
//  Created by peipei on 2018/4/23.
//  Copyright © 2018年 peipei. All rights reserved.
//

#import "PPOperation.h"

//继承operation

@interface PPOperation(){
    id target;
    SEL selector;
}
@end


@implementation PPOperation

-(instancetype)initWithTarget:(id)atarget action:(SEL)aselector{
    if(self = [super init]){
        target = atarget;
        selector = aselector;
    }
    return self;
}

-(void)start{
    if ([target respondsToSelector:selector]){
        [target performSelector:selector];
    }
//    NSLog(@"aaaaa%@",[NSThread currentThread]);
}

-(void)main{
    
}


@end
