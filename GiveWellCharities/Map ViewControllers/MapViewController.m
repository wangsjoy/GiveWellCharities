//
//  MapViewController.m
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/19/21.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

@import GoogleMaps; //import GoogleMaps SDK

@interface MapViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) NSMutableArray *arrayOfLocations;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [GMSServices provideAPIKey:@"AIzaSyCQOU0SUZBBkhEUuSL4VZVTG3XZU1lmvDA"];
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 1.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:32.7502
                                                            longitude:-114.7655
                                                                 zoom:1];
    GMSMapView *mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];
//    mapView.myLocationEnabled = YES; //don't show the user location
    [self.view addSubview:mapView];
    
    [self fetchLocations];
    
}

- (void)fetchLocations{
    //fetch all donation transactions
    
    PFQuery *query = [PFQuery queryWithClassName:@"Payment"];
    [query orderByDescending:@"createdAt"];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *locations, NSError *error) {
        if (locations != nil) {
            // do something with the array of object returned by the call
            NSLog(@"All Payments retrieved");
            for (PFObject *location in locations){
                NSLog(@"%@", location);
            }
            self.arrayOfLocations = locations;
            [self drawMarkers];

        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}
     
- (void)drawMarkers{
    //code
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 1.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:32.7502
                                                            longitude:-114.7655
                                                                 zoom:1];
    GMSMapView *mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];
//    mapView.myLocationEnabled = YES;
    [self.view addSubview:mapView];
    
    // Creates a marker for each location
    for (PFObject *location in self.arrayOfLocations){

        //map only if contribution is public
        if ([location[@"anonymousString"] isEqualToString:@"false"]){
            NSLog(@"Public Donation");
            GMSMarker *marker = [[GMSMarker alloc] init];
            NSNumber *longitudeNumber = location[@"longitude"];
            NSNumber *latitudeNumber = location[@"latitude"];
            double longitude = [longitudeNumber doubleValue];
            double latitude = [latitudeNumber doubleValue];
            marker.position = CLLocationCoordinate2DMake(latitude, longitude);
            marker.title = location[@"metricQuantity"];
            marker.snippet = location[@"metricString"];
            marker.map = mapView;
        } else {
            NSLog(@"Anonymous Donation");
        }
    }
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
