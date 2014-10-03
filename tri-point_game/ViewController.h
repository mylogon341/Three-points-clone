//
//  ViewController.h
//  tri-point_game
//
//  Created by Luke Sadler on 01/10/2014.
//  Copyright (c) 2014 Luke Sadler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Twitter/Twitter.h>

@interface ViewController : UIViewController
{
    IBOutlet UIButton *triangle;
    IBOutlet UILabel *scoreLabel;
    IBOutlet UILabel *collLabel;
    IBOutlet UIView *gameOverView;

    int rotationTracker;
    int score;
    int ball1Colour;
    int ball2Colour;
    int ball3Colour;
    
    float fallSpeed;
    
    NSTimer *timer;
    NSTimer *fallTimer;
    
    
    CGPoint startPoint;
    CGPoint secondStart;
    CGPoint thirdStart;
    
    CGSize screenSize;
    
    UIImageView *first;
    UIImageView *second;
    UIImageView *third;
}

@end

