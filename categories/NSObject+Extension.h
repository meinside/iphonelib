//
//  NSObject+Extension.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 11. 10. 19.
//
//  last update: 12.04.30.
//

#pragma once
#import <Foundation/Foundation.h>


@interface NSObject (NSObjectExtension)

/**
 * return all collectable properties of this object (including super classes' properties)
 * 
 */
- (NSDictionary*)propertiesDictionary;

/**
 * return all methods' names of this object
 * 
 */
- (NSArray*)methodsArray;

@end
