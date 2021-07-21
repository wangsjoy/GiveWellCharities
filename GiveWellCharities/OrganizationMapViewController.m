//
//  OrganizationMapViewController.m
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/20/21.
//

#import "OrganizationMapViewController.h"
#import <Parse/Parse.h>
@import GoogleMaps; //import GoogleMaps SDK

@interface OrganizationMapViewController ()
@property (nonatomic, strong) NSMutableArray *arrayOfCountryKeys;
@property (nonatomic, strong) NSMutableArray *arrayOfBorderCoordinates;
@property (nonatomic, strong) NSMutableArray *arrayOfLatitudes;
@property (nonatomic, strong) NSMutableArray *arrayOfLongitudes;
@end

@implementation OrganizationMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //assign the country border keys (array of NSNumbers)
    self.arrayOfCountryKeys = self.organization[@"operatingCountries"];
//    NSLog(@"Array of Country Keys:");
//    NSLog(@"%@", self.arrayOfCountryKeys);
    
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 1.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.36
                                                            longitude:-122.0
                                                                 zoom:1];
    GMSMapView *mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];
//    mapView.myLocationEnabled = YES; //don't show the user location
    [self.view addSubview:mapView];
    
    //call a query which stores all the borderobjects
    [self fetchBorderObjects];
}

