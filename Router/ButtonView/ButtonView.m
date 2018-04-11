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
@property(nonatomic,assign) CGPoint contentOrigin;

@property(nonatomic,strong) NSArray *contentArr;
@property(nonatomic,strong) NSMutableArray *contentArray;
@property(nonatomic,strong) NSMutableArray *labels;
@property(nonatomic,strong) resetBlock sizeBlock;
@end

@implementation ButtonView{
    LabelViewLayoutStyle _options;
}

-(instancetype)init{
    if (self=[super init]) {
    
    }
    return self;
}


-(instancetype)initWithFrame:(CGRect)frame contentArray:(NSArray*)contentArray fontSize:(CGFloat)fontsize options:(LabelViewLayoutStyle)options sizeBlock:(resetBlock)block{
    if (self=[super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        _labels = [NSMutableArray array];
        _contentOrigin = frame.origin;
        _contentSize = frame.size;
        _contentArr = contentArray;
        _fontSize = fontsize;
        _options = options;
        _sizeBlock = block;
        
        //default property
        _selectedColor = [UIColor redColor];
        _unselectedColor = [UIColor blackColor];
        _defaultSelected = 0;
        _hasDefualtSelected = YES;
        _edge = 18;
        _space = 15;
        _isMutiSelected = NO;
    }
    return self;
}



-(void)layoutSubviews{
    [self renderLabels:_contentArr];
}

#pragma -mark private event
-(void)renderLabels:(NSArray*)contentArray{

    CGFloat edge = self.edge;
    CGFloat edgeTop = edge;
    CGFloat edgeLeft = edge;

    CGFloat space = self.space;
    
    _contentArray = [[NSMutableArray alloc]init];
    for (int i=0; i<contentArray.count; i++) {
        if (_hasDefualtSelected) {
            if (i==_defaultSelected) {
                NSDictionary *dic = [[NSDictionary dictionaryWithObjectsAndKeys:contentArray[i],@"content",@(YES),@"isSelected",@(i),@"arrIndex",nil] mutableCopy];
                [_contentArray setObject:dic atIndexedSubscript:i];
            }else{
                NSDictionary *dic = [[NSDictionary dictionaryWithObjectsAndKeys:contentArray[i],@"content",@(NO),@"isSelected",@(i),@"arrIndex",nil] mutableCopy];
                [_contentArray setObject:dic atIndexedSubscript:i];
            }
        }else{
            NSDictionary *dic = [[NSDictionary dictionaryWithObjectsAndKeys:contentArray[i],@"content",@(NO),@"isSelected",@(i),@"arrIndex",nil] mutableCopy];
            [_contentArray setObject:dic atIndexedSubscript:i];
        }
    }
    
    int count=1;
    CGFloat rowHeight = 0.0;
    CGFloat totalHeight=0;
    CGFloat totalWidth=0;
    
    for (NSDictionary *strDic in _contentArray) {
        CGSize labelSize = [self labelAutoCalculateRectWith:strDic[@"content"] FontSize:self.fontSize MaxSize:_contentSize];
        CGFloat labelHeight = labelSize.height+10;
        rowHeight = labelHeight;
        CGFloat labelWidth = labelSize.width+labelHeight/2;
        totalWidth = totalWidth+labelWidth+space;
        if(labelWidth>_contentSize.width-edge*2){
            labelWidth=_contentSize.width-edge*2;
        }
        if ((edgeLeft+labelWidth+edge)>_contentSize.width) {
            edgeTop = edgeTop+labelHeight+space;
            edgeLeft = edge;
            count++;
        }
        
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(edgeLeft, edgeTop, labelWidth, labelHeight)];
        [_labels addObject:label];
        
        label.layer.masksToBounds = YES;
        label.layer.borderWidth = 1;
        label.layer.cornerRadius = labelHeight/2;
        if ([strDic[@"isSelected"] boolValue]) {
            label.textColor = self.selectedColor;
            label.layer.borderColor = [self.selectedColor CGColor];
        }else{
            label.textColor = self.unselectedColor;
            label.layer.borderColor = [self.unselectedColor CGColor];
        }
        label.text = strDic[@"content"];
        label.textAlignment = NSTextAlignmentCenter;
        label.userInteractionEnabled = YES;
        label.tag = [strDic[@"arrIndex"] intValue];
        label.numberOfLines = 1;
        edgeLeft=edgeLeft+labelWidth+space;
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapLabel:)];
        [label addGestureRecognizer:tapGes];
        [self addSubview:label];
    }
    
    if (_contentArray.count) {
        totalHeight = edge*2+count*rowHeight+(count-1)*space;
        totalWidth = totalWidth+edge*2-space;
    }
    if (_options == AutoAdjustHeightAndWidthStyle) {
        if (_contentSize.width>totalWidth) {
            _contentSize.width = totalWidth;
        }
        self.frame = CGRectMake(_contentOrigin.x, _contentOrigin.y, _contentSize.width, totalHeight);
        _sizeBlock(self.frame.size);
    }
    
}

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
    if (_isMutiSelected) {
        UILabel *label = _labels[sender.view.tag];
        NSMutableDictionary *labelState = _contentArray[sender.view.tag];
        if ([labelState[@"isSelected"] boolValue]) {
            label.textColor = self.unselectedColor;
            label.layer.borderColor = self.unselectedColor.CGColor;
            labelState[@"isSelected"] = @(NO);
        }else{
            label.textColor = self.selectedColor;
            label.layer.borderColor = self.selectedColor.CGColor;
            labelState[@"isSelected"] = @(YES);
        }
    }else{
        for (int i=0; i<_contentArray.count; i++) {
            if (i==sender.view.tag) {
                UILabel *label = _labels[i];
                label.textColor = self.selectedColor;
                label.layer.borderColor = self.selectedColor.CGColor;
            }else{
                UILabel *label = _labels[i];
                label.textColor = self.unselectedColor;
                label.layer.borderColor = self.unselectedColor.CGColor;
            }
        }
    }
}



@end
