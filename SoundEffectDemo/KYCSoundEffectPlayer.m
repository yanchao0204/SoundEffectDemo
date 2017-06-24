//
//  Created by Kevin kevindev0204@126.com
//
//  GitHub
//  https://github.com/yanchao0204/SoundEffect.git
//

#import "KYCSoundEffectPlayer.h"
#import <UIKit/UIKit.h>

// Log
#ifdef DEBUG
#define DebugLog(...) NSLog(@"%s:[%@]\n\n",__func__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define DebugLog(...)
#endif

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define iOS9Later   SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")


static NSString * const KYCSoundEffectPlayerEnableKey = @"KYCSoundEffectPlayerEnableKey";


@interface KYCSoundEffectPlayer ()

@property (nonatomic, strong) NSMutableDictionary *sounds;
@property (nonatomic, strong) NSMutableDictionary *completionBLocks;

@end


static void KYCSoundEffectPlayerCompletion(SystemSoundID soundID, void *clientData) {
    
    KYCSoundEffectPlayer *player = [KYCSoundEffectPlayer player];
    
    KYCSoundEffectPlayerCompletionBLock block = player.completionBLocks[@(soundID)];
    
    if (block) {
        block();
        [player.completionBLocks removeObjectForKey:@(soundID)];
    }
}


@implementation KYCSoundEffectPlayer

#pragma mark - Life Cycle

- (instancetype)init {
    @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%@ Init Error",[self class]]
                                   reason:@"Use +player to get a shared instance"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initPrivate {
    
    self = [super init];
    if (self) {
        _enable = [self loadEnableSetting];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAll) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopAll];
}

#pragma mark - Public

+ (instancetype)player {
    
    static KYCSoundEffectPlayer *player;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[self alloc] initPrivate];
    });
    
    return player;
}

- (void)playSystemSoundInPath:(NSString *)soundFilePath completion:(KYCSoundEffectPlayerCompletionBLock) completionBlock {
    
    
    
    if (!self.enable) {
        return;
    }
    [self playSoundInPath:soundFilePath isAlert:NO completion:completionBlock];
}

- (void)playAlertSoundInPath:(NSString *)soundFilePath completion:(KYCSoundEffectPlayerCompletionBLock) completionBlock {
    
    if (!self.enable) {
        return;
    }
    [self playSoundInPath:soundFilePath isAlert:YES completion:completionBlock];
}

- (void)playSystemSound:(SystemSoundID)soundID completion:(KYCSoundEffectPlayerCompletionBLock) completionBlock {
    
    if (!self.enable) {
        return;
    }
    [self playSound:soundID isAlert:NO completion:completionBlock];
}

- (void)playAlertSound:(SystemSoundID)soundID completion:(nullable KYCSoundEffectPlayerCompletionBLock) completionBlock {
    
    if (!self.enable) {
        return;
    }
    [self playSound:soundID isAlert:NO completion:completionBlock];
}

- (void)playVibration {
    
    if (!self.enable) {
        return;
    }
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)stopAll {
    for (NSString *sound in self.sounds.allKeys) {
        [self stopForSound:sound];
    }
}

- (void)stopForSound:(NSString *)soundFilePath {
    
    NSParameterAssert(soundFilePath != nil);
    
    SystemSoundID soundID = soundFilePath?[self.sounds[soundFilePath] unsignedIntValue]:0;
    if (soundID) {
        [self removeCompletionBLockForSoundID:soundID];
        AudioServicesDisposeSystemSoundID(soundID);
        [self.sounds removeObjectForKey:soundFilePath];
    }
}

#pragma mark - Enable Settings

- (BOOL)loadEnableSetting {
    
    NSNumber *enableValue = [[NSUserDefaults standardUserDefaults] objectForKey:KYCSoundEffectPlayerEnableKey];
    if (!enableValue) {
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:KYCSoundEffectPlayerEnableKey];
        return YES;
    } else {
        return [enableValue boolValue];
    }
}

