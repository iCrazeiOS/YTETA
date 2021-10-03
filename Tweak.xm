#import <UIKit/UIKit.h>

@interface YTPlayerViewController : UIViewController
-(NSInteger)playerState;
-(float)currentPlaybackRateForVarispeedSwitchController:(id)arg1;
@end

@interface UIView ()
@property(nonatomic, readwrite) UIView *overlayView;
@property(nonatomic, readwrite) UIView *playerBar;
@property(nonatomic, readwrite) UILabel *durationLabel;
@property(nonatomic, assign, readonly) CGFloat totalTime;
@property(nonatomic, assign, readonly) CGFloat mediaTime;
@end

static BOOL enabled;
static BOOL secondsEnabled;
static BOOL twentyFourHourClockEnabled;

static void loadPrefs() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.icraze.ytetaprefs.plist"];
	enabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES;
	secondsEnabled = [prefs objectForKey:@"secondsEnabled"] ? [[prefs objectForKey:@"secondsEnabled"] boolValue] : YES;
	twentyFourHourClockEnabled = [prefs objectForKey:@"twentyFourHourClockEnabled"] ? [[prefs objectForKey:@"twentyFourHourClockEnabled"] boolValue] : NO;
}

static void modifyLabel(UILabel *label, float remainingSeconds, float videoSpeed) {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSMutableString *formatString = [[NSMutableString alloc] initWithString:@"mm"];
	// Add seconds, if they're enabled
	if (secondsEnabled) [formatString appendString:@":ss"];
	// Determine 12h/24h time
	twentyFourHourClockEnabled ? [formatString insertString:@"HH:" atIndex:0] : [formatString insertString:@"hh:" atIndex:0];;
	// Make the NSDateFormatter use our time format
	[dateFormatter setDateFormat:formatString];
	// Get what time it'll be when the video ends
	NSString *endsAtString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:remainingSeconds/videoSpeed]];
	// Update the label's text
	if (![label.text containsString:@"Ends at"]) [label setText:[NSString stringWithFormat:@"%@ - Ends at: %@", label.text, endsAtString]];
	// Resize the label's frame so that the new text fits
    [label sizeToFit];
}

%hook YTPlayerViewController
-(void)singleVideo:(id)arg1 currentVideoTimeDidChange:(id)arg2 {
	%orig;
	if (!enabled) return;

	// Fixes crash with auto-playing videos on the home page
	if ([self.view.overlayView class] != %c(YTMainAppVideoPlayerOverlayView)) return;

	// Get remaining seconds
	float remainingSeconds = self.view.overlayView.playerBar.playerBar.totalTime - self.view.overlayView.playerBar.playerBar.mediaTime;

	// Get time label
	UILabel *progressLabel = self.view.overlayView.playerBar.durationLabel;
	// Modify label
	if (![progressLabel.text containsString:@"Ends at"]) modifyLabel(progressLabel, remainingSeconds, [self currentPlaybackRateForVarispeedSwitchController:nil]);
}
%end

%ctor {
	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.icraze.ytetaprefs.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	if (enabled) %init;
}
