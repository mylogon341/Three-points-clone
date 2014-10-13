//
//  ViewController.m
//  tri-point_game
//
//  Created by Luke Sadler on 01/10/2014.
//  Copyright (c) 2014 Luke Sadler. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
#import "GADBannerView.h"
#import "GADRequest.h"
#import "MylogonAudio.h"

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

//Start and accelerations values
#define initialFallSpeed 5.0f;
#define increaseInSpeed 0.2f;

@interface ViewController ()

@end

@implementation ViewController

- (BOOL)prefersStatusBarHidden{
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
#warning insert your own unique GAD ID
    self.bannerView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";
    self.bannerView.rootViewController = self;
    
    
    //Make sure game over view is off the screen
    [gameOverView setCenter:CGPointMake(-200, screenSize.height/2)];
    
    GADRequest *request = [GADRequest request];
    // Enable test ads on simulators.
    request.testDevices = @[ GAD_SIMULATOR_ID ];
    [self.bannerView loadRequest:request];
    
    //Setup 'Share' and 'Reset' buttons to highlights on selection
    [restartButton setImage:[UIImage imageNamed:@"restart_pressed"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [shareButton setImage:[UIImage imageNamed:@"share_pressed"] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    dead = NO;
    deadReverse = NO;
    rotationTracker = 1;
    
    [self highscores];
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    screenSize = screenBound.size;
    score = 0;

    //This is the score label. If a suffix is required, change to '%d Points' etc.
    scoreLabel.text = [NSString stringWithFormat:@"%d",score];
    [scoreLabel setCenter:CGPointMake(screenSize.width/2, 45)];
    
    //Set location, scale and offset anchor point of triangle to rotate around apex
    if (screenSize.height == 480) {
        [triangle setCenter:CGPointMake(screenSize.width/2, (screenSize.height/9)*6.5)];

    }else{
        [triangle setCenter:CGPointMake(screenSize.width/2, (screenSize.height/9)*7)];

    }

    float scale = screenSize.width/320;
    
    if (scale > 1.75) {
        scale = 1.75;
    }

    [triangle setFrame:CGRectMake(triangle.center.x - (137 * scale)/2, triangle.center.y - (121 * scale)/2, 137 * scale, 121 * scale)];
    
    float yAnchor = 78.0f/230.0f;
    triangle.layer.anchorPoint = CGPointMake(0.5f, yAnchor);
    
    
    //30fps -- 1/30 = 0.03
    timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(fallMovement) userInfo:nil repeats:YES];
    
    float ballHeights = -screenSize.height/3;
    
    startPoint = CGPointMake(screenSize.width/2, -240);
    
    float ballSize = 40 * scale;
    
    
    //Initialise balls
    first = [[UIImageView alloc] initWithFrame:CGRectMake(startPoint.x, startPoint.y , ballSize, ballSize)];
    second = [[UIImageView alloc] initWithFrame:CGRectMake(screenSize.width/2, -40, ballSize, ballSize)];
    third = [[UIImageView alloc] initWithFrame:CGRectMake(screenSize.width/2, -440, ballSize, ballSize)];
    
    //Centre on screen
    [first setCenter:CGPointMake(screenSize.width/2, ballHeights)];
    [second setCenter:CGPointMake(screenSize.width/2, ballHeights * 2)];
    [third setCenter:CGPointMake(screenSize.width/2, ballHeights *3)];
    
    //Set ball colours
    [self colourChange:first andMore:ball1Colour];
    [self colourChange:second andMore:ball2Colour];
    [self colourChange:third andMore:ball3Colour];
    
    //Insert balls
    [self.view insertSubview:first belowSubview:scoreLabel];
    [self.view insertSubview:second belowSubview:scoreLabel];
    [self.view insertSubview:third belowSubview:scoreLabel];
    
    gameOverView.layer.cornerRadius = 5;
    
    //Admob banner
    [_bannerView setCenter:CGPointMake(screenSize.width/2, screenSize.height-25)];
    
    //Make sure collision is in correct location
    [collLabel setCenter:triangle.center];
    
    fallSpeed = initialFallSpeed;
    
    //  Ball colour
    //  1 = yellow
    //  2 = blue
    //  3 = red
    
}


-(void)colourChange:(UIImageView *)ballIV andMore:(int)ballNumber{
    
    ballNumber = arc4random() %3 +1;
    
    //Sets colour of balls. These are image titles that are in 'Images.xcassets'
    switch (ballNumber) {
        case 1:
            [ballIV setImage:[UIImage imageNamed:@"yellow"]];
            break;
        case 2:
            [ballIV setImage:[UIImage imageNamed:@"blue"]];
            break;
        case 3:
            [ballIV setImage:[UIImage imageNamed:@"red"]];
            break;
        default:
            break;
    }
    
    if (ballIV == first) {
        ball1Colour = ballNumber;
    }
    if (ballIV == second) {
        ball2Colour = ballNumber;
    }
    if (ballIV == third) {
        ball3Colour = ballNumber;
    }
}

-(void)fallMovement{
    
    if (dead && !deadReverse) {
        fallSpeed -= 0.2;
    }
    
    if (fallSpeed <= 0) {
        fallSpeed = -1;
    }
    
    first.center = CGPointMake(startPoint.x, first.center.y + fallSpeed);
    second.center = CGPointMake(second.center.x, second.center.y + fallSpeed);
    third.center = CGPointMake(third.center.x, third.center.y + fallSpeed);
    if (!dead) {
        if (CGRectIntersectsRect(first.frame, collLabel.frame)) {
            if (rotationTracker != ball1Colour) {
                
                //Death
                first.hidden = YES;
                
                [self gameOver];
                
            }else{
                
                //Winning
                score ++;
                fallSpeed += increaseInSpeed;
                first.center = startPoint;
                [self colourChange:first andMore:ball1Colour];
                [self playPop];
            }
        }
        
        if (CGRectIntersectsRect(second.frame, collLabel.frame)) {
            if (rotationTracker != ball2Colour) {
                
                //Death
                second.hidden = YES;
                [self gameOver];
                
            }else{
                
                //Winning
                score ++;
                fallSpeed += increaseInSpeed;
                second.center = startPoint;
                [self colourChange:second andMore:ball2Colour];
                [self playPop];
                
            }
        }
        
        if (CGRectIntersectsRect(third.frame, collLabel.frame)) {
            if (rotationTracker != ball3Colour) {
                
                //Death
                //  fallSpeed = 0;
                third.hidden = YES;
                [self gameOver];
                
            }else{
                
                //Winning
                score ++;
                fallSpeed += increaseInSpeed;
                third.center = startPoint;
                [self colourChange:third andMore:ball3Colour];
                [self playPop];
            }
            
            
            
        }
    }
    scoreLabel.text = [NSString stringWithFormat:@"%d",score];
    
}

-(void)playPop{
#warning optionally replace 'pop' sound
    
    [[MylogonAudio sharedInstance]playSoundEffect:@"pop.mp3"];
    
}

-(void)gameOver{
    
    dead = YES;
    
    if (score > highScoreInt) {
        highScore.text = [NSString stringWithFormat:@"Highscore: %ld",highScoreInt];
        [self highscores];
    }
    
    triangle.enabled = NO;
    
    
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         [gameOverView setCenter:CGPointMake(screenSize.width/2, screenSize.height/2)];
                         [gameOverView setAlpha:1];
                     }
                     completion:^(BOOL finished) {
                     }
     ];
    
}

