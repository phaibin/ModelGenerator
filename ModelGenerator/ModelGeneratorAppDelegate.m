//
//  MyGeneratorAppDelegate.m
//  MyGenerator
//
//  Created by  on 11-9-2.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ModelGeneratorAppDelegate.h"

NSString *const CBTypeIdentifier = @"type";
NSString *const CBNameIdentifier = @"name";

@interface ModelGeneratorAppDelegate (Private)

- (void)parseVariants;

@end

@implementation ModelGeneratorAppDelegate

@synthesize window;
@synthesize variants = _variants;
@synthesize variantsTextView;
@synthesize headerTextView;
@synthesize implementTextView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self.variantsTextView setFont:[NSFont systemFontOfSize:12]];
    [self.headerTextView setFont:[NSFont systemFontOfSize:12]];
    [self.implementTextView setFont:[NSFont systemFontOfSize:12]];
    
    self.variants = [[[NSMutableArray alloc] init] autorelease];
    assignTypes = [[NSMutableArray alloc] initWithObjects:@"int", @"float", @"double", nil];
    copyTypes = [[NSMutableArray alloc] initWithObjects:@"NSString", nil];
    implementTemplate = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"implement" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)dealloc
{
    [_variants release];
    [assignTypes release];
    [copyTypes release];
    [implementTemplate release];
    [super dealloc];
}

- (IBAction)generate:(id)sender 
{
    [self parseVariants];
    
    if ([self.variants count] > 0) {
        NSMutableString *header = [NSMutableString string];
        NSMutableString *synthesize = [NSMutableString string];
        NSMutableString *initName = [NSMutableString stringWithString:@"- (id)initWith"];
        NSMutableString *initContent = [NSMutableString string];
        NSMutableString *dealloc = [NSMutableString string];
        NSMutableString *implement = [NSMutableString stringWithString:implementTemplate];
        
        for (int i=0; i<[self.variants count]; i++) {
            NSDictionary *dict = [self.variants objectAtIndex:i];
            NSString *type = [dict objectForKey:CBTypeIdentifier];
            NSString *name = [dict objectForKey:CBNameIdentifier];
            if (type && ![type isEqualToString:@""] && name && ![name isEqualToString:@""]) {
                if ([assignTypes containsObject:type]) {
                    [header appendFormat:@"@property (assign) %@ %@;\n", type, name];
                    if (i == 0)
                        [initName appendFormat:@"%@:(%@)a%@", [name capitalizedString], type, [name capitalizedString]];
                    else 
                        [initName appendFormat:@" %@:(%@)a%@", name, type, [name capitalizedString]];
                }
                else {
                    if ([copyTypes containsObject:type])
                        [header appendFormat:@"@property (copy) %@ *%@;\n", type, name];
                    else
                        [header appendFormat:@"@property (retain) %@ *%@;\n", type, name];
                    if (i == 0)
                        [initName appendFormat:@"%@:(%@ *)a%@", [name capitalizedString], type, [name capitalizedString]];
                    else
                        [initName appendFormat:@" %@:(%@ *)a%@", name, type, [name capitalizedString]];
                    [dealloc appendFormat:@"    [_%@ release];\n", name];
                }
                
                [synthesize appendFormat:@"@synthesize %@ = _%@;\n", name, name];
                [initContent appendFormat:@"        self.%@ = a%@;\n", name, [name capitalizedString]];
            }
        }
        
        [header appendFormat:@"\n%@;", initName];
        
        [implement replaceOccurrencesOfString:@"$SynthesizeString$" withString:synthesize options:NSCaseInsensitiveSearch range:NSMakeRange(0, [implement length])];
        [implement replaceOccurrencesOfString:@"$InitNameString$" withString:initName options:NSCaseInsensitiveSearch range:NSMakeRange(0, [implement length])];
        [implement replaceOccurrencesOfString:@"$InitContentString$" withString:initContent options:NSCaseInsensitiveSearch range:NSMakeRange(0, [implement length])];
        [implement replaceOccurrencesOfString:@"$DeallocString$" withString:dealloc options:NSCaseInsensitiveSearch range:NSMakeRange(0, [implement length])];
        
        [self.headerTextView setString:[NSString stringWithString:header]];
        [self.implementTextView setString:[NSString stringWithString:implement]];
        
        [self.headerTextView scrollToBeginningOfDocument:nil];
        [self.implementTextView scrollToBeginningOfDocument:nil];
    }
}

- (void)parseVariants
{
    [self.variants removeAllObjects];
    NSArray *variantsString = [self.variantsTextView.string componentsSeparatedByString:@"\n"];
    for (NSString *s in variantsString) {
        if (s && ![s isEqualToString:@""]) {
            NSArray *variantsPair = [s componentsSeparatedByString:@" "];      
            if ([variantsPair count] == 2) {
                NSString *type = [variantsPair objectAtIndex:0];
                NSMutableString *name = [NSMutableString stringWithString:[variantsPair objectAtIndex:1]];
                [name replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0,  [name length])];
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:type, @"type", name, @"name", nil];
                [self.variants addObject:dict];
                [dict release];
            }
        }
    }
}

@end
