#import <UIKit/UIKit.h>
#import <rootless.h>

@interface YTPlayerViewController : UIViewController
-(float)currentPlaybackRateForVarispeedSwitchController:(id)arg1;
@end

@interface UIView ()
@property(nonatomic, readwrite) UIView *overlayView;
@property(nonatomic, readwrite) UIView *playerBar;
@property(nonatomic, readwrite) UILabel *durationLabel;
@end

static BOOL enabled;
static BOOL secondsEnabled;
static BOOL twentyFourHourClockEnabled;

static void loadPrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:ROOT_PATH_NS(@"/var/mobile/Library/Preferences/com.icraze.ytetaprefs.plist")];
	enabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES;
	secondsEnabled = [prefs objectForKey:@"secondsEnabled"] ? [[prefs objectForKey:@"secondsEnabled"] boolValue] : YES;
	twentyFourHourClockEnabled = [prefs objectForKey:@"twentyFourHourClockEnabled"] ? [[prefs objectForKey:@"twentyFourHourClockEnabled"] boolValue] : NO;
}

%hook YTPlayerViewController
-(void)singleVideo:(id)arg1 currentVideoTimeDidChange:(id)arg2 {
	if (!enabled) return %orig;

	// Fixes crash with auto-playing videos on the home page
	if ([self.view.overlayView class] != %c(YTMainAppVideoPlayerOverlayView)) return %orig;

	// Get playback details
	UIView *playerBar = self.view.overlayView.playerBar;
	float remainingSeconds = [[playerBar valueForKey:@"_totalTime"] floatValue] - [[playerBar valueForKey:@"_roundedMediaTime"] floatValue];
	float videoSpeed = [self currentPlaybackRateForVarispeedSwitchController:nil];

	// Get time label
	UILabel *label = playerBar.durationLabel;

	// Create date formatter
	NSMutableString *formatString = [[NSMutableString alloc] initWithString:@"mm"];
	if (secondsEnabled) [formatString appendString:@":ss"]; // Add seconds if needed
	[formatString insertString:twentyFourHourClockEnabled ? @"HH:" : @"hh:" atIndex:0]; // Handle 12h/24h time

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:formatString];

	// Get video end time
	NSDate *date = [NSDate dateWithTimeIntervalSinceNow:remainingSeconds / videoSpeed];
	NSString *endsAtString = [dateFormatter stringFromDate:date];
	
	// Update the label
	NSString *origTimeLabelText = [@"/ " stringByAppendingString:[[label.text substringFromIndex:2] componentsSeparatedByString:@" "][0]];
	NSString *updatedText = [NSString stringWithFormat:@"%@ - Ends at: %@", origTimeLabelText, endsAtString];
	[label setText:updatedText];
	[label sizeToFit];

	%orig;
}
%end

%ctor {
	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.icraze.ytetaprefs.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	if (enabled) %init;
}
