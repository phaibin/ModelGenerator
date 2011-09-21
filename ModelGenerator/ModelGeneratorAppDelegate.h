//
//  MyGeneratorAppDelegate.h
//  MyGenerator
//
//  Created by  on 11-9-2.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ModelGeneratorAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    NSTextView *variantsTextView;
    NSTextView *headerTextView;
    NSTextView *implementTextView;
    
    NSMutableArray *assignTypes;
    NSMutableArray *copyTypes;
    NSString *implementTemplate;
}

@property (assign) IBOutlet NSWindow *window;
@property (retain) NSMutableArray *variants;

@property (assign) IBOutlet NSTextView *variantsTextView;
@property (assign) IBOutlet NSTextView *headerTextView;
@property (assign) IBOutlet NSTextView *implementTextView;

- (IBAction)generate:(id)sender;

@end
