//
//  AppDelegate.m
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/12/21.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>

@import GoogleMaps; //import GoogleMaps SDK
@import PayPalCheckout; //import PayPal Checkout

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(  NSDictionary *)launchOptions {

    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {

        configuration.applicationId = @"SSjzFOugYJAMLOq8YuW6aZKlA6c1ILKTU3qKpC13";
        configuration.clientKey = @"bG1EJMPr7qhBrcsmKagyBSGAl4iS6pa8XtGGuuUU";
        configuration.server = @"https://parseapi.back4app.com";
    }];

    [Parse initializeWithConfiguration:config];
    
    //initialize GoogleMaps API Key
    [GMSServices provideAPIKey:@"AIzaSyCQOU0SUZBBkhEUuSL4VZVTG3XZU1lmvDA"];
    
//    //initialize PayPalCheckout
//    PPCheckoutConfig *config = [[PPCheckoutConfig alloc] initWithClientID:@"ClientID" returnUrl:@"returnURL" environment:PPCEnvironmentSandbox];
//    [[PPCheckoutConfig alloc] initWithClientID:@"ClientID" returnUrl:@"returnURL" environment:PPCEnvironmentSandbox];
    
    
//    PPCheckoutConfig *config = [[PPCheckoutConfig alloc] initWithClientID:@"Client ID" returnUrl:@"returnURL" createOrder:^(PPCCreateOrderAction *create) {
//        NSLog(@"Created Order");
//        } onApprove:^(PPCApproval *approved) {
//            NSLog(@"Approved");
//        } onCancel:^{
//            NSLog(@"Cancelled");
//        } onError:^(PPCErrorInfo *error) {
//            NSLog(@"Error occurred");
//        } environment:PPCEnvironmentSandbox];
//
//    let config = CheckoutConfig(
//        clientID: "YOUR_CLIENT_ID",
//        returnUrl: "YOUR_RETURN_URL",
//        environment: .sandbox
//    )
//
//    Checkout.set(config: config)


    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

@end
