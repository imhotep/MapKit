//
//  Cordova
//
//

#import "MapKit.h"
#import "CDVAnnotation.h"
#import "CoreLocation/CoreLocation.h"
#import "AsyncImageView.h"

@interface MapKitView () <MKMapViewDelegate> {
    MKPolyline *_routeOverlay;
    MKRoute *_currentRoute;
}
@end

@implementation MapKitView

@synthesize buttonCallback;
@synthesize childView;
@synthesize mapView;
@synthesize imageButton;


-(CDVPlugin*) initWithWebView:(UIWebView*)theWebView
{
    self = (MapKitView*)[super initWithWebView:theWebView];
    return self;
}

/**
 * Create a native map view
 */
- (void)createView
{
    NSDictionary *options = [[NSDictionary alloc] init];
    [self createViewWithOptions:options];
}


- (void)createViewWithOptions:(NSDictionary *)options {

    //This is the Designated Initializer

    // defaults
    float height = ([options objectForKey:@"height"]) ? [[options objectForKey:@"height"] floatValue] : self.webView.bounds.size.height/2;
    float width = ([options objectForKey:@"width"]) ? [[options objectForKey:@"width"] floatValue] : self.webView.bounds.size.width;
    float x = ([options objectForKey:@"xPos"]) ? [[options objectForKey:@"xPos"] floatValue] : self.webView.bounds.origin.x + self.webView.bounds.size.width;
    float y = ([options objectForKey:@"yPos"]) ? [[options objectForKey:@"yPos"] floatValue] : self.webView.bounds.origin.y;
    BOOL atBottom = ([options objectForKey:@"atBottom"]) ? [[options objectForKey:@"atBottom"] boolValue] : NO;
    BOOL userInteractionEnabled = ([options objectForKey:@"userInteractionEnabled"]) ? [[options objectForKey:@"userInteractionEnabled"] boolValue] : NO;

    if(atBottom) {
        y += self.webView.bounds.size.height - height;
    }

    self.childView = [[UIView alloc] initWithFrame:CGRectMake(x,y,width,height)];
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(self.childView.bounds.origin.x, self.childView.bounds.origin.y, self.childView.bounds.size.width, self.childView.bounds.size.height)];
    self.mapView.delegate = self;
    self.mapView.multipleTouchEnabled   = YES;
    self.mapView.autoresizesSubviews    = YES;
    self.mapView.userInteractionEnabled = userInteractionEnabled;
    self.mapView.showsUserLocation = YES;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.childView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CLLocationCoordinate2D centerCoord = { [[options objectForKey:@"lat"] floatValue] , [[options objectForKey:@"lon"] floatValue] };
    CLLocationDistance diameter = [[options objectForKey:@"diameter"] floatValue];

    MKCoordinateRegion region=[ self.mapView regionThatFits: MKCoordinateRegionMakeWithDistance(centerCoord,
                                                                                                diameter*(height / self.webView.bounds.size.width),
                                                                                                diameter*(height / self.webView.bounds.size.width))];
    
    [self.mapView setRegion:region animated:YES];
    [self.childView addSubview:self.mapView];

    [ [ [ self viewController ] view ] addSubview:self.childView];

}

- (void)destroyMap:(CDVInvokedUrlCommand *)command
{
    if (self.mapView)
    {
        [ self.mapView removeAnnotations:mapView.annotations];
        [ self.mapView removeFromSuperview];

        mapView = nil;
    }
    if(self.imageButton)
    {
        [ self.imageButton removeFromSuperview];
        //[ self.imageButton removeTarget:self action:@selector(closeButton:) forControlEvents:UIControlEventTouchUpInside];
        self.imageButton = nil;

    }
    if(self.childView)
    {
        [ self.childView removeFromSuperview];
        self.childView = nil;
    }
    self.buttonCallback = nil;
}

- (void)clearMapPins:(CDVInvokedUrlCommand *)command
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

