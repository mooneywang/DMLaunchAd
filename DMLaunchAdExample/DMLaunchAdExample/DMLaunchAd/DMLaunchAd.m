//
//  DMLaunchAd.m
//  DMLaunchAdExample
//
//  Created by Mengjie.Wang on 16/7/20.
//  Copyright © 2016年 王梦杰. All rights reserved.
//

#import "DMLaunchAd.h"

#define DMDefaultAdDuration 3 // 默认广告停留时间

typedef void(^TimeUp)(id sender);

@interface DMLaunchAd()

@property (nonatomic, weak) UIButton *skipButton;

@end

@implementation DMLaunchAd

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _adDuration = DMDefaultAdDuration;
        [self setupSubViews];
        [self addToWindow];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _adDuration = DMDefaultAdDuration;
        [self setupSubViews];
        [self addToWindow];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame duration:(NSUInteger)adDuration {
    if (self = [self initWithFrame:frame]) {
        _adDuration = adDuration;
    }
    return self;
}

- (void)setupSubViews {
    UIImageView *adImageView = [[UIImageView alloc] init];
    adImageView.backgroundColor = [UIColor redColor];
    [self addSubview:adImageView];
    _adImageView = adImageView;
    
    UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    skipButton.titleLabel.font = [UIFont systemFontOfSize:15];
    skipButton.titleLabel.textColor = [UIColor whiteColor];
    [skipButton setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
    skipButton.layer.cornerRadius = 15;
    skipButton.layer.masksToBounds = YES;
    [skipButton addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:skipButton];
    _skipButton = skipButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _adImageView.frame = self.bounds;
    _skipButton.frame = CGRectMake(self.bounds.size.width - 70, 30, 60, 30);
}

- (void)addToWindow {
    // 监测DidFinished通知
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        // 将广告视图添加到window上
        [[[UIApplication sharedApplication].delegate window] addSubview:self];
        // 开始计时
        [self countDownFromTime:_adDuration complete:^(id sender) {
            //时间到
            [self remove];
        }];
    }];
}

- (void)countDownFromTime:(CGFloat)duration complete:(TimeUp)timeup {
    // 剩余的时间（必须用__block修饰，以便在block中使用）
    __block NSInteger remainTime = _adDuration;
    // 获取全局队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    // 每隔1s钟执行一次
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    // 在queue中执行event_handler事件
    dispatch_source_set_event_handler(timer, ^{
        if (remainTime <= 0) { // 倒计时结束
            dispatch_source_cancel(timer);
            // 回到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                timeup(_skipButton);
            });
        } else {
            NSString *remainTimeStr = [NSString stringWithFormat:@"%ld 跳过",remainTime];
            // 回到主线程更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [_skipButton setTitle:remainTimeStr forState:UIControlStateNormal];
            });
            remainTime--;
        }
    });
    dispatch_resume(timer);
}

- (void)remove {
    [UIView animateWithDuration:1.0 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
