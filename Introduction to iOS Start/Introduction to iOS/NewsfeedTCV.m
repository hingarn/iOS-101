//
//  NewsfeedTCV.m
//  Introduction to iOS
//
//  Created by Alexey Ivlev on 7/30/12.
//  Copyright (c) 2012 Alexey Ivlev. All rights reserved.
//

#import "NewsfeedTCV.h"
#import "IGN_JSONParser.h"
#import <QuartzCore/QuartzCore.h>

#define currentGameId @"14235014"
#define relatedArticleUrlV3 @"http://apis.ign.com/article/v3/articles/search?q="
#define v3ArticleAPIBody @"{\"matchRule\":\"matchAll\",\"rules\":[{\"field\":\"legacyData.objectRelations\",\"condition\":\"is\",\"value\":\"%@\"}{\"field\":\"metadata.articleType\",\"condition\":\"is\",\"value\":\"article\"}],\"startIndex\":%i,\"count\":25,\"networks\":\"ign\",\"states\":\"published\",\"fields\":[\"metadata.headline\",\"metadata.publishDate\",\"metadata.slug\", \"promo\"]}"

static NSString *kNewsfeedCellIdentifier = @"NewsfeedCell";

@interface NewsfeedTCV ()
//private properties
@property (nonatomic, strong) NSArray *newsfeedArticles;
@property (nonatomic) int currentArticleIndex;
@end

@implementation NewsfeedTCV
@synthesize newsfeedArticles = _newsfeedArticles;
@synthesize currentArticleIndex = _currentArticleIndex;


- (void) setNewsfeedArticles:(NSArray *)newsfeedArticles
{
    if (_newsfeedArticles != newsfeedArticles) {
        _newsfeedArticles = newsfeedArticles;
        [self.tableView reloadData];
    }
}

- (void) retrieveLatestGameArticles
{
    NSString *body = [[NSString stringWithFormat: v3ArticleAPIBody, currentGameId, self.currentArticleIndex] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:[relatedArticleUrlV3 stringByAppendingString:body]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if ([data length] > 0) {
        NSError *error = nil;
        NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSArray *articleObjects = [json valueForKey:@"data"];
        NSArray *articles = [IGN_JSONParser parseLatestArticles:articleObjects];
        self.newsfeedArticles = articles;
        
    } else {
        NSLog(@"error in request");
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self retrieveLatestGameArticles];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.newsfeedArticles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNewsfeedCellIdentifier];
    // Configure the cell...
    
    UIImageView *cellimage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 88, 49)];
    [cell.contentView addSubview:cellimage];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
