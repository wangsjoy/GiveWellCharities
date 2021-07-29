//
//  PayPalViewController.m
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/22/21.
//

#import "PayPalViewController.h"
#import <Braintree/BTPayPalDriver.h>

@import Braintree; //import Braintree Paypal SDK
@import PayPalCheckout;

@interface PayPalViewController ()

@property BTAPIClient *braintreeClient;

@end

@interface BTPayPalDriver () //extension
//@property (nonatomic, weak, nullable) id<BTAppSwitchDelegate> appSwitchDelegate;
@property (nonatomic, weak, nullable) id<BTViewControllerPresentingDelegate> viewControllerPresentingDelegate;
@end

@implementation PayPalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.braintreeClient = [[BTAPIClient alloc] initWithAuthorization:@"sandbox_5rzkvvbq_yhmkqgz24bmzjpqv"]; //use tokenization key
//    self.braintreeClient = [[BTAPIClient alloc] initWithAuthorization:@"sandbox_5rzkvvbq_yhmkqgz24bmzjpqv"];
    
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:self.braintreeClient];
    payPalDriver.viewControllerPresentingDelegate = self;
    
}




- (IBAction)didTapPayPal:(id)sender {
    NSLog(@"Tapped Pay Pal Button");
    BTPayPalDriver *payPalDriver = [[BTPayPalDriver alloc] initWithAPIClient:self.braintreeClient];
    payPalDriver.viewControllerPresentingDelegate = self;
    
    // ...start the Checkout flow
    BTPayPalDriver *request = [[BTPayPalRequest alloc] init];
    [payPalDriver requestOneTimePayment:request completion:^(BTPayPalAccountNonce * _Nullable tokenizedPayPalAccount, NSError * _Nullable error) {
        if (error){
            NSLog(@"An Error occurred");
        } else {
            NSLog(@"Payment went through");
        }
    }];

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
