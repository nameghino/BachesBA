//
//  NAJSONRequestOperation.m
//  BachesBA
//
//  Created by Nicolas Ameghino on 29/01/13.
//  Copyright (c) 2013 Nicolas Ameghino. All rights reserved.
//

#import "NAJSONRequestOperation.h"

@implementation NAJSONRequestOperation

+(NSSet *)acceptableContentTypes {
    return [[[super acceptableContentTypes] setByAddingObject:@"application/x-javascript"] setByAddingObject:@"text/html"];
}

@end