- (void)addMapPins:(CDVInvokedUrlCommand *)command
{
    NSLog(@"DROP PINS !");

    NSArray *pins = command.arguments[0];

  for (int y = 0; y < pins.count; y++)
    {
        NSDictionary *pinData = [pins objectAtIndex:y];
        CLLocationCoordinate2D pinCoord = { [[pinData objectForKey:@"lat"] floatValue] , [[pinData objectForKey:@"lon"] floatValue] };
        NSString *title=[[pinData valueForKey:@"title"] description];
        NSString *subTitle=[[pinData valueForKey:@"snippet"] description];
        NSInteger index=[[pinData valueForKey:@"index"] integerValue];
        BOOL selected = [[pinData valueForKey:@"selected"] boolValue];

        NSString *pinColor = nil;
        NSString *imageURL = nil;

        if([[pinData valueForKey:@"icon"] isKindOfClass:[NSNumber class]])
        {
            pinColor = [[pinData valueForKey:@"icon"] description];
        }
        else if([[pinData valueForKey:@"icon"] isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *iconOptions = [pinData valueForKey:@"icon"];
            pinColor = [[iconOptions valueForKey:@"pinColor" ] description];
            imageURL=[[iconOptions valueForKey:@"resource"] description];
        }

        CDVAnnotation *annotation = [[CDVAnnotation alloc] initWithCoordinate:pinCoord index:index title:title subTitle:subTitle imageURL:imageURL];
        annotation.pinColor=pinColor;
        annotation.selected = selected;

        [self.mapView addAnnotation:annotation];
        
        
        MKMapRect zoomRect = MKMapRectNull;
        for (id <MKAnnotation> annotation in self.mapView.annotations)
        {
            MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
            MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.2, 0.2);
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
        
        [self.mapView setVisibleMapRect:MKMapRectInset(zoomRect, -zoomRect.size.width * 0.5, -zoomRect.size.width * 0.5) animated:YES];
        
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
    }

}

-(void)showMap:(CDVInvokedUrlCommand *)command
{
    if (!self.mapView)
    {
        [self createViewWithOptions:command.arguments[0]];
    }
    self.childView.hidden = NO;
    self.mapView.showsUserLocation = YES;
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
    
}

/* DRAW DIRECTIONS */
-(void)showDirections:(CDVInvokedUrlCommand *)command
{
    if (!self.mapView || self.childView.hidden==YES)
    {
        return;
    }
    
    NSLog(@"SHOW DIRECTIONS");
    
    NSArray *directions = command.arguments[0];
    
    for (int y = 0; y < directions.count; y++)
    {
        NSDictionary *dirData = [directions objectAtIndex:y];
        bool srcIsCurrPosition = [dirData objectForKey:@"srcIsCurrPosition"] ? [[dirData objectForKey:@"srcIsCurrPosition"] floatValue] : false;
        float srcLatitude = [[dirData objectForKey:@"srcLatitude"] floatValue];
        float srcLongitude = [[dirData objectForKey:@"srcLongitude"] floatValue];
        float destLatitude = [[dirData objectForKey:@"destLatitude"] floatValue];
        float destLongitude = [[dirData objectForKey:@"destLongitude"] floatValue];
        bool walk = [dirData objectForKey:@"transportTypeWalk"] ? [[dirData objectForKey:@"transportTypeWalk"] floatValue] : false;
        
        MKDirectionsRequest *directionsRequest = [MKDirectionsRequest new];
        
        // Make the destination
        CLLocationCoordinate2D destinationCoords = CLLocationCoordinate2DMake(destLatitude, destLongitude);
        MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:destinationCoords addressDictionary:nil];
        MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
        
        // Set the source and destination on the request
        if (srcIsCurrPosition){
            MKMapItem *source = [MKMapItem mapItemForCurrentLocation];
            [directionsRequest setSource:source];
        }
        else{
            CLLocationCoordinate2D sourceCoords = CLLocationCoordinate2DMake(srcLatitude, srcLongitude);
            MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:sourceCoords addressDictionary:nil];
            MKMapItem *source = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
            [directionsRequest setSource:source];
        }
        if (walk) {
            [directionsRequest setTransportType:MKDirectionsTransportTypeWalking];
        }
        else{
            [directionsRequest setTransportType:MKDirectionsTransportTypeAutomobile];
        }
        [directionsRequest setDestination:destination];
        MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            
            // Now handle the result
            // AN ERROR OCCURED THROW ERROR
            if (error) {
                NSLog(@"There was an error getting your directions");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erreur d'itinéraire"
                                                            message:@"Veuillez nous excusez, nous n'avons pas pu tracer votre itinéraire."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
                [alert show];
                return;
            }
        
            // So there wasn't an error - let's plot those routes
            NSLog(@"SUCCESS");
            _currentRoute = [response.routes firstObject];
            [self plotRouteOnMap:_currentRoute];
        }];
    }
}

