//
//  XMLParsedElement.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 06. 30.
//
//  last update: 10.07.30.
//

#pragma once
#import <Foundation/Foundation.h>


@interface XMLParsedElement : NSObject {

	NSString* name;
	NSString* value;
	NSMutableDictionary* attributes;
	
	XMLParsedElement* parent;
	NSMutableArray* children;
	NSMutableDictionary* childrenNameIndex;
}

- (id)initWithName:(NSString*)aName value:(NSString*)nilIfNone;

- (void)addAttributeWithKey:(NSString*)aKey andValue:(NSString*)aValue;
- (void)addChild:(XMLParsedElement*)aChild;
- (BOOL)hasChild;
- (XMLParsedElement*)childWithName:(NSString*)aName;
- (NSString*)valueOfChildWithName:(NSString*)aName;

- (NSString*)stringRepresentationWithTab:(NSInteger)tabSize;
- (NSString*)stringRepresentation;

@property (copy, nonatomic) NSString* name;
@property (copy, nonatomic) NSString* value;
@property (retain, nonatomic) NSMutableDictionary* attributes;
@property (retain, nonatomic) XMLParsedElement* parent;
@property (retain, nonatomic) NSMutableArray* children;
@end
