//
//  MOBAnonymizerSettings.h
//  MobileEdge
//
//  Created by Raphael Arias on 23/10/14.
//  Copyright (c) 2014 eMundo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MOBAnonymizerSettings <NSObject>

- (BOOL) whitelistDomainForSelfSignedCertificates: (NSURL *) aDomain;

- (BOOL) getValueForKey: (NSString *) aKey;

- (BOOL) setValue: (id) aValue
           forKey: (NSString *) aKey;

@end
