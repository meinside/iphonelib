//
//  XMLParsedTree.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 06. 30.
//
//  last update: 10.07.30.
//

#pragma once
#import <Foundation/Foundation.h>

#import "XMLParsedElement.h"

@interface XMLParsedTree : NSObject {

	XMLParsedElement* root;
}

- (id)initWithRootElement:(XMLParsedElement*)rootElement;

- (id)traverse:(NSArray*)names nameIndex:(NSInteger)index element:(XMLParsedElement*)element;

- (XMLParsedElement*)elementAtPath:(NSString*)path;

- (XMLParsedTree*)parsedTreeAtPath:(NSString*)path;

- (NSArray*)childrenAtPath:(NSString*)path;

- (NSDictionary*)namesAndValuesOfChildrenAtPath:(NSString*)path;

- (NSDictionary*)attributesAtPath:(NSString*)path;

- (NSString*)attributeValueOfName:(NSString*)attributeName atPath:(NSString*)path;

- (NSString*)valueAtPath:(NSString*)path;

- (NSString*)stringValue;
- (NSString*)stringValueWithEncoding:(NSStringEncoding)encoding;

+ (XMLParsedTree*)XMLParsedTreeWithRootElement:(XMLParsedElement*)rootElement;

@property (retain, nonatomic) XMLParsedElement* root;

@end
