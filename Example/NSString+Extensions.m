//
//  NSString+Extensions.m
//  Example
//
//  Created by Helmut Schottmüller on 17.07.19.
//  Copyright © 2019 NYTimes. All rights reserved.
//

#import "NSString+Extensions.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <CommonCrypto/CommonDigest.h>


#define MIME_KEY @"MimeTypeKey"
#define UTI_KEY @"UtiKey"
#define JPEG_KEY @"JpegKey"
#define IMAGE_KEY @"ImageKey"
#define HEIC_KEY @"HeicKey"
#define RAW_KEY @"RawKey"
#define VIDEO_KEY @"VideoKey"

static NSMutableDictionary *EXTENSION_CACHE;

@implementation  NSString(NSStringExtension)


+(void)setExtensionCacheKey:(NSString*)key value:(id)value extension:(NSString*)extension
{
	if (EXTENSION_CACHE == nil) {
		EXTENSION_CACHE = [NSMutableDictionary new];
	}
	if (EXTENSION_CACHE[extension]== nil) {
		[EXTENSION_CACHE setObject:[NSMutableDictionary new] forKey:extension];
	}
	[EXTENSION_CACHE[extension] setObject:value forKey:key];
}

+(id)valueForExtensionCacheKey:(NSString*)key extension:(NSString*)extension
{
	if (EXTENSION_CACHE[extension] == nil) {
		return nil;
	}
	if (EXTENSION_CACHE[extension][key] == nil) {
		return nil;
	}
	return EXTENSION_CACHE[extension][key];
}

+ (NSString*) stringWithUUID {
	CFUUIDRef	uuidObj = CFUUIDCreate(nil);
	NSString	*uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	return uuidString;
}

- (NSString*) fileMIMEType
{
	id cachedValue = [NSString valueForExtensionCacheKey:MIME_KEY extension:[self pathExtension]];
	if (cachedValue != nil) {
		return cachedValue;
	} else {
		CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[self pathExtension], NULL);
		CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
		[NSString setExtensionCacheKey:MIME_KEY value:(__bridge id)(MIMEType) extension:[self pathExtension]];
		CFRelease(UTI);
		return (__bridge_transfer NSString *)MIMEType;
	}
}

-(NSString*)fileUTI
{
	id cachedValue = [NSString valueForExtensionCacheKey:UTI_KEY extension:[self pathExtension]];
	if (cachedValue != nil) {
		return cachedValue;
	} else {
		CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[self pathExtension], NULL);
		[NSString setExtensionCacheKey:UTI_KEY value:(__bridge id)(UTI) extension:[self pathExtension]];
		return (__bridge_transfer NSString *)UTI;
	}
}

-(BOOL)isJPEGFile
{
	id cachedValue = [NSString valueForExtensionCacheKey:JPEG_KEY extension:[self pathExtension]];
	if (cachedValue != nil) {
		return [cachedValue boolValue];
	} else {
		CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[self pathExtension], NULL);
		if (UTTypeConformsTo(UTI,(CFStringRef) @"public.jpeg"))
		{
			[NSString setExtensionCacheKey:JPEG_KEY value:@(YES) extension:[self pathExtension]];
			CFRelease(UTI);
			return YES;
		}
		else
		{
			[NSString setExtensionCacheKey:JPEG_KEY value:@(NO) extension:[self pathExtension]];
			CFRelease(UTI);
			return NO;
		}
	}
}


- (BOOL)isImageFile
{
	id cachedValue = [NSString valueForExtensionCacheKey:IMAGE_KEY extension:[self pathExtension]];
	if (cachedValue != nil) {
		return [cachedValue boolValue];
	} else {
		CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[self pathExtension], NULL);
		if (UTTypeConformsTo(UTI,(CFStringRef) @"public.image"))
		{
			[NSString setExtensionCacheKey:IMAGE_KEY value:@(YES) extension:[self pathExtension]];
			CFRelease(UTI);
			return YES;
		}
		else
		{
			[NSString setExtensionCacheKey:IMAGE_KEY value:@(NO) extension:[self pathExtension]];
			CFRelease(UTI);
			return NO;
		}
	}
}

