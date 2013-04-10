//
//  Cordova
//
//

#import "MapKit.h"
#import "CDVAnnotation.h"
#import "AsyncImageView.h"

#ifdef CORDOVA_FRAMEWORK
    // PhoneGap >= 1.2.0
    #import <Cordova/JSONKit.h>
#else
    // https://github.com/johnezang/JSONKit
    #import "JSONKit.h"
#endif

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
	self.childView = [[UIView alloc] init];
    self.mapView = [[MKMapView alloc] init];
    [self.mapView sizeToFit];
    self.mapView.delegate = self;
    self.mapView.multipleTouchEnabled   = YES;
    self.mapView.autoresizesSubviews    = YES;
    self.mapView.userInteractionEnabled = YES;
	self.mapView.showsUserLocation = YES;
	self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.childView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	self.imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
	[self.childView addSubview:self.mapView];
	[self.childView addSubview:self.imageButton];
    
    [ [ [ self viewController ] view ] addSubview:self.childView];
}

- (void)mapView:(MKMapView *)theMapView regionDidChangeAnimated: (BOOL)animated
{
    float currentLat = theMapView.region.center.latitude;
    float currentLon = theMapView.region.center.longitude;
    float latitudeDelta = theMapView.region.span.latitudeDelta;
    float longitudeDelta = theMapView.region.span.longitudeDelta;
    
    NSString* jsString = nil;
	jsString = [[NSString alloc] initWithFormat:@"geo.onMapMove(\'%f','%f','%f','%f\');", currentLat,currentLon,latitudeDelta,longitudeDelta];
	[self.webView stringByEvaluatingJavaScriptFromString:jsString];
	[jsString autorelease];
}

- (void)mapView:(MKMapView *)theMapView regionWillChangeAnimated: (BOOL)animated
{
    float currentLat = theMapView.region.center.latitude;
    float currentLon = theMapView.region.center.longitude;
    float latitudeDelta = theMapView.region.span.latitudeDelta;
    float longitudeDelta = theMapView.region.span.longitudeDelta;
    
    NSString* jsString = nil;
	jsString = [[NSString alloc] initWithFormat:@"geo.beforeMapMove(\'%f','%f','%f','%f\');", currentLat,currentLon,latitudeDelta,longitudeDelta];
	[self.webView stringByEvaluatingJavaScriptFromString:jsString];
	[jsString autorelease];
}

- (void)destroyMap:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
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
		[ self.imageButton removeTarget:self action:@selector(closeButton:) forControlEvents:UIControlEventTouchUpInside];
		self.imageButton = nil;
		
	}
	if(self.childView)
	{
		[ self.childView removeFromSuperview];
		self.childView = nil;
	}
    self.buttonCallback = nil;
}

- (void)clearMapPins:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
{
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (void)addMapPins:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
{
    
    NSArray *pins = [[arguments objectAtIndex:0] objectFromJSONString];
	
    for (int y = 0; y < pins.count; y++)
	{
		NSDictionary *pinData = [pins objectAtIndex:y];
		CLLocationCoordinate2D pinCoord = { [[pinData objectForKey:@"lat"] floatValue] , [[pinData objectForKey:@"lon"] floatValue] };
		NSString *title=[[pinData valueForKey:@"title"] description];
		NSString *subTitle=[[pinData valueForKey:@"subTitle"] description];
		NSString *imageURL=[[pinData valueForKey:@"imageURL"] description];
		NSString *pinColor=[[pinData valueForKey:@"pinColor"] description];
		NSInteger index=[[pinData valueForKey:@"index"] integerValue];
		BOOL selected = [[pinData valueForKey:@"selected"] boolValue];
        
		CDVAnnotation *annotation = [[CDVAnnotation alloc] initWithCoordinate:pinCoord index:index title:title subTitle:subTitle imageURL:imageURL];
		annotation.pinColor=pinColor;
		annotation.selected = selected;
        
		[self.mapView addAnnotation:annotation];
		[annotation release];
	}
}

/**
 * Set annotations and mapview settings
 */
- (void)setMapData:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;\
{
    if (!self.mapView)
	{
		[self createView];
	}
	
	// defaults
    CGFloat height = 480.0f;
    CGFloat offsetTop = 0.0f;
    
	if ([options objectForKey:@"height"])
	{
		height=[[options objectForKey:@"height"] floatValue];
	}
    if ([options objectForKey:@"offsetTop"])
	{
		offsetTop=[[options objectForKey:@"offsetTop"] floatValue];
	}
	if ([options objectForKey:@"buttonCallback"])
	{
		self.buttonCallback=[[options objectForKey:@"buttonCallback"] description];
	}
	
	CLLocationCoordinate2D centerCoord = { [[options objectForKey:@"lat"] floatValue] , [[options objectForKey:@"lon"] floatValue] };
	CLLocationDistance diameter = [[options objectForKey:@"diameter"] floatValue];
	
	CGRect webViewBounds = self.webView.bounds;
	
	CGRect mapBounds;
    mapBounds = CGRectMake(
                           webViewBounds.origin.x,
                           webViewBounds.origin.y + (offsetTop / 2),
                           webViewBounds.size.width,
                           webViewBounds.origin.y + height
                           );
    
	[self.childView setFrame:mapBounds];
	[self.mapView setFrame:mapBounds];
	
	MKCoordinateRegion region=[ self.mapView regionThatFits: MKCoordinateRegionMakeWithDistance(centerCoord,
                                                                                                diameter*(height / webViewBounds.size.width),
                                                                                                diameter*(height / webViewBounds.size.width))];
	[self.mapView setRegion:region animated:YES];
	
	CGRect frame = CGRectMake(285.0,12.0,  29.0, 29.0);
	
	[ self.imageButton setImage:[UIImage imageNamed:@"www/map-close-button.png"] forState:UIControlStateNormal];
	[ self.imageButton setFrame:frame];
	[ self.imageButton addTarget:self action:@selector(closeButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) closeButton:(id)button
{
	[ self hideMap:NULL withDict:NULL];
	NSString* jsString = [NSString stringWithFormat:@"%@(\"%i\");", self.buttonCallback,-1];
	[self.webView stringByEvaluatingJavaScriptFromString:jsString];
}

- (void)showMap:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
	if (!self.mapView)
	{
		[self createView];
	}
    
    // animates showing action
    self.childView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        
        self.childView.alpha = 1;
    } completion: ^(BOOL finished) {
        
    }];
    
	//self.childView.hidden = NO; //uncomment to go back to default behavior
	self.mapView.showsUserLocation = YES;
    
    // this closes annotation callouts and deselects them when the map is shown, a hacky way to close annotations after the jQuery popup closes
    for (NSObject<MKAnnotation> *annotation in [mapView selectedAnnotations]) {
        [mapView deselectAnnotation:(id <MKAnnotation>)annotation animated:NO];
    }
}


