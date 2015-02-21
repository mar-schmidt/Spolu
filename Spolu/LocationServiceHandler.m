//
//  LocationServiceHandler.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-21.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//
//

#import "LocationServiceHandler.h"

@implementation LocationServiceHandler

+ (LocationServiceHandler *)sharedLocationServiceHandler
{
    static LocationServiceHandler *_sharedLocationServiceHandler = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLocationServiceHandler = [[self alloc] init];
    });
    
    return _sharedLocationServiceHandler;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _currenctLocationCity = @"Fetching current location...";
        
        // This creates the CCLocationManager that will find users current location (100m accuracy)
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    return self;
}

- (void)startUpdatingLocation
{
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    // Check if locationService is available, if so. Start updating. Otherwise return error
    //
    // Disclaimer: The locationServicesEnabled class method only tests the global setting for Location Services.
    // AFAIK, there's no way to test if app has explicitly been denied. We'll have to wait for the location request to fail and use the
    // CLLocationManagerDelegate method locationManager:didFailWithError
    if ([CLLocationManager locationServicesEnabled]) {
        [_locationManager startUpdatingLocation];
    } else {
        // Create dictionary with reasons for locationError
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Getting location failed", @"Alert Title: Getting location failed"),
                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Access to Location Services denied by user.", @"Alert Message: Access to Location Services denied. by user"),
                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please allow it under settings.", @"Alert Message: Please allow it under settings.")
                                   };
        _locationError = [NSError errorWithDomain:@"com.ronelius.Spolu"
                                             code:-1
                                         userInfo:userInfo];
        
        // Announce error to delegate
        [self sendCurrentErrorToDelegate];
    }
}

- (void)stopUpdatingLocation
{
    [_locationManager stopUpdatingLocation];
}

#pragma CLLocationManager Delegates
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // Stop from updating longer
    [_locationManager stopUpdatingLocation];
    
    // Get the latest location received in the array and point it to CLLocation object
    NSUInteger latestLocation = locations.count-1;
    CLLocation *currentLocation = [locations objectAtIndex:latestLocation];
    
    // Set the coordinates
    _currentLocationCoordinateX = currentLocation.coordinate.longitude;
    _currentLocationCoordinateY = currentLocation.coordinate.latitude;
    
    // Set the current city
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark *placemark in placemarks) {
            _currenctLocationCity = [placemark locality];
        }
        // Announce on delegate if no error
        if (!error) {
            if ([self.delegate respondsToSelector:@selector(locationServiceHandler:didFailGettingLocation:)]) {
                [self.delegate locationServiceHandler:self didUpdateCurrentLocation:_currenctLocationCity];
            }
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@",[error localizedDescription]);
    
    // Stop location updating
    [manager stopUpdatingLocation];
    
    NSString *errorDescription;
    NSString *errorFailureReason;
    NSString *errorRecoverySuggestion;
    NSInteger errorCode;
    
    switch([error code]) {
        case kCLErrorDenied:
            // Access denied by user
            errorDescription = NSLocalizedString(@"Getting location failed",
                                                 @"Alert Title: Getting location failed");
            
            errorFailureReason = NSLocalizedString(@"Access to Location Services is denied by you.",
                                                   @"Alert Message: Access to Location Services is denied by you.");
            
            errorRecoverySuggestion = NSLocalizedString(@"Please allow it under settings.",
                                                        @"Alert Message: Please allow it under settings");
            errorCode = 0;
            
            break;
        case kCLErrorLocationUnknown:
            // Probably temporary...
            errorDescription = NSLocalizedString(@"Location data unavailable",
                                                 @"Alert Title: Location data unavailable");
            
            errorFailureReason = NSLocalizedString(@"Your location was not found.",
                                                   @"Alert Message: Your location was not found.");
            
            errorRecoverySuggestion = NSLocalizedString(@"Please try again.",
                                                        @"Alert Message: Please try again.");
            errorCode = 1;
            
            break;
        default:
            // Unknown error
            errorDescription = NSLocalizedString(@"Unknown error",
                                                 @"Alert Title: Unknown error");
            
            errorFailureReason = NSLocalizedString(@"An unknown error has occurred.",
                                                   @"Alert Message: An unknown error has occurred.");
            
            errorRecoverySuggestion = NSLocalizedString(@"Please try again.",
                                                        @"Alert Message: Please try again.");
            errorCode = 2;
            
            break;
    }
    
    // Create dictionary with reasons for _locationError
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: errorDescription,
                               NSLocalizedFailureReasonErrorKey: errorFailureReason,
                               NSLocalizedRecoverySuggestionErrorKey: errorRecoverySuggestion
                               };
    _locationError = [NSError errorWithDomain:@"com.ronelius.Spolu"
                                         code:errorCode
                                     userInfo:userInfo];
    
    // Announce error to delegate
    [self sendCurrentErrorToDelegate];
}

- (void)sendCurrentErrorToDelegate
{
    // Announce error to delegate
    if ([self.delegate respondsToSelector:@selector(locationServiceHandler:didFailGettingLocation:)]) {
        [self.delegate locationServiceHandler:self didFailGettingLocation:_locationError];
    }
}

@end
