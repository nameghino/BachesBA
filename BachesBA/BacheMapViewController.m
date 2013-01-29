//
//  BacheMapViewController.m
//  BachesBA
//
//  Created by Nicolas Ameghino on 29/01/13.
//  Copyright (c) 2013 Nicolas Ameghino. All rights reserved.
//

#import "BacheMapViewController.h"
#import <MapKit/MapKit.h>
#import <AFNetworking/AFNetworking.h>
#import <BlocksKit/BlocksKit.h>

#import "Bump.h"
#import "NAJSONRequestOperation.h"

@interface BacheMapViewController () <MKMapViewDelegate>
@property(nonatomic, strong) MKMapView *mapView;
@property(nonatomic, strong) NSMutableSet *bumps;
@end

@implementation BacheMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) loadView {
    [super loadView];
    
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    mapView.mapType = MKMapTypeStandard;
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    self.mapView = mapView;
    
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:mapView];
}

-(void) pruneAnnotationsInMapView:(MKMapView*) mapView {
    /*
    if ([mapView.annotations count] > 50) {
        NSSet *visibleAnnotations = [mapView annotationsInMapRect:[mapView visibleMapRect]];
        [mapView.annotations each:^(id sender) {
            if (![visibleAnnotations containsObject:sender]) {
                [mapView removeAnnotation:sender];
            }
        }];
    }
     */
    [mapView.annotations each:^(id sender) {
        if ([sender isKindOfClass:[MKUserLocation class]]) return;
        [mapView removeAnnotation:sender];
    }];
}

-(void) loadAnnotations {
    AFHTTPClient *client = [BachesBAClient sharedInstance];
    
    NSDictionary *parameterDictionary = [self getMapBounds:self.mapView useServiceKeys:YES];
    
    NSMutableURLRequest *request = [client requestWithMethod:@"GET"
                                                        path:@"marcadores.php"
                                                  parameters:parameterDictionary];
    
    AFJSONRequestOperation *operation =
    [NAJSONRequestOperation JSONRequestOperationWithRequest:request
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                        NSArray *items = JSON[@"hechos"];
                                                        
                                                        NSMutableSet *newAnnotations = [NSMutableSet set];
                                                        
                                                        [items each:^(id sender) {
                                                            Bump *b = [Bump bumpWithDictionary:sender];
                                                            if (![self.mapView.annotations containsObject:b]) {
                                                                if ([newAnnotations count] < 200) {
                                                                    [newAnnotations addObject:b];
                                                                }
                                                            }
                                                        }];
                                                        
                                                        [self pruneAnnotationsInMapView:self.mapView];
                                                        
                                                        [self.mapView addAnnotations:[newAnnotations allObjects]];
                                                        

                                                    }
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error descargando puntos"
                                                                                                        message:[error localizedDescription]];
                                                        [alert show];
                                                    }];
    [operation start];
}

static BOOL userLocated;

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) { return nil; }
    MKPinAnnotationView *pin = (MKPinAnnotationView*) [mapView dequeueReusableAnnotationViewWithIdentifier:@"PinView"];
    pin.animatesDrop = YES;
    if (!pin) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PinView"];
    }
    
    Bump *b = (Bump*)annotation;
    
    NSInteger bumpType = [b[@"idtipo"] integerValue];
    MKPinAnnotationColor pinColor;
    
    switch (bumpType) {
        case 4:
            pinColor = MKPinAnnotationColorPurple;
            break;
        case 5:
            pinColor = MKPinAnnotationColorRed;
            break;
        default:
            pinColor = MKPinAnnotationColorGreen;
            break;
    }
    
    pin.pinColor = pinColor;
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    
    return pin;
}


-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self loadAnnotations];
}

-(NSDictionary*) getMapBounds:(MKMapView*) mapView useServiceKeys:(BOOL) sk{
    MKMapRect mRect = mapView.visibleMapRect;
    MKMapPoint neMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), mRect.origin.y);
    MKMapPoint swMapPoint = MKMapPointMake(mRect.origin.x, MKMapRectGetMaxY(mRect));
    CLLocationCoordinate2D neCoord = MKCoordinateForMapPoint(neMapPoint);
    CLLocationCoordinate2D swCoord = MKCoordinateForMapPoint(swMapPoint);
    return @{
        (!sk ? @"north" :@"frm_latmax") : [NSNumber numberWithDouble:neCoord.latitude],
        (!sk ? @"south" :@"frm_latmin") : [NSNumber numberWithDouble:swCoord.latitude],
        (!sk ? @"east" :@"frm_lngmax")  : [NSNumber numberWithDouble:neCoord.longitude],
        (!sk ? @"west" :@"frm_lngmin")  : [NSNumber numberWithDouble:swCoord.longitude],
    };
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    Bump *b = view.annotation;
    
    NSString *title = [b[@"direccion"] componentsSeparatedByString:@","][0];

    NSMutableString *message = [NSMutableString new];
    [message appendFormat:@"%@\n", b[@"comentario"]];
    [message appendFormat:@"Reportado por %@", b[@"nombre_usuario"]];
    
    
    UIAlertView *details = [[UIAlertView alloc] initWithTitle:title
                                                      message:message
                                                     delegate:nil
                                            cancelButtonTitle:@"Cerrar"
                                            otherButtonTitles:nil];
    [details show];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!userLocated) {
        userLocated = YES;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000, 1000);
        [self.mapView setRegion:region animated:YES];
    }
}

-(void) showAddBumpForm:(id) sender {
    QuickDialogController *addBumpForm = [QuickDialogController controllerForRoot:[AddBumpFormViewController buildForm]];
    [self.navigationController pushViewController:addBumpForm animated:YES];    
}

-(BOOL)shouldAutorotate { return YES; }
-(NSUInteger)supportedInterfaceOrientations { return UIInterfaceOrientationMaskAllButUpsideDown; }

-(void)viewDidAppear:(BOOL)animated {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"BachesBA";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                          target:self
                                                                                          action:@selector(showAddBumpForm:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
