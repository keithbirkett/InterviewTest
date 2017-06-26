//
//  Encryption.h
//  FloowTest
//
//  Created by Keith Birkett on 25/06/2017.
//  Copyright © 2017 Keith Birkett. All rights reserved.
//

#ifndef Encryption_h
#define Encryption_h

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

@interface Encryption : NSObject
    +(void)setEncryptionKey:(const NSString *)key;
    +(NSData *)encrypt:(const NSData *)data;
    +(NSData *)decrypt:(const NSData *)data;
    +(NSData *)blowfish:(const NSData *)dataIn context:(CCOperation)encryptionType;
@end
#endif /* Encryption_h */
