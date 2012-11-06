//
//  ImpressionistAppDelegate.m
//  Impressionist
//
//  Created by Stephanie Abascal on 1/24/09.
//  Copyright Stephanie Abascal 2009. All rights reserved.
//

#import "ImpressionistAppDelegate.h"
#import "RootViewController.h"

@implementation ImpressionistAppDelegate


@synthesize window;
@synthesize rootViewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    [window addSubview:[rootViewController view]];
    [window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication*)application {
}


- (void)dealloc {
    [rootViewController release];
    [window release];
	
    [super dealloc];
}

@end
