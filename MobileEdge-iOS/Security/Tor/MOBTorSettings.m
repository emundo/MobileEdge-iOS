/*
 * Copyright (c) 2014 eMundo
 * All Rights Reserved.
 *
 * This file is part of MobileEdge-iOS.
 * MobileEdge-iOS is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MobileEdge-iOS is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with MobileEdge-iOS.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Created by Raphael Arias on 8/18/14.
 */

#import "MOBTorSettings.h"

@implementation MOBTorSettings

- (void) whitelistDomainForSelfSignedCertificates: (NSString *) aDomain
{
    if (!self.settings)
    {
        self.settings = [NSMutableDictionary dictionary];
    }
    if (!self.settings[@"sslWhitelistedDomains"])
    {
        self.settings[@"sslWhitelistedDomains"] = [NSMutableArray arrayWithCapacity: 1];
    }
    [self.settings[@"sslWhitelistedDomains"] addObject: aDomain];
}

- (id) getValueForKey: (NSString *) aKey
{
    return self.settings[aKey];
}

@end