- (BOOL)isHEIFFile
{
	id cachedValue = [NSString valueForExtensionCacheKey:HEIC_KEY extension:[self pathExtension]];
	if (cachedValue != nil) {
		return [cachedValue boolValue];
	} else {
		CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[self pathExtension], NULL);
		if ([CFBridgingRelease(UTI) isEqualToString:@"public.heic"])
		{
			[NSString setExtensionCacheKey:HEIC_KEY value:@(YES) extension:[self pathExtension]];
			return YES;
		}
		else
		{
			[NSString setExtensionCacheKey:HEIC_KEY value:@(NO) extension:[self pathExtension]];
			return NO;
		}
	}
}


- (BOOL)isRawFile
{
	id cachedValue = [NSString valueForExtensionCacheKey:RAW_KEY extension:[self pathExtension]];
	if (cachedValue != nil) {
		return [cachedValue boolValue];
	} else {
		CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[self pathExtension], NULL);
		if (UTTypeConformsTo(UTI,(CFStringRef) @"public.camera-raw-image"))
		{
			[NSString setExtensionCacheKey:RAW_KEY value:@(YES) extension:[self pathExtension]];
			CFRelease(UTI);
			return YES;
		}
		else
		{
			[NSString setExtensionCacheKey:RAW_KEY value:@(NO) extension:[self pathExtension]];
			CFRelease(UTI);
			return NO;
		}
	}
}

- (BOOL)isVideoFile
{
	id cachedValue = [NSString valueForExtensionCacheKey:VIDEO_KEY extension:[self pathExtension]];
	if (cachedValue != nil) {
		return [cachedValue boolValue];
	} else {
		CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[self pathExtension], NULL);
		if (UTTypeConformsTo(UTI,(CFStringRef) @"public.movie"))
		{
			[NSString setExtensionCacheKey:VIDEO_KEY value:@(YES) extension:[self pathExtension]];
			CFRelease(UTI);
			return YES;
		}
		else
		{
			[NSString setExtensionCacheKey:VIDEO_KEY value:@(NO) extension:[self pathExtension]];
			CFRelease(UTI);
			return NO;
		}
		
	}
}

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
																																							 (__bridge CFStringRef)self,
																																							 NULL,
																																							 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
																																							 CFStringConvertNSStringEncodingToEncoding(encoding));
}

+(NSString*)stringfromDuration:(NSTimeInterval)duration
{
	long total = lroundf(duration);
	int hours = (int)total/ 3600;
	int minutes = (total % 3600) / 60;
	int seconds = total % 60;
	NSString *displayString = @"";
	
	if (hours>0) {
		displayString = [NSString stringWithFormat:@"%i:%02i:%02i",hours,minutes,seconds];
	} else {
		displayString = [NSString stringWithFormat:@"%i:%02i",minutes,seconds];
	}
	return displayString;
}

+ (NSString *)stringFromFileSize:(long long)theSize
{
	double floatSize = theSize;
	if (theSize<1023)
		return([NSString stringWithFormat:@"%qi bytes",theSize]);
	floatSize = floatSize / 1024;
	if (floatSize<1023)
		return([NSString stringWithFormat:@"%1.1f KB",floatSize]);
	floatSize = floatSize / 1024;
	if (floatSize<1023)
		return([NSString stringWithFormat:@"%1.1f MB",floatSize]);
	floatSize = floatSize / 1024;
	return([NSString stringWithFormat:@"%1.1f GB",floatSize]);
}

+ (NSString *)MD5:(NSString *)str
{
	const char *cStr = [str UTF8String];
	unsigned char result[16];
	CC_MD5( cStr, (unsigned int)strlen(cStr), result );
	return [NSString stringWithFormat:
					@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
					result[0], result[1], result[2], result[3],
					result[4], result[5], result[6], result[7],
					result[8], result[9], result[10], result[11],
					result[12], result[13], result[14], result[15]
					];
}

- (NSString *)stripTags:(NSString *)str
{
	NSMutableString *html = [NSMutableString stringWithCapacity:[str length]];
	
	NSScanner *scanner = [NSScanner scannerWithString:str];
	scanner.charactersToBeSkipped = NULL;
	NSString *tempText = nil;
	
	while (![scanner isAtEnd])
	{
		[scanner scanUpToString:@"<" intoString:&tempText];
		
		if (tempText != nil)
			[html appendString:[tempText stringByAppendingString:@" "]];
		
		[scanner scanUpToString:@">" intoString:NULL];
		
		if (![scanner isAtEnd])
			[scanner setScanLocation:[scanner scanLocation] + 1];
		
		tempText = nil;
	}
	
	return html;
}

