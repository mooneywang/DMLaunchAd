//
//  DMLaunchAd.h
//  DMLaunchAdExample
//
//  Created by Mengjie.Wang on 16/7/20.
//  Copyright © 2016年 王梦杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMLaunchAd : UIView

/** 广告持续时间*/
@property (nonatomic, assign) NSUInteger adDuration;
/** 广告图片*/
@property (nonatomic, weak) UIImageView *adImageView;

- (instancetype)initWithFrame:(CGRect)frame duration:(NSUInteger)adDuration;

@end
