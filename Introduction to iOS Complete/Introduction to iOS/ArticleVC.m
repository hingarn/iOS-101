//
//  ArticleVC.m
//  Introduction to iOS
//
//  Created by Alexey Ivlev on 7/31/12.
//  Copyright (c) 2012 Alexey Ivlev. All rights reserved.
//

#import "ArticleVC.h"
#import "SVProgressHUD.h"

@interface ArticleVC ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@end

@implementation ArticleVC
@synthesize webview;
@synthesize stringUrlToLoad = _stringUrlToLoad;

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD showWithStatus:@"Loading..."];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *url = [NSURL URLWithString:self.stringUrlToLoad];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webview loadRequest:request];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Current Article";
}

- (void)viewDidUnload
{
    [self setWebview:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
