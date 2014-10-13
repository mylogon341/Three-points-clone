
@interface MylogonAudio : NSObject

+ (instancetype)sharedInstance;

- (void)playBackgroundMusic:(NSString *)filename;
- (void)pauseBackgroundMusic;
- (void)resumeBackgroundMusic;

- (void)playSoundEffect:(NSString *)filename;

@end
