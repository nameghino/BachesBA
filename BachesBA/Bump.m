//
//  Bump.m
//  BachesBA
//
//  Created by Nicolas Ameghino on 29/01/13.
//  Copyright (c) 2013 Nicolas Ameghino. All rights reserved.
//

#import "Bump.h"

@interface Bump ()

@property(nonatomic, strong) NSDictionary* bumpDictionary;

@end

@implementation Bump

+(Bump*) bumpWithDictionary:(NSDictionary*) dictionary {
    Bump *b = [Bump new];
    b.bumpDictionary = dictionary;
    return b;
}

-(id)valueForKey:(NSString *)key {
    return self.bumpDictionary[key];
}

-(CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake([self[@"lat"] doubleValue], [self[@"lng"] doubleValue]);
}

-(NSString *)title {
    return [self[@"direccion"] componentsSeparatedByString:@","][0];
}

-(NSString *)subtitle {
    return [NSString stringWithFormat: @"\"%@\" -%@", self[@"tipodelito"], self[@"nombre_usuario"]];
}

-(BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[Bump class]]) return NO;
    return [self[@"id"] integerValue] == [object[@"id"] integerValue];
}

- (id)objectForKeyedSubscript: (id)key {
    return self.bumpDictionary[key];
}

@end