- (void)hideMap:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    if (!self.mapView || self.childView.hidden==YES)
	{
		return;
	}
	// disable location services, if we no longer need it.
	self.mapView.showsUserLocation = NO;
    
    // animates hiding action
    [UIView animateWithDuration:0.2 animations:^{
        self.childView.alpha = 0;
    } completion: ^(BOOL finished) {
        self.childView.hidden = YES;
    }];
    
	//self.childView.hidden = YES; // unmcomment to go back to default behavior
}


- (MKAnnotationView *) mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>) annotation {
    
    
    
    if ([annotation class] != CDVAnnotation.class) {
        return nil;
    }
    
	CDVAnnotation *phAnnotation=(CDVAnnotation *) annotation;
	NSString *identifier=[NSString stringWithFormat:@"INDEX[%i]", phAnnotation.index];
    
    // uncomment for original. Second allows for images and therefor custom colors
	MKPinAnnotationView *annView = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    //commented out to fix pin color cache issues. Uncomment to get back original functionality, whatever that is...
	//if (annView!=nil) return annView;
    
	annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    
    // uncomment to use normal animiations and restore defaults. Only works with MKPinAnnotationView, not MKAnnotationView
	annView.animatesDrop=YES;
    
    // change to yes to allow callouts on annotations
	annView.canShowCallout = YES;
    

    
	if ([phAnnotation.pinColor isEqualToString:@"green"])
        // original
         annView.pinColor = MKPinAnnotationColorGreen;
	else if ([phAnnotation.pinColor isEqualToString:@"purple"])
        // original
        annView.pinColor = MKPinAnnotationColorPurple;
	else ([phAnnotation.pinColor isEqualToString:@"red"])
        // original (this was also the end of the if statement, no else if, just default to red)
        annView.pinColor = MKPinAnnotationColorPurple;

    
	AsyncImageView* asyncImage = [[[AsyncImageView alloc] initWithFrame:CGRectMake(0,0, 50, 32)] autorelease];
	asyncImage.tag = 999;
	if (phAnnotation.imageURL)
	{
		NSURL *url = [[NSURL alloc] initWithString:phAnnotation.imageURL];
		[asyncImage loadImageFromURL:url];
		[ url release ];
	}
	else
	{
		//uncomment to allow default images for pins
        [asyncImage loadDefaultImage];
	}
    
	//uncomment to allow images for pins
    annView.leftCalloutAccessoryView = asyncImage;
    
    // uncomment all to allow the "more" button/chevron in the callout
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
    
    
    
	return [annView autorelease];
}

//when a pin is selected or deselected, do something
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    NSString *latitude = [[NSString alloc] initWithFormat:@"%f",view.annotation.coordinate.latitude];
    NSString *longitude = [[NSString alloc] initWithFormat:@"%f",view.annotation.coordinate.longitude];
    
    NSLog(@"Selected: %@%@%@",[view.annotation subtitle], latitude, longitude);
    
    NSString *annotationTapFunctionString = [NSString stringWithFormat:@"%s%@%s%@%s%@%s", "annotationTap('", [view.annotation subtitle], "','", latitude, "','", longitude, "')"];
    [self.webView stringByEvaluatingJavaScriptFromString:annotationTapFunctionString];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    //NSLog(@"De-Selected: %@",[view.annotation title]);
    NSString *annotationDeselectFunctionString = [NSString stringWithFormat:@"%s%@%s", "annotationDeselect('", [view.annotation subtitle], "')"];
    [self.webView stringByEvaluatingJavaScriptFromString:annotationDeselectFunctionString];
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
    [super dealloc];
}

@end