- (void)plotRouteOnMap:(MKRoute *)route
{
    if(_routeOverlay) {
        [self.mapView removeOverlay:_routeOverlay];
    }
    
    // Update the ivar
    _routeOverlay = route.polyline;
    
    // Add it to the map
    [self.mapView addOverlay:_routeOverlay];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = [UIColor colorWithRed:(252.0 / 255.0) green:(76.0 / 255.0) blue:(2.0 / 255.0) alpha: 1];
    renderer.lineWidth = 4.0;
    return  renderer;
}


/* MOVE MAP */
- (void)moveMap:(CDVInvokedUrlCommand *)command
{
    
    if (!self.mapView || self.childView.hidden==YES)
    {
        return;
    }
    
    NSArray *move = command.arguments[0];
    
    for (int y = 0; y < move.count; y++)
    {
        NSDictionary *moveData = [move objectAtIndex:y];
        float xPosEnd = [[moveData objectForKey:@"xPosEnd"] floatValue];
        float yPosEnd = [[moveData objectForKey:@"yPosEnd"] floatValue];
        float heightEnd = [[moveData objectForKey:@"heightEnd"] floatValue];
        float widthEnd = [[moveData objectForKey:@"widthEnd"] floatValue];
        //NSLog(@"THE LOG SCORE : %f", xPosEnd);
        [UIView animateWithDuration:0.5f
                         animations:^{
                             [self.childView setFrame:CGRectMake(xPosEnd, yPosEnd, widthEnd, heightEnd)];
                         }
                         completion:nil
         ];
    }
}

- (void)addInnerShadows:(CDVInvokedUrlCommand *)command
{
    if (!self.mapView || self.childView.hidden==YES)
    {
        return;
    }
    
    NSArray *shadows = command.arguments[0];
    
    for (int y = 0; y < shadows.count; y++)
    {
        NSDictionary *shadowsData = [shadows objectAtIndex:y];
        float shadowOffsetX = [[shadowsData objectForKey:@"shadowOffsetX"] floatValue];
        float shadowOffsetY = [[shadowsData objectForKey:@"shadowOffsetY"] floatValue];
        float shadowRadius = [[shadowsData objectForKey:@"shadowRadius"] floatValue];
        float shadowOpacity = [[shadowsData objectForKey:@"shadowOpacity"] floatValue];
        float shadowStartX = [[shadowsData objectForKey:@"shadowStartX"] floatValue];
        float shadowStartY = [[shadowsData objectForKey:@"shadowStartY"] floatValue];
        float shadowHeight = [[shadowsData objectForKey:@"shadowHeight"] floatValue];
        float shadowWidth = [[shadowsData objectForKey:@"shadowWidth"] floatValue];
    
        /* ADD SHADOWS */
        UIView *mymapviewShadowTop=[[UIView alloc]initWithFrame:CGRectMake(shadowStartX, shadowStartY, shadowWidth, shadowHeight)];
    
        mymapviewShadowTop.backgroundColor=[UIColor colorWithWhite:1 alpha:1];
    
        [self.mapView addSubview:mymapviewShadowTop];
    
        /* SHADOW */
        mymapviewShadowTop.layer.masksToBounds = NO;
        mymapviewShadowTop.layer.shadowOffset = CGSizeMake(shadowOffsetX, shadowOffsetY);
        mymapviewShadowTop.layer.shadowRadius = shadowRadius;
        mymapviewShadowTop.layer.shadowOpacity = shadowOpacity;
    }
}


