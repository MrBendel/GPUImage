//
//  ViewController.m
//  MultipleVideoPlayback
//
//  Created by Andrew Poes on 11/12/15.
//  Copyright © 2015 Andrew Poes. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    for (NSUInteger i = 0; i < 3; ++i) {
        [self createNewMovie];
    }
}

- (void)createNewMovie {
    NSString *moviePath = [[NSBundle mainBundle] pathForResource:@"video_sample" ofType:@"mp4"];
    NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
    GPUImageMovie *movie = [[GPUImageMovie alloc] initWithURL:movieURL];
    movie.shouldRepeat = true;
    movie.playAtActualSpeed = true;
    [movie startProcessing];
    
    int rOriginX = arc4random()%300;
    int rOriginY = arc4random()%400;
    int rWidth = arc4random()%200 + 100;
    int rHeight = arc4random()%160 + 60;
    CGRect rect = CGRectMake(rOriginX, rOriginY, rWidth, rHeight);
    GPUImageView *view = [[GPUImageView alloc] initWithFrame:rect];
    view.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    view.backgroundColor = [UIColor blackColor];
    [movie addTarget:view];
    
    [self.view addSubview:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
