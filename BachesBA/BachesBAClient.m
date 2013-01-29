//
//  BachesBAClient.m
//  BachesBA
//
//  Created by Nicolas Ameghino on 29/01/13.
//  Copyright (c) 2013 Nicolas Ameghino. All rights reserved.
//

#import "BachesBAClient.h"
#import "NAJSONRequestOperation.h"

#import <BlocksKit/BlocksKit.h>

@interface BachesBAClient ()
@property(nonatomic, strong) NSArray *sortedHoleTypes;
@end

@implementation BachesBAClient

static BachesBAClient *sharedInstance;

+(BachesBAClient*) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BachesBAClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://buenosairesbache.com/app/"]];
        [sharedInstance loadHoleTypes];
        [sharedInstance loadNeighbourhoods];
    });
    return sharedInstance;
}


-(void) loadHoleTypes {
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                      path:@"index.php"
                                                parameters:nil];
    AFJSONRequestOperation *op = [NAJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                     NSMutableDictionary *holeTypes = [NSMutableDictionary new];
                                                                                     
                                                                                     [JSON[@"delitos"] each:^(id sender) {
                                                                                         id identifier = sender[@"id"];
                                                                                         id name = sender[@"nombre"];
                                                                                         holeTypes[name] = identifier;
                                                                                     }];
                                                                                     
                                                                                     self.holeTypes = holeTypes;
                                                                                     
                                                                                 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                     NSLog(@"Error: %@", [error localizedDescription]);
                                                                                 }];
    [op start];
}

-(void) loadNeighbourhoods {
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                      path:@"barrios.php"
                                                parameters:nil];
    AFJSONRequestOperation *op = [NAJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                     NSMutableDictionary *neighbourhboods = [NSMutableDictionary new];
                                                                                     
                                                                                     [JSON[@"barrios"] each:^(id sender) {
                                                                                         id identifier = sender[@"id"];
                                                                                         id name = sender[@"nombre"];
                                                                                         neighbourhboods[name] = identifier;
                                                                                     }];
                                                                                     
                                                                                     self.neighbourhoods = neighbourhboods;
                                                                                 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                     NSLog(@"Error: %@", [error localizedDescription]);
                                                                                 }];
    [op start];
}



@end
