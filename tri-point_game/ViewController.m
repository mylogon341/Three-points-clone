//
//  ViewController.m
//  tri-point_game
//
//  Created by Luke Sadler on 01/10/2014.
//  Copyright (c) 2014 Luke Sadler. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    screenSize = screenBound.size;
    score = 0;
    
    scoreLabel.text = [NSString stringWithFormat:@"%d",score];
    
    
    rotationTracker = 1;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(fallMovement) userInfo:nil repeats:YES];
    
     startPoint = CGPointMake(screenSize.width/2, -40);
    secondStart = CGPointMake(screenSize.width/2, -240);
     thirdStart = CGPointMake(screenSize.width/2, -440);
    
    
     first = [[UIImageView alloc] initWithFrame:CGRectMake(startPoint.x, startPoint.y , 40, 40)];
    
    second = [[UIImageView alloc] initWithFrame:CGRectMake(startPoint.x, secondStart.y, 40, 40)];
    
     third = [[UIImageView alloc] initWithFrame:CGRectMake(startPoint.x, thirdStart.y, 40, 40)];
    
    [self colourChange:first andMore:ball1Colour];
    [self colourChange:second andMore:ball2Colour];
    [self colourChange:third andMore:ball3Colour];
    
    [self.view insertSubview:first belowSubview:triangle];
    [self.view insertSubview:second belowSubview:triangle];
    [self.view insertSubview:third belowSubview:triangle];
    
    gameOverView.layer.cornerRadius = 5;
    
    fallSpeed = 5;
    
    
    //  Ball colour
    //  1 = yellow
    //  2 = blue
    //  3 = red
    
}


-(void)colourChange:(UIImageView *)ballIV andMore:(int)ballNumber{
    
    ballNumber = arc4random() %3 +1;
    
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
    
     first.center = CGPointMake(startPoint.x, first.center.y + fallSpeed);
    second.center = CGPointMake(secondStart.x, second.center.y + fallSpeed);
     third.center = CGPointMake(thirdStart.x, third.center.y + fallSpeed);
    
    if (CGRectIntersectsRect(first.frame, collLabel.frame)) {
        if (rotationTracker != ball1Colour) {
            
            //Death
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            //fallSpeed = 0;
            first.hidden = YES;
            
            [self gameOver];
            
        }else{
            
            //Winning
            score ++;
            fallSpeed += 0.2;
            first.center = secondStart;
            [self colourChange:first andMore:ball1Colour];
        }
    }
    
    if (CGRectIntersectsRect(second.frame, collLabel.frame)) {
        if (rotationTracker != ball2Colour) {
            
            //Death
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
          //  fallSpeed = 0;
            second.hidden = YES;
            [self gameOver];
            
        }else{
            
            //Winning
            score ++;
            fallSpeed += 0.2;
            second.center = secondStart;
            [self colourChange:second andMore:ball2Colour];
            
        }
    }
    
    if (CGRectIntersectsRect(third.frame, collLabel.frame)) {
        if (rotationTracker != ball3Colour) {
            
            //Death
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
          //  fallSpeed = 0;
            third.hidden = YES;
            [self gameOver];
            
        }else{
            
            //Winning
            score ++;
            fallSpeed += 0.2;
            third.center = secondStart;
            [self colourChange:third andMore:ball3Colour];
            
        }
        
        
        
    }
    
    scoreLabel.text = [NSString stringWithFormat:@"%d",score];
    
}

-(void)gameOver{
    
    triangle.enabled = NO;
    fallSpeed = -0.2;

    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void) {
                         [gameOverView setCenter:CGPointMake(screenSize.width/2, screenSize.height/2 -50)];
                     }
                     completion:^(BOOL finished) {
                     }
     ];
    
}
-(IBAction)restart{

    [self performSegueWithIdentifier:@"restart" sender:nil];

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
    
    [UIView animateWithDuration:0.15
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