// Add a Close Button
- (void)addCloseButton:(CDVInvokedUrlCommand *)command
{
    if (!self.mapView || self.childView.hidden==YES)
    {
        return;
    }
    NSLog(@"CLOSE BUTTON");
    NSArray *btn = command.arguments[0];
    
    for (int y = 0; y < btn.count; y++)
    {
        NSDictionary *btnData = [btn objectAtIndex:y];
        float PosX = [[btnData objectForKey:@"PosX"] floatValue];
        float PosY = [[btnData objectForKey:@"PosY"] floatValue];
        
        CGRect  viewRect = CGRectMake(PosX, PosY, 40, 40);
        UIButton* closeBtn = [[UIButton alloc] initWithFrame:viewRect];
        
        closeBtn.backgroundColor = [UIColor colorWithRed:(0.0 / 255.0) green:(126.0 / 255.0) blue:(180.0 / 255.0) alpha: 1];
        closeBtn.layer.cornerRadius = 20;
        closeBtn.layer.borderColor = [UIColor colorWithWhite:1 alpha: 1].CGColor;
        closeBtn.layer.borderWidth = 3.0f;
        [self.mapView addSubview:closeBtn];
        
    }

}
 
// Add an image

- (void)addCoverImage:(CDVInvokedUrlCommand *)command
{
    if (!self.mapView || self.childView.hidden==YES)
    {
        return;
    }
    NSLog(@"IMAGE");
    NSArray *image = command.arguments[0];
    
    for (int y = 0; y < image.count; y++)
    {
        NSDictionary *imgData = [image objectAtIndex:y];
        float PosX = [[imgData objectForKey:@"PosX"] floatValue];
        float PosY = [[imgData objectForKey:@"PosY"] floatValue];
        
        CGRect  viewRect = CGRectMake(PosX, PosY, 76, 76);
        UIButton* closeBtn = [[UIButton alloc] initWithFrame:viewRect];
        
        closeBtn.backgroundColor = [UIColor colorWithRed:(221.0 / 255.0) green:(221.0 / 255.0) blue:(221.0 / 255.0) alpha: 1];
        closeBtn.layer.cornerRadius = 36;
        closeBtn.layer.borderColor = [UIColor colorWithWhite:1 alpha: 1].CGColor;
        closeBtn.layer.borderWidth = 3.0f;
        [self.mapView addSubview:closeBtn];
        
    }
    
}


- (void)hideMap:(CDVInvokedUrlCommand *)command
{
    if (!self.mapView || self.childView.hidden==YES)
    {
        return;
    }
    // disable location services, if we no longer need it.
    self.mapView.showsUserLocation = NO;
    self.childView.hidden = YES;
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}

/*
- (void)changeMapType:(CDVInvokedUrlCommand *)command
{
    if (!self.mapView || self.childView.hidden==YES)
    {
        return;
    }

    int mapType = ([command.arguments[0] objectForKey:@"mapType"]) ? [[command.arguments[0] objectForKey:@"mapType"] intValue] : 0;

    switch (mapType) {
        case 4:
            [self.mapView setMapType:MKMapTypeHybrid];
            break;
        case 2:
            [self.mapView setMapType:MKMapTypeSatellite];
            break;
        default:
            [self.mapView setMapType:MKMapTypeStandard];
            break;
    }

    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
}
 */

