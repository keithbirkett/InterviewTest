//
//  Encryption.m
//  FloowTest
//
//  Created by Keith Birkett on 25/06/2017.
//  Copyright © 2017 Keith Birkett. All rights reserved.
//


#import "Encryption.h"

static NSData *blowfishKey;

@implementation Encryption

// Encrypt or decrypt the NSData that is passed in
// This is mainly apple magic code.
// setEncryptionKey MUST have been called
+(NSData *)blowfish:(const NSData *)data context:(CCOperation)encryptionType
{
    CCCryptorStatus ccStatus   = kCCSuccess;
    size_t          cryptBytes = 0;
    NSMutableData  *dataOut    = [NSMutableData dataWithLength:data.length + kCCBlockSizeBlowfish];
    
    ccStatus = CCCrypt( encryptionType,
                       kCCAlgorithmBlowfish,
                       kCCOptionPKCS7Padding | kCCOptionECBMode,
                       blowfishKey.bytes,
                       blowfishKey.length,
                       nil,
                       data.bytes,
                       data.length,
                       dataOut.mutableBytes,
                       dataOut.length,
                       &cryptBytes);
    
    if (ccStatus == kCCSuccess)
    {
        dataOut.length = cryptBytes;
    }
    else
    {
        dataOut = nil;
    }
    
    return dataOut;
}

// Set the encryption key
+(void)setEncryptionKey:(const NSString *)key
{
    blowfishKey = [key dataUsingEncoding:NSUTF8StringEncoding];
}

// Simple encrypt method
+(NSData *)encrypt:(const NSData *)data
{
    return [Encryption blowfish:data context:kCCEncrypt];
}

// Simple decrypt method
+(NSData *)decrypt:(const NSData *)data
{
    return [Encryption blowfish:data context:kCCDecrypt];
}

@end
