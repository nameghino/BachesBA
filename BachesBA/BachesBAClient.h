//
//  BachesBAClient.h
//  BachesBA
//
//  Created by Nicolas Ameghino on 29/01/13.
//  Copyright (c) 2013 Nicolas Ameghino. All rights reserved.
//

#import "AFHTTPClient.h"

@interface BachesBAClient : AFHTTPClient


@property(nonatomic, strong) NSDictionary *neighbourhoods;
@property(nonatomic, strong) NSDictionary *holeTypes;

+(BachesBAClient*) sharedInstance;
-(NSArray*) sortedHoleTypes;

@end
