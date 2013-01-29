//
//  Bump.h
//  BachesBA
//
//  Created by Nicolas Ameghino on 29/01/13.
//  Copyright (c) 2013 Nicolas Ameghino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Bump : NSObject <MKAnnotation>

+ (Bump*) bumpWithDictionary:(NSDictionary*) dictionary;
- (id)objectForKeyedSubscript: (id)key;

@end
