//
//  BPUUID.m
//  Skates
//
//  Created by Jon Olson on 2/3/10.
//  Copyright 2010 Ballistic Pigeon, LLC. All rights reserved.
//

#import "BPUUID.h"


@interface BPUUID (Private)

@end

@implementation BPUUID

#pragma mark -
#pragma mark Construction and deallocation

+ (BPUUID *)UUID {
	return [[[self alloc] init] autorelease];
}

+ (BPUUID *)UUIDWithCFUUID:(CFUUIDRef)uuid {
	return [[[self alloc] initWithCFUUID:uuid] autorelease];
}

+ (BPUUID *)UUIDWithString:(NSString *)uuidString {
	return [[[self alloc] initWithString:uuidString] autorelease];
}

+ (BPUUID *)UUIDWithBytes:(NSData *)uuidBytes {
	return [[[self alloc] initWithBytes:uuidBytes] autorelease];
}

- (id)init {
	if (self = [super init]) {
		CFUUID = CFUUIDCreate(NULL);
	}
	
	return self;
}

- (id)initWithCFUUID:(CFUUIDRef)uuid {
	if (self = [super init]) {
		CFRetain(uuid);
		CFUUID = uuid;
	}
	
	return self;
}

- (id)initWithString:(NSString *)uuidString {
	if (self = [super init]) {
		CFUUID = CFUUIDCreateFromString(NULL, (CFStringRef)uuidString);
        if (!CFUUID) {
            [self release];
            return  nil;
        }
	}
	
	return self;
}

- (id)initWithBytes:(NSData *)uuidBytes {
	if (self = [super init]) {
		CFUUIDBytes bytes;
        if ([uuidBytes length] != sizeof(bytes)) {
            [self release];
            return nil;
        }
		[uuidBytes getBytes:&bytes];
		CFUUID = CFUUIDCreateFromUUIDBytes(NULL, bytes);
        if (!CFUUID) {
            [self release];
            return nil;
        }
	}
	
	return self;
}

- (void)dealloc {
    if (CFUUID)
        CFRelease(CFUUID);
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

@synthesize CFUUID;

#pragma mark -
#pragma mark UUID Represnetations

- (NSString *)stringRepresentation {
	NSString *stringRep = (NSString *)CFUUIDCreateString(NULL, CFUUID);
	return [stringRep autorelease];
}

- (NSData *)byteRepresentation {
	CFUUIDBytes bytes = CFUUIDGetUUIDBytes(CFUUID);
	return [NSData dataWithBytes:&bytes length:sizeof(bytes)];
}

#pragma mark -
#pragma mark Hashing and equality

- (NSUInteger)hash {
#if __LP64__
    union {
        CFUUIDBytes bytes;
        uint64_t longs[2];
    } onion;
    
    onion.bytes = CFUUIDGetUUIDBytes(CFUUID);
    
    return onion.longs[0] ^ onion.longs[1];    
#else
    union {
        CFUUIDBytes bytes;
        uint32_t longs[4];
    } onion;
    
    onion.bytes = CFUUIDGetUUIDBytes(CFUUID);
    
    return onion.longs[0] ^ onion.longs[1] ^ onion.longs[2] ^ onion.longs[3];
#endif
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]])
        return NO;
    
    BPUUID *other = object;
    
    CFUUIDBytes myBytes = CFUUIDGetUUIDBytes(CFUUID);
    CFUUIDBytes otherBytes = CFUUIDGetUUIDBytes(other.CFUUID);
    
    return (memcmp(&myBytes, &otherBytes, sizeof(myBytes)) == 0);
}

#pragma mark -
#pragma mark Description

- (NSString *)description {
	return [self stringRepresentation];
}

#pragma mark -
#pragma mark NSCoding implementation

- (id)initWithCoder:(NSCoder *)decoder {
	NSString *uuidString = [decoder decodeObjectForKey:@"UUID"];
	return [self initWithString:uuidString];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:[self stringRepresentation] forKey:@"UUID"];
}

#pragma mark -
#pragma mark NSCopying implementation

- (id)copyWithZone:(NSZone *)zone {
    return [[BPUUID allocWithZone:zone] initWithCFUUID:CFUUID];
}

@end
