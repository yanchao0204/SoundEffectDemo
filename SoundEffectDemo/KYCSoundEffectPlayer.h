//
//  Created by Kevin kevindev0204@126.com
//
//  GitHub
//  https://github.com/yanchao0204/SoundEffect.git
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

typedef void(^KYCSoundEffectPlayerCompletionBLock)(void);

NS_ASSUME_NONNULL_BEGIN


/**
 A Class thay play UI sound effects.
 */
@interface KYCSoundEffectPlayer : NSObject

/**
 Enable / Disable the function of playing sound.
 */
@property (nonatomic, assign) BOOL enable;

/**
  Return the shared instance, you must always use it to play sounds. Create instance with Init method will throw a NSException.
 
 @return a shared KYCSoundEffectPlayer instance.
 */
+ (instancetype)player;



/**
 Play the systemsound associated with sound's soundFilePath. the player supports audio format: .caf, .aif, .aiff, .wav.
 */
- (void)playSystemSoundInPath:(NSString *)soundFilePath completion:(nullable KYCSoundEffectPlayerCompletionBLock) completionBlock;

/**
 Play the alert associated with sound's soundFilePath. the player supports audio format: .caf, .aif, .aiff, .wav.
 */
- (void)playAlertSoundInPath:(NSString *)soundFilePath completion:(nullable KYCSoundEffectPlayerCompletionBLock) completionBlock;

/**
 Play the systemsound with SystemSoundID directly.
 @param soundID You can use some predefined system sounds, website: http://iphonedevwiki.net/index.php/AudioServices
 */
- (void)playSystemSound:(SystemSoundID)soundID completion:(nullable KYCSoundEffectPlayerCompletionBLock) completionBlock;

/**
 Play the alert with SystemSoundID directly.
 @param soundID You can use some predefined system sounds, website: http://iphonedevwiki.net/index.php/AudioServices
 */
- (void)playAlertSound:(SystemSoundID)soundID completion:(nullable KYCSoundEffectPlayerCompletionBLock) completionBlock;

/**
 Play the playVibration, notice: vibration depends on the particular iOS device and settings.
 */
- (void)playVibration;

/**
 Stop playing all sounds.
 */
- (void)stopAll;

/**
 Stop playing the sound associated with soundFilePath.
 */
- (void)stopForSound:(NSString *)soundFilePath;


#pragma mark - Deprecated Init Method
- (instancetype)init DEPRECATED_MSG_ATTRIBUTE("Use +player to get a shared instance");

@end

NS_ASSUME_NONNULL_END
