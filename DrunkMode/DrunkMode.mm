//
//  DrunkMode.mm
//  DrunkMode
//
//  Created by Qusic on 4/13/13.
//  Copyright (c) 2013 Qusic. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>
#import "CaptainHook/CaptainHook.h"
#import "Resources.h"

// Objective-C runtime hooking using CaptainHook:
//   1. declare class using CHDeclareClass()
//   2. load class using CHLoadClass() or CHLoadLateClass() in CHConstructor
//   3. hook method using CHOptimizedMethod()
//   4. register hook using CHHook() in CHConstructor
//   5. (optionally) call old method using CHSuper()

#define PreferencesPlist @"/var/mobile/Library/Preferences/me.qusic.drunkmode.plist"
#define DrunkModeKey @"DrunkMode"

static BOOL getDrunkMode()
{
    NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:PreferencesPlist];
    return [[preferences objectForKey:DrunkModeKey]boolValue];
}
static void setDrunkMode(BOOL value)
{
    NSMutableDictionary *preferences = [NSMutableDictionary dictionary];
    [preferences addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PreferencesPlist]];
    [preferences setObject:[NSNumber numberWithBool:value] forKey:DrunkModeKey];
    [preferences writeToFile:PreferencesPlist atomically:YES];
}

CHDeclareClass(CKTranscriptController)
CHOptimizedMethod(1, self, void, CKTranscriptController, messageEntryViewSendButtonHit, id, messageEntryView)
{
    if (getDrunkMode()) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Drunk Mode"
                                                           message:@"Go Home, You Are Drunk!"
                                                          delegate:nil
                                                 cancelButtonTitle:@"What?"
                                                 otherButtonTitles:nil];
        [alertView show];
    } else {
        CHSuper(1, CKTranscriptController, messageEntryViewSendButtonHit, messageEntryView);
    }
}

CHDeclareClass(PrefsListController)
CHOptimizedMethod(0, self, NSMutableArray *, PrefsListController, specifiers)
{
    NSMutableArray *specifiers = CHSuper(0, PrefsListController, specifiers);
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        PSSpecifier *specifier = [NSClassFromString(@"PSSpecifier") preferenceSpecifierNamed:@"Drunk Mode"
                                                                                      target:self
                                                                                         set:@selector(setDrunkMode:specifier:)
                                                                                         get:@selector(getDrunkMode:)
                                                                                      detail:Nil
                                                                                        cell:[NSClassFromString(@"PSTableCell") cellTypeFromString:@"PSSwitchCell"]
                                                                                        edit:Nil];
        [specifier setIdentifier:DrunkModeKey];
        [specifier setProperty:[NSNumber numberWithBool:YES] forKey:@"enabled"];
        [specifier setProperty:[NSNumber numberWithBool:YES] forKey:@"alternateColors"];
        [specifier setProperty:DrunkModeIcon() forKey:@"iconImage"];
        [specifier setProperty:@"Settings-DrunkMode" forKey:@"iconCache"];
        
        [specifiers insertObject:specifier atIndex:2];
    });
    
    return specifiers;
}
CHMethod(1, id, PrefsListController, getDrunkMode, PSSpecifier *, specifier)
{
    return [NSNumber numberWithBool:getDrunkMode()];
}
CHMethod(2, void, PrefsListController, setDrunkMode, id, value, specifier, PSSpecifier *, specifier)
{
    setDrunkMode([value boolValue]);
}

CHConstructor
{
	@autoreleasepool {
        CHLoadLateClass(CKTranscriptController);
        CHHook(1, CKTranscriptController, messageEntryViewSendButtonHit);
        
        if ([[[NSBundle mainBundle]bundleIdentifier]isEqualToString:@"com.apple.Preferences"]) {
            CHLoadLateClass(PrefsListController);
            CHHook(0, PrefsListController, specifiers);
            CHHook(1, PrefsListController, getDrunkMode);
            CHHook(2, PrefsListController, setDrunkMode, specifier);
        }
	}
}
