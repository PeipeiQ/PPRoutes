//
//  ButtonView.m
//  Router
//
//  Created by 沛沛 on 2018/4/10.
//  Copyright © 2018年 peipei. All rights reserved.
//

#import "ButtonView.h"
@interface ButtonView()
@property(nonatomic,assign) CGSize contentSize;
@property(nonatomic,strong) NSArray *contentArray;
@property(nonatomic,strong) NSMutableArray *labels;

@end

@implementation ButtonView

-(instancetype)init{
    if (self=[super init]) {
    
    }
    return self;
}


-(instancetype)initWithFrame:(CGRect)frame contentArray:(NSArray*)contentArray{
    if (self=[super initWithFrame:frame]) {
        self.backgroundColor = [UIColor grayColor];
        _labels = [NSMutableArray array];
        _contentSize = frame.size;
        _contentArray = contentArray;
        [self renderLabels:contentArray];
    }
    return self;
}

-(void)renderLabels:(NSArray*)contentArray{
    //外边距
    CGFloat edge = 18;
    CGFloat edgeTop = edge;
    CGFloat edgeLeft = edge;

    //label间距
    CGFloat space = 15;
    
    unsigned int count=1;
    
    for (NSString *str in contentArray) {
        CGSize labelSize = [self labelAutoCalculateRectWith:str FontSize:17 MaxSize:_contentSize];
        CGFloat labelHeight = labelSize.height;
        CGFloat labelWidth = labelSize.width+labelHeight/2;
        if(labelWidth>_contentSize.width){
            labelWidth=_contentSize.width-edge*2;
        }
        if ((edgeLeft+labelWidth+edge)>_contentSize.width) {
            edgeTop = edgeTop+labelHeight+space;
            edgeLeft = edge;
        }
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(edgeLeft, edgeTop, labelWidth, labelHeight)];
        [_labels addObject:label];
        label.textColor = [UIColor blackColor];
        label.layer.masksToBounds = YES;
        label.layer.borderWidth = 1;
        label.layer.cornerRadius = labelHeight/2;
        label.layer.borderColor = [[UIColor blackColor] CGColor];
        label.text = str;
        label.textAlignment = NSTextAlignmentCenter;
        label.userInteractionEnabled = YES;
        label.tag = count++;
        label.numberOfLines = 1;
        edgeLeft=edgeLeft+labelWidth+space;
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapLabel:)];
        [label addGestureRecognizer:tapGes];

        [self addSubview:label];
    }
}

#pragma -mark 私有方法
- (CGSize)labelAutoCalculateRectWith:(NSString *)text FontSize:(CGFloat)fontSize MaxSize:(CGSize)maxSize{
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize labelSize = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
    labelSize.height = ceil(labelSize.height);
    labelSize.width = ceil(labelSize.width);
    return labelSize;
}

-(void)tapLabel:(UITapGestureRecognizer*)sender{
    //sender.view.layer.borderColor = [[UIColor redColor] CGColor];
    long index;
    if (sender.view.tag>0) {
        index = sender.view.tag-1;
    }else{
        index = -sender.view.tag-1;
    }
    UILabel *selectedLabel = _labels[index];
    if(sender.view.tag>0){
        sender.view.layer.borderColor = [[UIColor redColor] CGColor];
        selectedLabel.textColor = [UIColor redColor];
        sender.view.tag = -sender.view.tag;
    }else{
        sender.view.layer.borderColor = [[UIColor blackColor] CGColor];
        selectedLabel.textColor = [UIColor blackColor];
        sender.view.tag = -sender.view.tag;
    }
    NSLog(@"%@",_labels);
}

@end
