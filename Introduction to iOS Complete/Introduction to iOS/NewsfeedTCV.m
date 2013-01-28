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
#import "ArticleVC.h"

#define currentGameId @"14235014"
#define relatedArticleUrlV3 @"http://apis.ign.com/article/v3/articles/search?q="
#define v3ArticleAPIBody @"{\"matchRule\":\"matchAll\",\"rules\":[{\"field\":\"legacyData.objectRelations\",\"condition\":\"is\",\"value\":\"%@\"}{\"field\":\"metadata.articleType\",\"condition\":\"is\",\"value\":\"article\"}],\"startIndex\":%i,\"count\":25,\"networks\":\"ign\",\"states\":\"published\",\"fields\":[\"metadata.headline\",\"metadata.publishDate\",\"metadata.slug\", \"promo\"]}"

static NSString *kNewsfeedCellIdentifier = @"NewsfeedCell";

@interface NewsfeedTCV ()
//private properties
@property (nonatomic, strong) NSArray *newsfeedArticles;
@property (nonatomic) int currentArticleIndex; 
@property (weak, nonatomic) IBOutlet UIButton *loadMoreButton;
@end

@implementation NewsfeedTCV
@synthesize newsfeedArticles = _newsfeedArticles;
@synthesize currentArticleIndex = _currentArticleIndex;
@synthesize loadMoreButton = _loadMoreButton;

- (IBAction)loadMore:(id)sender {
    [self retrieveLatestGameArticles]; 
}

- (void) setNewsfeedArticles:(NSArray *)newsfeedArticles
{
    if (_newsfeedArticles != newsfeedArticles) {
        _newsfeedArticles = newsfeedArticles;
        [self.tableView reloadData];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowArticleContent"]) {
        ArticleVC *vc = segue.destinationViewController;
        NSIndexPath *path = (NSIndexPath *)sender;
        vc.stringUrlToLoad = [[self.newsfeedArticles objectAtIndex: path.row] valueForKey:@"mDotArticleUrl"];
    }
}

- (void) retrieveLatestGameArticles
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *body = [[NSString stringWithFormat: v3ArticleAPIBody, currentGameId, self.currentArticleIndex] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:[relatedArticleUrlV3 stringByAppendingString:body]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        if ([data length] > 0) {
            NSError *error = nil;
            NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSArray *articleObjects = [json valueForKey:@"data"];
            NSArray *articles = [IGN_JSONParser parseLatestArticles:articleObjects];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.newsfeedArticles != nil) {
                    self.newsfeedArticles = [self.newsfeedArticles arrayByAddingObjectsFromArray:articles];
                } else {
                    self.newsfeedArticles = articles;
                }
                self.currentArticleIndex += 25;
            });
            
        } else {
            NSLog(@"error in request");
        }
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 80;
    [self retrieveLatestGameArticles];
    self.loadMoreButton.layer.cornerRadius = 10.0f;
    self.loadMoreButton.layer.masksToBounds = YES;
    self.loadMoreButton.layer.borderWidth = 1.0f;
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
    // Configure the cell...
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNewsfeedCellIdentifier];
    
    NSDictionary *article = [self.newsfeedArticles objectAtIndex:indexPath.row];
    cell.textLabel.text = [article valueForKey:@"articleTitle"];
    cell.detailTextLabel.text = [article valueForKey:@"publishDate"];
    
    UIImageView *cellimage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 88, 49)];
    [cell.contentView addSubview:cellimage];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[article valueForKey:@"articleBlogrollImageUrl"]]];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            cellimage.image = image;
        });
    });

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"ShowArticleContent" sender:indexPath];
}

@end
