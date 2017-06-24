
//  SoundEffectDemo
//
//  Created by Kevin kevindev0204@126.com
//  GitHub
//  https://github.com/yanchao0204/SoundEffect.git
//

#import "ViewController.h"
#import "KYCSoundEffectPlayer.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UISwitch *SoundEffectToggle;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *items;

@end


@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.SoundEffectToggle.on = [KYCSoundEffectPlayer player].enable;
    [self loadItems];
    
}


- (void)loadItems {
    [self.items addObject:NSStringFromSelector(@selector(playSystemNewMailSound))];
    [self.items addObject:NSStringFromSelector(@selector(playSystemSound))];
    [self.items addObject:NSStringFromSelector(@selector(playAlertSound))];
    [self.items addObject:NSStringFromSelector(@selector(playLongSound))];
    [self.items addObject:NSStringFromSelector(@selector(playVibration))];

    
    
    [self.tableView reloadData];
}

- (IBAction)enable:(UISwitch *)sender {
    [KYCSoundEffectPlayer player].enable = sender.on;
}

- (void)playSystemNewMailSound {
    
    KYCSoundEffectPlayer *player = [KYCSoundEffectPlayer player];
    // See http://iphonedevwiki.net/index.php/AudioServices
    [player playSystemSound:1000 completion:^{
        NSLog(@"Playing email is done.");
    }];
}

- (void)playSystemSound {
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"click.wav" ofType:nil];
    KYCSoundEffectPlayer *player = [KYCSoundEffectPlayer player];
    // See http://iphonedevwiki.net/index.php/AudioServices
    [player playSystemSoundInPath:soundPath completion:^{
        NSLog(@"playing SystemSound 'click.wav' done.");
    }];
}

- (void)playAlertSound {
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"Hero.aiff" ofType:nil];
    KYCSoundEffectPlayer *player = [KYCSoundEffectPlayer player];
    // See http://iphonedevwiki.net/index.php/AudioServices
    [player playAlertSoundInPath:soundPath completion:^{
        NSLog(@"playing AlertSound 'Hero.aiff' done.");
    }];
}


- (void)playLongSound {
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"guitar.caf" ofType:nil];
    KYCSoundEffectPlayer *player = [KYCSoundEffectPlayer player];
    // See http://iphonedevwiki.net/index.php/AudioServices
    [player playSystemSoundInPath:soundPath completion:^{
        NSLog(@"playing LongSound 'guitar.caf' done.");
    }];
}

- (void)playVibration {
    KYCSoundEffectPlayer *player = [KYCSoundEffectPlayer player];
    [player playVibration];
}

#pragma mark - TableView DataSource and Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"CellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellID];
    }
    
    cell.textLabel.text = self.items[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SEL selector = NSSelectorFromString(self.items[indexPath.row]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:selector];
#pragma clang diagnostic pop
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

}

#pragma mark - PlayItems
- (NSMutableArray *)items {
    if (_items == nil) {
        _items = [NSMutableArray array];
    }
    return _items;
}

@end