- (void)setEnable:(BOOL)enable {
    
    _enable = enable;
    
    if (!enable) {
        [self stopAll];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@(enable) forKey:KYCSoundEffectPlayerEnableKey];

    
}

#pragma mark - Sound play

- (void)playSoundInPath:(NSString *)soundFilePath isAlert:(BOOL)isAlert completion:(KYCSoundEffectPlayerCompletionBLock)completionBlock {
    
    NSParameterAssert(soundFilePath != nil);
    
    if (soundFilePath) {
        SystemSoundID soundID = [self.sounds[soundFilePath] unsignedIntValue];
        soundID = soundID?:[self createSoundIDForPath:soundFilePath];
        if (soundID) {
            [self playSound:soundID isAlert:isAlert completion:completionBlock];
        }

    }
}

- (void)playSound:(SystemSoundID)soundID isAlert:(BOOL)isAlert completion:(KYCSoundEffectPlayerCompletionBLock)completionBlock {
    
    if (soundID) {
        // No need cache completionBlock after iOS9
        if (iOS9Later) {
            if (isAlert) {
                AudioServicesPlayAlertSoundWithCompletion(soundID, completionBlock);
            } else {
                AudioServicesPlaySystemSoundWithCompletion(soundID, completionBlock);
            }
        }
        // CompletionBlock will be cached before iOS9
        else {
            if (completionBlock) {
                [self addCompletionBLock:completionBlock forSoundID:soundID];
            }
            
            if (isAlert) {
                AudioServicesPlayAlertSound(soundID);
            } else {
                AudioServicesPlaySystemSound(soundID);
            }
        }
    }
}

#pragma mark - Manage sounds

- (SystemSoundID)createSoundIDForPath:(NSString *)soundFilePath {
    
    if ([soundFilePath isKindOfClass:[NSString class]] && soundFilePath.length > 0) {
        SystemSoundID soundID;
            // create soundID for soundFilePath
            if ([[NSFileManager defaultManager] fileExistsAtPath:soundFilePath]) {
                
                NSURL *fileURL = [NSURL fileURLWithPath:soundFilePath];
                OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(fileURL), &soundID);
                
                if (error) {
                    DebugLog(@"Create soundID failed for %@", soundFilePath);
                    return 0;
                } else {
                    self.sounds[soundFilePath] = @(soundID);
                    return soundID;
                }
                
            } else {
                DebugLog(@"Can not find sound in %@",soundFilePath);
                return 0;
            }
        
    }
    else {
        return 0;
    }
}



#pragma mark - Manage completionBlocks IOS9Before

- (void)addCompletionBLock:(KYCSoundEffectPlayerCompletionBLock)completionBlock forSoundID:(SystemSoundID)soundID {

    if (iOS9Later) {
        return;
    }
    
    if (soundID && completionBlock) {
        OSStatus error = AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, KYCSoundEffectPlayerCompletion, NULL);
        
        if (error) {
            DebugLog(@"AudioServicesAddSystemSoundCompletion failed.");
        } else {
            self.completionBLocks[@(soundID)] = completionBlock;
        }
    }
}

- (void)removeCompletionBLockForSoundID:(SystemSoundID)soundID {
    
    if (iOS9Later) {
        return;
    }
    
    if (soundID) {
        [self.completionBLocks removeObjectForKey:@(soundID)];
        AudioServicesRemoveSystemSoundCompletion(soundID);
    }
}

#pragma mark - Lazy

- (NSMutableDictionary *)sounds {
    
    if (_sounds == nil) {
        _sounds = [NSMutableDictionary dictionary];
    }
    
    return _sounds;
}

- (NSMutableDictionary *)completionBLocks {
    
    if (_completionBLocks == nil) {
        _completionBLocks = [NSMutableDictionary dictionary];
    }
    
    return _completionBLocks;
}



@end
