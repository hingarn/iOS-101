//
//  WikiMapsJSONParser.h
//  SkyrimMap
//
//  Created by Alex Ivlev on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGN_JSONParser : NSObject
+ (NSArray *) parseLatestArticles: (NSArray *) latestArticlesArray;
@end