- (void)fetchBorderObjects{
    //fetch all donation transactions
    
    PFQuery *query = [PFQuery queryWithClassName:@"Border"];
//    [query orderByDescending:@"createdAt"];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *borders, NSError *error) {
        if (borders != nil) {
            // do something with the array of object returned by the call
            NSLog(@"All Borders retrieved");
//            for (PFObject *border in borders){
//                NSLog(@"%@", border);
//            }
            self.arrayOfBorderCoordinates = borders;
            [self drawBorderPath]; //draw each border

        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)drawBorderPath{
    //code
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 1.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.36
                                                            longitude:-122.0
                                                                 zoom:1];
    GMSMapView *mapView = [GMSMapView mapWithFrame:self.view.frame camera:camera];
//    mapView.myLocationEnabled = YES; //don't show the user location
    [self.view addSubview:mapView];

    double startingColor = 0;
    NSUInteger countryCountInteger = [self.arrayOfCountryKeys count];
    double countryCountDouble = (double)countryCountInteger;
    double colorIncrement = 3/countryCountDouble;
    
    for (PFObject *border in self.arrayOfBorderCoordinates){
        
        //check if organization operates in the country (if not, don't draw)
        NSNumber *countryKeyNumber = border[@"keyNumber"];
        NSLog(@"Quantity found: %@", border[@"keyNumber"]);
        if ([self.arrayOfCountryKeys containsObject:countryKeyNumber]){
            NSLog(@"Drawing Border for %@", border[@"countryName"]);

            // Create a rectangular path
            GMSMutablePath *countryBorder = [GMSMutablePath path];
            
            //populate array to store all longitude and latitude values
            //clear all values previously stored arrays (array of NSNumbers)
            [self.arrayOfLongitudes removeAllObjects];
            [self.arrayOfLatitudes removeAllObjects];
            
            //first check if border is noncontiguous
            if ([border[@"adjusted"] isEqualToString:@"True"]){
                //use adjusted coordinates
                self.arrayOfLatitudes = border[@"adjustedLat"];
                self.arrayOfLongitudes = border[@"adjustedLon"];
            } else {
                self.arrayOfLatitudes = border[@"lat"];
                self.arrayOfLongitudes = border[@"lon"];
            }

            NSUInteger length = [self.arrayOfLatitudes count];
            NSUInteger arrow = 0;
            while (arrow < length){
                NSString *latitudeString = self.arrayOfLatitudes[arrow];
                double lat = [latitudeString doubleValue];
                NSString *longitudeString = self.arrayOfLongitudes[arrow];
                double lon = [longitudeString doubleValue];
                [countryBorder addCoordinate:CLLocationCoordinate2DMake(lat, lon)];
                arrow++;
            }

            // Create the polygon, and assign it to the map.
            GMSPolygon *polygon = [GMSPolygon polygonWithPath:countryBorder];
            
            //deal with colors
            //increment color
            startingColor += colorIncrement;
            NSMutableArray *colorMap = [self colorMap:startingColor];
//            NSLog(@"Logging the colors of the colorMap: %@", colorMap);
            double red = [colorMap[0] doubleValue];
            double green = [colorMap[1] doubleValue];
            double blue = [colorMap[2] doubleValue];
            polygon.fillColor = [UIColor colorWithRed:red green:green blue:blue alpha:1];

            polygon.strokeColor = [UIColor colorWithRed:red green:green blue:blue alpha:1];

//            polygon.strokeColor = [UIColor blackColor];
            polygon.strokeWidth = 2;
            polygon.map = mapView;
            
            //check for additional noncontiguous borders (e.g. Alaska/Pacific Islands in US border)
            if ([border[@"multiple"] isEqualToString:@"True"]){
                NSLog(@"Started Another Non-Contiguous Border Polygon Drawing");
                [self.arrayOfLongitudes removeAllObjects];
                [self.arrayOfLatitudes removeAllObjects];
                self.arrayOfLatitudes = border[@"additionalLat"];
                self.arrayOfLongitudes = border[@"additionalLon"];
                // Create another border path
                GMSMutablePath *anotherCountryBorder = [GMSMutablePath path];
                NSUInteger anotherLength = [self.arrayOfLatitudes count];
                NSUInteger anotherArrow = 0;
                while (anotherArrow < anotherLength){
                    NSString *latitudeString = self.arrayOfLatitudes[anotherArrow];
                    double lat = [latitudeString doubleValue];
                    NSString *longitudeString = self.arrayOfLongitudes[anotherArrow];
                    double lon = [longitudeString doubleValue];
                    [anotherCountryBorder addCoordinate:CLLocationCoordinate2DMake(lat, lon)];
                    anotherArrow++;
                }

                // Create the polygon, and assign it to the map.
                GMSPolygon *anotherPolygon = [GMSPolygon polygonWithPath:anotherCountryBorder];
                anotherPolygon.fillColor = [UIColor colorWithRed:red green:green blue:blue alpha:1];
                anotherPolygon.strokeColor = [UIColor colorWithRed:red green:green blue:blue alpha:1];
                anotherPolygon.strokeWidth = 2;
                
                anotherPolygon.map = mapView;
            }
        } else {
            NSLog(@"Country Border %@ is not included", border[@"countryName"]);
        }
    }
    
}

- (NSMutableArray*)colorMap:(double)colorIncrement{
    //return array with three elements [red, green, blue] (where each element is a double between 0 to 1, inclusive)
    //start with rounding down
    double floored = floor(colorIncrement);
    NSMutableArray *returnedColorArray = [[NSMutableArray alloc] initWithCapacity:0];
    if (floored == 0){
        [returnedColorArray addObject:[NSNumber numberWithDouble:colorIncrement]];
        [returnedColorArray addObject:[NSNumber numberWithDouble:0]];
        [returnedColorArray addObject:[NSNumber numberWithDouble:0]];
    } else if (floored ==1){
        [returnedColorArray addObject:[NSNumber numberWithDouble:1]];
        [returnedColorArray addObject:[NSNumber numberWithDouble:(colorIncrement-1)]];
        [returnedColorArray addObject:[NSNumber numberWithDouble:0]];
    } else {
        [returnedColorArray addObject:[NSNumber numberWithDouble:1]];
        [returnedColorArray addObject:[NSNumber numberWithDouble:1]];
        [returnedColorArray addObject:[NSNumber numberWithDouble:(colorIncrement-2)]];
    }
    return returnedColorArray;
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
