//
//  TAHelpViewController.m
//  Lesson Book
//
//  Created by Michael Toth on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAHelpViewController.h"

@interface TAHelpViewController ()

@end

@implementation TAHelpViewController
@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSString *help1FilePath = [[[NSBundle mainBundle] resourcePath]
                                      stringByAppendingPathComponent:@"help1.html"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:help1FilePath];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [webView loadRequest:request];

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSString *help1FilePath = [[[NSBundle mainBundle] resourcePath]
                               stringByAppendingPathComponent:@"help1.html"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:help1FilePath];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [webView loadRequest:request];

    
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
