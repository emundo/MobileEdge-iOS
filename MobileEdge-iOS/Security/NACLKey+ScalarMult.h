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

#import "NACLKey.h"

@interface NACLKey (ScalarMult)

/**
 * @discussion Multiply the key with a given other key using scalar multiplication
 * on curve25519. Uses libsodium/NaCl and is used for Diffie Hellman.
 * @param aKey - the key to multiply with.
 * @return a new key whose data is the result of the multiplication.
 */
- (instancetype) multWithKey: (NACLKey *) aKey;

@end
