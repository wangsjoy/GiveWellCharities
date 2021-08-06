//
//  ConfettiViewController.m
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 8/6/21.
//

#import "ConfettiViewController.h"

@interface ConfettiViewController ()

@end

@implementation ConfettiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self startConfetti];

}

- (void)startConfetti{
    NSLog(@"Start Confetti Emitter");
    //confetti emitter
    CAEmitterLayer *confettiEmitter = [[CAEmitterLayer alloc] init];
    confettiEmitter.emitterPosition = CGPointMake(0, 0);
    CAEmitterCell *emitterCell = [[CAEmitterCell alloc] init];
    emitterCell.birthRate = 100;
    emitterCell.lifetime = 5;
    emitterCell.velocity = 100;
    emitterCell.scale = 0.01;
    emitterCell.emissionRange = 3.14 * 2.0;
    emitterCell.contents = (id) [[UIImage imageNamed:@"green_confetti"] CGImage];
    confettiEmitter.emitterCells = [NSArray arrayWithObject:emitterCell];
    [self.view.layer addSublayer:confettiEmitter];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
