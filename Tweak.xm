#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

%hook CKTranscriptController
-(void) messageEntryViewSendButtonHit:(id)arg1{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Drunk Mode"
                                                       message:@"Go Home, You Are Drunk!"
                                                      delegate:nil
                                             cancelButtonTitle:@"What?"
                                             otherButtonTitles:nil];
    [alertView show];
}
%end

static void PreferencesCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    CFPreferencesAppSynchronize(CFSTR("me.qusic.drunkmode"));
}

%ctor{
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesCallback, CFSTR("me.qusic.drunkmode.preferencechanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/private/var/mobile/Library/Preferences/me.qusic.drunkmode.plist"];
    static BOOL enabled = ([prefs objectForKey:@"DrunkMode"] ? [[prefs objectForKey:@"DrunkMode"] boolValue] : YES);
    if (enabled)
        %init();
}