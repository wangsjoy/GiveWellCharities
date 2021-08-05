//
//  LoginSignupViewController.m
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 8/5/21.
//

#import "LoginSignupViewController.h"

@interface LoginSignupViewController ()
@property (weak, nonatomic) IBOutlet UIView *userView;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@end

@implementation LoginSignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.organizationImages.image = [UIImage imageNamed:self.strImage];
    
//    [self drawBezier];
    [self.signInButton.layer setBorderWidth:1];
    
    [self.signInButton.layer setBorderColor:[[UIColor grayColor] CGColor]];
    
}

- (void) drawBezier {
    //Bezier Path
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGFloat frameHeight = self.view.frame.size.height;
    CGFloat frameWidth = self.view.frame.size.width;
    NSLog(@"Frame Width %f", frameWidth);
    NSLog(@"Frame Height %f", frameHeight);
    [path moveToPoint:CGPointMake(0.0, frameHeight/4)];
    [path addLineToPoint:CGPointMake(frameWidth/2, (frameHeight/4) - 50)];
    [path addLineToPoint:CGPointMake(frameWidth, frameHeight/4)];
    [path addLineToPoint:CGPointMake(frameWidth, frameHeight)];
    [path addLineToPoint:CGPointMake(0, frameHeight)];
    [path closePath];
    
    CAShapeLayer *userLayer = [[CAShapeLayer alloc] init];
    [userLayer setPath:path.CGPath];
    [userLayer setFillColor:[UIColor whiteColor].CGColor];
    [self.userView.layer addSublayer:userLayer];
    
}
- (IBAction)didTapLogin:(id)sender {
    NSLog(@"Entering Login View Controller");
    [self performSegueWithIdentifier:@"userLoginSegue" sender:nil];
}

- (IBAction)didTapSignUp:(id)sender {
    NSLog(@"Entering Sign Up View Controller");
    [self performSegueWithIdentifier:@"userSignUpSegue" sender:nil];
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