- (NSString *)stringByAppendingPathComponents:(NSArray *)components
{
	__block NSMutableString *newString = [self mutableCopy];
	while ( [newString hasSuffix: @"/"] )
		[newString deleteCharactersInRange: NSMakeRange([newString length]-1,1)];
	[components enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
		while ([obj hasPrefix:@"/"]) obj = [obj substringFromIndex:1];
		while ([obj hasSuffix:@"/"]) obj = [obj substringToIndex:[obj length]-1];
		newString = [NSMutableString stringWithFormat:@"%@/%@", newString, obj];
	}];
	return newString;
}

- (NSString *)decodeHTMLEntities {
	if ([self rangeOfString:@"&"].location == NSNotFound) {
		return self;
	} else {
		NSMutableString *escaped = [NSMutableString stringWithString:self];
		NSArray *codes = [NSArray arrayWithObjects:
											@"&nbsp;", @"&iexcl;", @"&cent;", @"&pound;", @"&curren;", @"&yen;", @"&brvbar;",
											@"&sect;", @"&uml;", @"&copy;", @"&ordf;", @"&laquo;", @"&not;", @"&shy;", @"&reg;",
											@"&macr;", @"&deg;", @"&plusmn;", @"&sup2;", @"&sup3;", @"&acute;", @"&micro;",
											@"&para;", @"&middot;", @"&cedil;", @"&sup1;", @"&ordm;", @"&raquo;", @"&frac14;",
											@"&frac12;", @"&frac34;", @"&iquest;", @"&Agrave;", @"&Aacute;", @"&Acirc;",
											@"&Atilde;", @"&Auml;", @"&Aring;", @"&AElig;", @"&Ccedil;", @"&Egrave;",
											@"&Eacute;", @"&Ecirc;", @"&Euml;", @"&Igrave;", @"&Iacute;", @"&Icirc;", @"&Iuml;",
											@"&ETH;", @"&Ntilde;", @"&Ograve;", @"&Oacute;", @"&Ocirc;", @"&Otilde;", @"&Ouml;",
											@"&times;", @"&Oslash;", @"&Ugrave;", @"&Uacute;", @"&Ucirc;", @"&Uuml;", @"&Yacute;",
											@"&THORN;", @"&szlig;", @"&agrave;", @"&aacute;", @"&acirc;", @"&atilde;", @"&auml;",
											@"&aring;", @"&aelig;", @"&ccedil;", @"&egrave;", @"&eacute;", @"&ecirc;", @"&euml;",
											@"&igrave;", @"&iacute;", @"&icirc;", @"&iuml;", @"&eth;", @"&ntilde;", @"&ograve;",
											@"&oacute;", @"&ocirc;", @"&otilde;", @"&ouml;", @"&divide;", @"&oslash;", @"&ugrave;",
											@"&uacute;", @"&ucirc;", @"&uuml;", @"&yacute;", @"&thorn;", @"&yuml;", nil];
		
		NSUInteger i, count = [codes count];
		
		// Html
		for (i = 0; i < count; i++) {
			NSRange range = [self rangeOfString:[codes objectAtIndex:i]];
			if (range.location != NSNotFound) {
				[escaped replaceOccurrencesOfString:[codes objectAtIndex:i]
																 withString:[NSString stringWithFormat:@"%C", (unsigned short) (160 + i)]
																		options:NSLiteralSearch
																			range:NSMakeRange(0, [escaped length])];
			}
		}
		
		// The following five are not in the 160+ range
		
		// @"&amp;"
		NSRange range = [self rangeOfString:@"&amp;"];
		if (range.location != NSNotFound) {
			[escaped replaceOccurrencesOfString:@"&amp;"
															 withString:[NSString stringWithFormat:@"%C", (unsigned short) 38]
																	options:NSLiteralSearch
																		range:NSMakeRange(0, [escaped length])];
		}
		
		// @"&lt;"
		range = [self rangeOfString:@"&lt;"];
		if (range.location != NSNotFound) {
			[escaped replaceOccurrencesOfString:@"&lt;"
															 withString:[NSString stringWithFormat:@"%C", (unsigned short) 60]
																	options:NSLiteralSearch
																		range:NSMakeRange(0, [escaped length])];
		}
		
		// @"&gt;"
		range = [self rangeOfString:@"&gt;"];
		if (range.location != NSNotFound) {
			[escaped replaceOccurrencesOfString:@"&gt;"
															 withString:[NSString stringWithFormat:@"%C", (unsigned short) 62]
																	options:NSLiteralSearch
																		range:NSMakeRange(0, [escaped length])];
		}
		
		// @"&apos;"
		range = [self rangeOfString:@"&apos;"];
		if (range.location != NSNotFound) {
			[escaped replaceOccurrencesOfString:@"&apos;"
															 withString:[NSString stringWithFormat:@"%C", (unsigned short) 39]
																	options:NSLiteralSearch
																		range:NSMakeRange(0, [escaped length])];
		}
		
		// @"&quot;"
		range = [self rangeOfString:@"&quot;"];
		if (range.location != NSNotFound) {
			[escaped replaceOccurrencesOfString:@"&quot;"
															 withString:[NSString stringWithFormat:@"%C", (unsigned short) 34]
																	options:NSLiteralSearch
																		range:NSMakeRange(0, [escaped length])];
		}
		
		// Decimal & Hex
		NSRange start, finish, searchRange = NSMakeRange(0, [escaped length]);
		i = 0;
		
		while (i < [escaped length]) {
			start = [escaped rangeOfString:@"&#"
														 options:NSCaseInsensitiveSearch
															 range:searchRange];
			
			finish = [escaped rangeOfString:@";"
															options:NSCaseInsensitiveSearch
																range:searchRange];
			
			if (start.location != NSNotFound && finish.location != NSNotFound &&
					finish.location > start.location) {
				NSRange entityRange = NSMakeRange(start.location, (finish.location - start.location) + 1);
				NSString *entity = [escaped substringWithRange:entityRange];
				NSString *value = [entity substringWithRange:NSMakeRange(2, [entity length] - 2)];
				
				[escaped deleteCharactersInRange:entityRange];
				
				if ([value hasPrefix:@"x"]) {
					unsigned tempInt = 0;
					NSScanner *scanner = [NSScanner scannerWithString:[value substringFromIndex:1]];
					[scanner scanHexInt:&tempInt];
					[escaped insertString:[NSString stringWithFormat:@"%C", (unsigned short) tempInt] atIndex:entityRange.location];
				} else {
					[escaped insertString:[NSString stringWithFormat:@"%C", (unsigned short) [value intValue]] atIndex:entityRange.location];
				} i = start.location;
			} else { i++; }
			searchRange = NSMakeRange(i, [escaped length] - i);
		}
		
		return escaped;    // Note this is autoreleased
	}
}