-(void)highscores{
    
    if (!dead) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        highScoreInt = [defaults integerForKey:@"highscore"];
        
    }else{
        
        highScoreInt = score;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setInteger:highScoreInt forKey:@"highscore"];
        [defaults synchronize];
    }
    
    highScore.text = [NSString stringWithFormat:@"Highscore: %ld",highScoreInt];
    
}


-(IBAction)restart{
    
    // [self performSegueWithIdentifier:@"restart" sender:nil];
    
    [self viewDidLoad];
    
}


-(IBAction)share{
    //  Create an instance of the Tweet Sheet
    SLComposeViewController *tweetSheet = [SLComposeViewController
                                           composeViewControllerForServiceType:
                                           SLServiceTypeTwitter];
    
    // Sets the completion handler.  Note that we don't know which thread the
    // block will be called on, so we need to ensure that any required UI
    // updates occur on the main queue
    tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultDone:
            {
                
                
                break;}
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultCancelled:{
                
            }   break;
        }
    };
    
    //  Set the initial body of the Tweet
    [tweetSheet setInitialText:[NSString stringWithFormat:@"Hey. I scored %d on Tri-Game. See if you can beat it!",score]];
    
    //  Adds an image to the Tweet.  For demo purposes, assume we have an
    //  image named 'larry.png' that we wish to attach
    if (![tweetSheet addImage:[UIImage imageNamed:@"triangle"]]) {
        NSLog(@"Unable to add the image!");
    }
    
    //  Add an URL to the Tweet.  You can add multiple URLs.
#warning insert app store url
    if (![tweetSheet addURL:[NSURL URLWithString:@"<app store url>"]]){
        NSLog(@"Unable to add the URL!");
    }
    
    //  Presents the Tweet Sheet to the user
    [self presentViewController:tweetSheet animated:NO completion:^{
        NSLog(@"Tweet sheet has been presented.");
    }];
}



-(IBAction)tri:(id)sender{
    
    CGFloat radians = atan2f(triangle.transform.b, triangle.transform.a);
    CGFloat degrees = radians * (180 / M_PI);
    
    switch (rotationTracker) {
        case 1:
            //yellow
            rotationTracker = 2;
            break;
        case 2:
            //blue
            rotationTracker = 3;
            break;
        case 3:
            //red
            rotationTracker = 1;
            break;
        default:
            break;
    }
    
    
    
    
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         
                         triangle.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degrees + 120));
                     }
                     completion:^(BOOL finished) {

                     }
     ];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
