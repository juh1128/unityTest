//
//  LocalNotification.m
//  NativeToolkit
//
//  Created by Ryan on 29/01/2015.
//
//

#import <Foundation/NSObjCRuntime.h>
#import "LocalNotifications.h"
#import "StringTools.h"

bool launchedFromNotification = false;

@implementation LocalNotifications

-(bool)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) {
        launchedFromNotification = true;
        NSLog(@"didFinishLaunchingWithOptions: From notification");
    }else{
        launchedFromNotification = false;
        NSLog(@"didFinishLaunchingWithOptions: Not from notification");
    }
    
    [super application:application didFinishLaunchingWithOptions:launchOptions];
}

-(void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (application.applicationState == UIApplicationStateInactive ) {
        launchedFromNotification = true;
        NSLog(@"didReceiveLocalNotification: App was in background");
    }
    
    if(application.applicationState == UIApplicationStateActive ) {
        launchedFromNotification = false;
        NSLog(@"didReceiveLocalNotification: App was in foreground");
    }
    
    [super application:application didReceiveLocalNotification:notification];
}

@end

extern "C"
{
    void scheduleNotification(char* title, char* message, int delayInMinutes, char* sound)
    {
        if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1)
        {
            // Register for notifications if iOS 8
            UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
            UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            
            NSLog(@"###### register for notifications");
        }
        
        NSDate* currentDate = [NSDate date];
        NSDate* notifyDate = [currentDate dateByAddingTimeInterval:delayInMinutes*60]; //*60
        NSString *nsSound = [StringTools createNSString:sound];

        UILocalNotification *notification = [[UILocalNotification alloc] init];
        if (notification)
        {
            notification.fireDate = notifyDate;
            notification.timeZone = [NSTimeZone defaultTimeZone];
            notification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
            notification.repeatInterval = 0;
            notification.alertBody = [StringTools createNSString:message];
            
            if([nsSound isEqualToString:@"default_sound"])
                notification.soundName = UILocalNotificationDefaultSoundName;
            else if(![nsSound isEqualToString:@""])
                notification.soundName = [nsSound stringByAppendingString:@".caf"];
            
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            
             NSLog(@"###### send notification");
        }
    }
    
    void clearNotifications()
    {
        NSLog(@"###### clear notifications");
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    
    bool wasLaunchedFromNotification()
    {
        NSLog(@"###### wasLaunchedFromNotification");
        
        return launchedFromNotification;
    }
}

IMPL_APP_CONTROLLER_SUBCLASS(LocalNotifications)