- (NSString *)encodeHTMLEntities {
	NSMutableString *encoded = [NSMutableString stringWithString:self];
	
	// @"&amp;"
	NSRange range = [self rangeOfString:@"&"];
	if (range.location != NSNotFound) {
		[encoded replaceOccurrencesOfString:@"&"
														 withString:@"&amp;"
																options:NSLiteralSearch
																	range:NSMakeRange(0, [encoded length])];
	}
	
	// @"&lt;"
	range = [self rangeOfString:@"<"];
	if (range.location != NSNotFound) {
		[encoded replaceOccurrencesOfString:@"<"
														 withString:@"&lt;"
																options:NSLiteralSearch
																	range:NSMakeRange(0, [encoded length])];
	}
	
	// @"&gt;"
	range = [self rangeOfString:@">"];
	if (range.location != NSNotFound) {
		[encoded replaceOccurrencesOfString:@">"
														 withString:@"&gt;"
																options:NSLiteralSearch
																	range:NSMakeRange(0, [encoded length])];
	}
	
	// @"&quot;"
	range = [self rangeOfString:@"\""];
	if (range.location != NSNotFound) {
		[encoded replaceOccurrencesOfString:@"\""
														 withString:@"&quot;"
																options:NSLiteralSearch
																	range:NSMakeRange(0, [encoded length])];
	}
	
	return encoded;
}

-(CGSize)sizeWithFont:(UIFont*)font maxSize:(CGSize)maxSize paragraphStyle:(NSLineBreakMode)lineBreakMode
{
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.lineBreakMode = lineBreakMode;
	CGSize labelSize = ([self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle} context:nil]).size;
	labelSize = CGSizeMake(ceil(labelSize.width), ceil(labelSize.height));
	return labelSize;
}

@end
