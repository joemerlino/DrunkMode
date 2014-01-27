#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CaptainHook.h>

typedef enum PSCellType {
    PSGroupCell,
    PSLinkCell,
    PSLinkListCell,
    PSListItemCell,
    PSTitleValueCell,
    PSSliderCell,
    PSSwitchCell,
    PSStaticTextCell,
    PSEditTextCell,
    PSSegmentCell,
    PSGiantIconCell,
    PSGiantCell,
    PSSecureEditTextCell,
    PSButtonCell,
    PSEditTextViewCell,
} PSCellType;

@interface PSSpecifier : NSObject {
@public
    id target;
    SEL getter;
    SEL setter;
    SEL action;
    Class detailControllerClass;
    PSCellType cellType;
    Class editPaneClass;
    UIKeyboardType keyboardType;
    UITextAutocapitalizationType autoCapsType;
    UITextAutocorrectionType autoCorrectionType;
    int textFieldType;
@private
    NSString* _name;
    NSArray* _values;
    NSDictionary* _titleDict;
    NSDictionary* _shortTitleDict;
    id _userInfo;
    NSMutableDictionary* _properties;
}
@property(retain) NSMutableDictionary* properties;
@property(retain) NSString* identifier;
@property(retain) NSString* name;
@property(retain) id userInfo;
@property(retain) id titleDictionary;
@property(retain) id shortTitleDictionary;
@property(retain) NSArray* values;
+(id)preferenceSpecifierNamed:(NSString*)title target:(id)target set:(SEL)set get:(SEL)get detail:(Class)detail cell:(PSCellType)cell edit:(Class)edit;
+(PSSpecifier*)groupSpecifierWithName:(NSString*)title;
+(PSSpecifier*)emptyGroupSpecifier;
+(UITextAutocapitalizationType)autoCapsTypeForString:(PSSpecifier*)string;
+(UITextAutocorrectionType)keyboardTypeForString:(PSSpecifier*)string;
-(id)propertyForKey:(NSString*)key;
-(void)setProperty:(id)property forKey:(NSString*)key;
-(void)removePropertyForKey:(NSString*)key;
-(void)loadValuesAndTitlesFromDataSource;
-(void)setValues:(NSArray*)values titles:(NSArray*)titles;
-(void)setValues:(NSArray*)values titles:(NSArray*)titles shortTitles:(NSArray*)shortTitles;
-(void)setupIconImageWithPath:(NSString*)path;
-(NSString*)identifier;
-(void)setTarget:(id)target;
-(void)setKeyboardType:(UIKeyboardType)type autoCaps:(UITextAutocapitalizationType)autoCaps autoCorrection:(UITextAutocorrectionType)autoCorrection;
@end

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
                                                                                        cell:PSSwitchCell
                                                                                        edit:Nil];
        [specifier setIdentifier:DrunkModeKey];
        [specifier setProperty:[NSNumber numberWithBool:YES] forKey:@"enabled"];
        [specifier setProperty:[NSNumber numberWithBool:YES] forKey:@"alternateColors"];
        [specifier setProperty:[UIImage imageWithContentsOfFile:@"/Library/Application Support/DrunkMode/DrunkMode.png"] forKey:@"iconImage"];
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
