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

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *url = [NSURL URLWithString:self.stringUrlToLoad];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webview loadRequest:request];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Current Article";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