/*
- (void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion mapRegion;
    MKCoordinateSpan span;
    mapRegion.center = userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.2;
    mapRegion.span.longitudeDelta = 0.2;
    CLLocationCoordinate2D location;

    location.latitude = userLocation.coordinate.latitude;
    location.longitude = userLocation.coordinate.longitude;
    mapRegion.span = span;
    mapRegion.center = location;

    [self.mapView setRegion:mapRegion animated: YES];

}
*/

/*- (void)mapView:(MKMapView *)theMapView regionDidChangeAnimated: (BOOL)animated
{
    NSLog(@"region did change animated");
    float currentLat = theMapView.region.center.latitude;
    float currentLon = theMapView.region.center.longitude;
    float latitudeDelta = theMapView.region.span.latitudeDelta;
    float longitudeDelta = theMapView.region.span.longitudeDelta;

    NSString* jsString = nil;
    jsString = [[NSString alloc] initWithFormat:@"geo.onMapMove(\'%f','%f','%f','%f\');", currentLat,currentLon,latitudeDelta,longitudeDelta];
    [self.webView stringByEvaluatingJavaScriptFromString:jsString];
    [jsString autorelease];
}*/


- (MKAnnotationView *) mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>) annotation {

  if ([annotation class] != CDVAnnotation.class) {
    return nil;
  }

    CDVAnnotation *phAnnotation=(CDVAnnotation *) annotation;
    NSString *identifier=[NSString stringWithFormat:@"INDEX[%i]", phAnnotation.index];

    MKPinAnnotationView *annView = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:identifier];

    if (annView!=nil) return annView;

    annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];

    annView.animatesDrop=YES;
    annView.canShowCallout = YES;
    if ([phAnnotation.pinColor isEqualToString:@"120"])
        annView.pinColor = MKPinAnnotationColorGreen;
    else if ([phAnnotation.pinColor isEqualToString:@"270"])
        annView.pinColor = MKPinAnnotationColorPurple;
    else
        annView.pinColor = MKPinAnnotationColorRed;

    AsyncImageView* asyncImage = [[AsyncImageView alloc] initWithFrame:CGRectMake(0,0, 50, 32)];
    asyncImage.tag = 999;
    if (phAnnotation.imageURL)
    {
        NSURL *url = [[NSURL alloc] initWithString:phAnnotation.imageURL];
        [asyncImage loadImageFromURL:url];
    }
    else
    {
        [asyncImage loadDefaultImage];
    }

    annView.leftCalloutAccessoryView = asyncImage;


    if (self.buttonCallback && phAnnotation.index!=-1)
    {

        UIButton *myDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        myDetailButton.frame = CGRectMake(0, 0, 23, 23);
        myDetailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        myDetailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        myDetailButton.tag=phAnnotation.index;
        annView.rightCalloutAccessoryView = myDetailButton;
        [ myDetailButton addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    }

    if(phAnnotation.selected)
    {
        [self performSelector:@selector(openAnnotation:) withObject:phAnnotation afterDelay:1.0];
    }

    return annView;
}

-(void)openAnnotation:(id <MKAnnotation>) annotation
{
    [ self.mapView selectAnnotation:annotation animated:YES];

}

- (void) checkButtonTapped:(id)button
{
    UIButton *tmpButton = button;
    NSString* jsString = [NSString stringWithFormat:@"%@(\"%i\");", self.buttonCallback, tmpButton.tag];
    [self.webView stringByEvaluatingJavaScriptFromString:jsString];
}

- (void)dealloc
{
    if (self.mapView)
    {
        [ self.mapView removeAnnotations:mapView.annotations];
        [ self.mapView removeFromSuperview];
        self.mapView = nil;
    }
    if(self.imageButton)
    {
        [ self.imageButton removeFromSuperview];
        self.imageButton = nil;
    }
    if(childView)
    {
        [ self.childView removeFromSuperview];
        self.childView = nil;
    }
    self.buttonCallback = nil;
}

@end
