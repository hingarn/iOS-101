//
//  WikiMapsJSONParser.m
//  SkyrimMap
//
//  Created by Alex Ivlev on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IGN_JSONParser.h"

#define contentOnlyArticleUrl @"http://m.ign.com/articles/%@?content_only"
#define fullSiteArticleUrlTemplate @"http://www.ign.com/articles/%@"

@implementation IGN_JSONParser

+ (NSArray *) parseLatestArticles: (NSArray *) latestArticlesArray
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *articleInfo in latestArticlesArray) {
        NSString *publishDate = [articleInfo valueForKeyPath:@"metadata.publishDate"];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
        NSString *parsedDate = [publishDate stringByReplacingOccurrencesOfString:@":" 
                                                                      withString:@"" 
                                                                         options:0 
                                                                           range:NSMakeRange([publishDate length] - 5,5)];
        NSDate *convertedDate = [df dateFromString:parsedDate];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* compoNents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:convertedDate];
        double ti = [convertedDate timeIntervalSinceNow];
        publishDate = [IGN_JSONParser gh_stringForTimeInterval:ti includeSeconds:NO];

        NSString *month = [NSString stringWithFormat:@"%i", [compoNents month]];
        NSString *day = [parsedDate substringWithRange: NSMakeRange(8, 2)];
        if ([compoNents month] < 10) {
            month = [NSString stringWithFormat:@"0%@", month];
        }
        
        NSString *articleUrlString = [NSString stringWithFormat:@"%d/%@/%@/%@", [compoNents year], month, day, [articleInfo valueForKeyPath:@"metadata.slug"]];
        NSString *mDotArticleUrl = [NSString stringWithFormat: contentOnlyArticleUrl, articleUrlString];
        NSString *articleUrl = [NSString stringWithFormat:fullSiteArticleUrlTemplate, articleUrlString];
        NSString *articleTitle = [articleInfo valueForKeyPath:@"metadata.headline"];
        NSString *articleBlogrollImageUrl = nil;
        if ([[articleInfo valueForKeyPath: @"promo.promoImages"] count] > 0) {
            articleBlogrollImageUrl = [[[articleInfo valueForKeyPath: @"promo.promoImages"] objectAtIndex:0] valueForKey:@"url"];
        }
        
        NSDictionary *article = [[NSDictionary alloc] initWithObjectsAndKeys:mDotArticleUrl, @"mDotArticleUrl", articleUrl, @"fullSiteArticleUrl", articleTitle, @"articleTitle", publishDate, @"publishDate", articleBlogrollImageUrl, @"articleBlogrollImageUrl", nil];
        [resultArray addObject:article];
    }
    
    return [resultArray copy];
}






#define GHIntervalLocalize(key, defaultValue) NSLocalizedStringWithDefaultValue(key, tableName, bundle, defaultValue, nil)

+ (NSString *)gh_localizedStringForTimeInterval:(NSTimeInterval)interval includeSeconds:(BOOL)includeSeconds tableName:(NSString *)tableName bundle:(NSBundle *)bundle {
    NSTimeInterval intervalInSeconds = fabs(interval);
    double intervalInMinutes = round(intervalInSeconds/60.0);
    
    if (intervalInMinutes >= 0 && intervalInMinutes <= 1) {
        if (!includeSeconds) return intervalInMinutes <= 0 ? GHIntervalLocalize(@"LessThanAMinute", @"less than a minute ago") : GHIntervalLocalize(@"1Minute", @"1 minute ago");
        if (intervalInSeconds >= 0 && intervalInSeconds < 5) return [NSString stringWithFormat:GHIntervalLocalize(@"LessThanXSeconds", @"less than %d seconds ago"), 5];
        else if (intervalInSeconds >= 5 && intervalInSeconds < 10) return [NSString stringWithFormat:GHIntervalLocalize(@"LessThanXSeconds", @"less than %d seconds ago"), 10];
        else if (intervalInSeconds >= 10 && intervalInSeconds < 20) return [NSString stringWithFormat:GHIntervalLocalize(@"LessThanXSeconds", @"less than %d seconds ago"), 20];
        else if (intervalInSeconds >= 20 && intervalInSeconds < 40) return GHIntervalLocalize(@"HalfMinute", @"half a minute ago");
        else if (intervalInSeconds >= 40 && intervalInSeconds < 60) return GHIntervalLocalize(@"LessThanAMinute", @"less than a minute ago");
        else return GHIntervalLocalize(@"1Minute", @"1 minute ago");
    }
    else if (intervalInMinutes >= 2 && intervalInMinutes <= 44) return [NSString stringWithFormat:GHIntervalLocalize(@"XMinutes", @"%.0f minutes ago"), intervalInMinutes];
    else if (intervalInMinutes >= 45 && intervalInMinutes <= 89) return GHIntervalLocalize(@"About1Hour", @"about 1 hour ago");
    else if (intervalInMinutes >= 90 && intervalInMinutes <= 1439) return [NSString stringWithFormat:GHIntervalLocalize(@"AboutXHours", @"about %.0f hours ago"), round(intervalInMinutes/60.0)];
    else if (intervalInMinutes >= 1440 && intervalInMinutes <= 2879) return GHIntervalLocalize(@"1Day", @"1 day ago");
    else if (intervalInMinutes >= 2880 && intervalInMinutes <= 43199) return [NSString stringWithFormat:GHIntervalLocalize(@"XDays", @"%.0f days ago"), round(intervalInMinutes/1440.0)];
    else if (intervalInMinutes >= 43200 && intervalInMinutes <= 86399) return GHIntervalLocalize(@"About1Month", @"about 1 month ago");
    else if (intervalInMinutes >= 86400 && intervalInMinutes <= 525599) return [NSString stringWithFormat:GHIntervalLocalize(@"XMonths", @"%.0f months ago"), round(intervalInMinutes/43200.0)];
    else if (intervalInMinutes >= 525600 && intervalInMinutes <= 1051199) return GHIntervalLocalize(@"About1Year", @"about 1 year ago");
    else
        return [NSString stringWithFormat:GHIntervalLocalize(@"OverXYears", @"over %.0f years ago"), floor(intervalInMinutes/525600.0)];
}

+ (NSString *)gh_stringForTimeInterval:(NSTimeInterval)interval includeSeconds:(BOOL)includeSeconds {
	return [IGN_JSONParser gh_localizedStringForTimeInterval:interval includeSeconds:includeSeconds tableName:nil bundle:[NSBundle mainBundle]];
}

+ (NSString *)displayTimeWithSecond:(NSInteger)seconds
{
    NSInteger remindMinute = seconds / 60;
    NSInteger remindHours = remindMinute / 60;
    
    NSInteger remindMinutes = seconds - (remindHours * 3600);
    NSInteger remindMinuteNew = remindMinutes / 60;
    
    NSInteger remindSecond = seconds - (remindMinuteNew * 60) - (remindHours * 3600);
    NSString *result = nil;
    if (remindHours != 0) {
        result = [NSString stringWithFormat:@"%02d:%02d:%02d", remindHours, remindMinuteNew, remindSecond];
    } else {
        result = [NSString stringWithFormat:@"%02d:%02d", remindMinuteNew, remindSecond];
    }
    
    return result;
}

@end
