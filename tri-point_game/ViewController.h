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
@class GADBannerView;

@interface ViewController : UIViewController
{
    IBOutlet UIButton *triangle;
    IBOutlet UILabel *scoreLabel;
    IBOutlet UILabel *collLabel;
    IBOutlet UIView *gameOverView;
    
    IBOutlet UIButton *restartButton;
    IBOutlet UIButton *shareButton;

    int rotationTracker;
    int score;
    int ball1Colour;
    int ball2Colour;
    int ball3Colour;
    
    long int highScoreInt;
    
    float fallSpeed;
    
    BOOL dead;
    BOOL deadReverse;
    
    __weak IBOutlet UILabel *highScore;

    NSTimer *timer;
    NSTimer *fallTimer;
 
    CGPoint startPoint;
 
    CGSize screenSize;
    
    UIImageView *first;
    UIImageView *second;
    UIImageView *third;
    
    
}
@property (weak, nonatomic) IBOutlet GADBannerView  *bannerView;

@end

