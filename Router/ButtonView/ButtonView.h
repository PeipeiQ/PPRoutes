//
//  ButtonView.h
//  Router
//
//  Created by 沛沛 on 2018/4/10.
//  Copyright © 2018年 peipei. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger,LabelViewLayoutStyle) {
    FixedBothHeightAndWidthStyle=0,
    AutoAdjustHeightAndWidthStyle=1,
};

typedef void (^resetBlock)(CGSize newSize);

@interface ButtonView : UIView

@property(nonatomic,copy)NSArray *contentsArray;
@property(nonatomic,assign)CGFloat fontSize;
@property(nonatomic,strong)UIColor* unselectedColor;
@property(nonatomic,strong)UIColor* selectedColor;
@property(nonatomic,assign)BOOL hasDefualtSelected;
@property(nonatomic,assign)NSUInteger defaultSelected;
@property(nonatomic,assign)CGFloat edge;
@property(nonatomic,assign)CGFloat space;
@property(nonatomic,assign)BOOL isMutiSelected;

-(instancetype)initWithFrame:(CGRect)frame contentArray:(NSArray*)contentArray fontSize:(CGFloat)fontsize options:(LabelViewLayoutStyle)options sizeBlock:(resetBlock)block;

-(void)reloadLabelView;
@end
