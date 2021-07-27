//
//  DonateWebKitViewController.m
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/27/21.
//

#import "DonateWebKitViewController.h"
#import <WebKit/WebKit.h>

@interface DonateWebKitViewController ()
@property (weak, nonatomic) IBOutlet WKWebView *webKitView;

@end

@implementation DonateWebKitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *donateWebPage = @"https://secure.givewell.org/?a2b1Y0000026SUQ=100&recurring=9swm#givewell-braintree-donate-form";
    NSURL *donateURL = [NSURL URLWithString:donateWebPage];
    
//    NSURL *trailerURL = [NSURL URLWithString:trailerString];

    // Place the URL in a URL Request.
    NSURLRequest *request = [NSURLRequest requestWithURL:donateURL
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:10.0];
    // Load Request into WebView.
    [self.webKitView loadRequest:request];
    
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
