//
//  ZYGameFB.m
//  ZYWebGameKitSample
//
//  Created by admin on 2020/5/12.
//  Copyright © 2020 Octopus. All rights reserved.
//

#import "ZYGameFB.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@import ZYWebGameKit;

@implementation ZYGameFB
+ (instancetype)shareFacebook{
    static ZYGameFB *facebookLogin = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        facebookLogin = [[ZYGameFB alloc] init];
    });
    
    return facebookLogin;
}
- (void)initWithAppID:(NSString *)AppID application:(UIApplication *)application options:(NSDictionary *)launchOptions{
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    [FBSDKSettings setAppID:AppID];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookLogin) name:@"ZYSDKNotificationFaceBookLogin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookInit) name:@"ZYSDKNotificationFaceBookInit" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookPaysuccess:) name:@"ZYSDKNotificationFaceBookPaySuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookQuicklyLogin) name:@"ZYSDKNotificationFaceBookQuicklyLogin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookNormalLogin) name:@"ZYSDKNotificationFaceBookNormalLogin" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookPhoneLogin) name:@"ZYSDKNotificationFaceBookPhoneLogin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookPhoneRegist) name:@"ZYSDKNotificationFaceBookPhoneRegist" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookEmailLogin) name:@"ZYSDKNotificationFaceBookEmailLogin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookEmailRegist) name:@"ZYSDKNotificationFaceBookEmailRegist" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookLoginSuccess) name:@"ZYSDKNotificationFaceBookLoginsuccess" object:nil];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSNotificationCenter
- (void)facebookLogin{//facebook登录

    if ([FBSDKAccessToken currentAccessToken]) {
        
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:[FBSDKAccessToken currentAccessToken].userID parameters:@{@"fields":@"id,name,email"} HTTPMethod:@"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection * _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
            
            if (result) {
                
                NSString *faceid = [NSString stringWithFormat:@"%@",result[@"id"]?result[@"id"]:@""];
                NSString *email = [NSString stringWithFormat:@"%@",result[@"email"]?result[@"email"]:@""];
                NSString *name = [NSString stringWithFormat:@"%@",result[@"name"]?result[@"name"]:@""];
                
                [ZYWebGameKit otherLoginWithOtherId:faceid email:email name:name loginType:@"facebook"];
                
            }else{
                
                if (error.code == NSURLErrorTimedOut || error.code == NSURLErrorNetworkConnectionLost) {
                    NSLog(@"请求超时");
                }else if (error.code == NSURLErrorCannotFindHost){
                    NSLog(@"网络错误");
                }else{
                    NSLog(@"没有网");
                }
            }
            
        }];
        
    } else {
        
        FBSDKLoginManager *facebookLogin = [[FBSDKLoginManager alloc] init];
        [facebookLogin logInWithPermissions:@[@"public_profile"] fromViewController:[[UIApplication sharedApplication] keyWindow].rootViewController handler:^(FBSDKLoginManagerLoginResult * _Nullable result, NSError * _Nullable error) {
            
            if (error) {
                
            }else if (result.isCancelled){
                NSLog(@"取消登录");
            }else{
                
                FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:result.token.userID parameters:@{@"fields":@"id,name,email"} HTTPMethod:@"GET"];
                [request startWithCompletionHandler:^(FBSDKGraphRequestConnection * _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
                    
                    if (result) {
                        
                        NSString *faceid = [NSString stringWithFormat:@"%@",result[@"id"]?result[@"id"]:@""];
                        NSString *email = [NSString stringWithFormat:@"%@",result[@"email"]?result[@"email"]:@""];
                        NSString *name = [NSString stringWithFormat:@"%@",result[@"name"]?result[@"name"]:@""];
                        
                        [ZYWebGameKit otherLoginWithOtherId:faceid email:email name:name loginType:@"facebook"];
                        
                    }else{
                        
                        if (error.code == NSURLErrorTimedOut || error.code == NSURLErrorNetworkConnectionLost) {
                            NSLog(@"请求超时");
                        }else if (error.code == NSURLErrorCannotFindHost){
                            NSLog(@"网络错误");
                        }else{
                            NSLog(@"没有网");
                        }
                        
                    }
                    
                }];
            }
            
        }];
    }
}

- (void)facebookInit{//初始化打点
    [FBSDKAppEvents activateApp];
}

- (void)facebookPaysuccess:(NSNotification *)notify{//支付成功打点
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            notify.userInfo[@"FBSDKAppEventParameterNameNumItems"], FBSDKAppEventParameterNameNumItems,
                            @"goods", FBSDKAppEventParameterNameContentType,
                            notify.userInfo[@"FBSDKAppEventParameterNameContentID"], FBSDKAppEventParameterNameContentID,
                            @"CNY", FBSDKAppEventParameterNameCurrency,
                            nil];
    
    [FBSDKAppEvents logPurchase:[notify.userInfo[@"FBSDKAppEventParameterNameNumItems"] intValue] currency:@"CNY" parameters:params];
    
}

- (void)facebookQuicklyLogin{//快捷登录打点
    NSDictionary *paramsLog = [[NSDictionary alloc] initWithObjectsAndKeys:@"quicklyLogin", FBSDKAppEventParameterNameRegistrationMethod,nil];
    [FBSDKAppEvents logEvent:FBSDKAppEventNameCompletedRegistration parameters: paramsLog];
}

- (void)facebookNormalLogin{//常规登录打点
    NSDictionary *paramsLog = [[NSDictionary alloc] initWithObjectsAndKeys:@"normalLogin", FBSDKAppEventParameterNameRegistrationMethod,nil];
    [FBSDKAppEvents logEvent:FBSDKAppEventNameCompletedRegistration parameters: paramsLog];
}

- (void)facebookPhoneLogin{//手机登录打点
    NSDictionary *paramsLog = [[NSDictionary alloc] initWithObjectsAndKeys:@"phoneLogin", FBSDKAppEventParameterNameRegistrationMethod,nil];
    [FBSDKAppEvents logEvent:FBSDKAppEventNameCompletedRegistration parameters: paramsLog];
}

- (void)facebookPhoneRegist{//手机注册打点
    NSDictionary *paramsReg = [[NSDictionary alloc] initWithObjectsAndKeys:@"phoneRegist", FBSDKAppEventParameterNameRegistrationMethod,nil];
    [FBSDKAppEvents logEvent:FBSDKAppEventNameCompletedRegistration parameters: paramsReg];
}

- (void)facebookEmailLogin{//邮箱登录打点
    NSDictionary *paramsLog = [[NSDictionary alloc] initWithObjectsAndKeys:@"emailLogin", FBSDKAppEventParameterNameRegistrationMethod,nil];
    [FBSDKAppEvents logEvent:FBSDKAppEventNameCompletedRegistration parameters: paramsLog];
}

- (void)facebookEmailRegist{//邮箱注册打点
    NSDictionary *paramsReg = [[NSDictionary alloc] initWithObjectsAndKeys:@"emailRegist", FBSDKAppEventParameterNameRegistrationMethod,nil];
    [FBSDKAppEvents logEvent:FBSDKAppEventNameCompletedRegistration parameters: paramsReg];
}

- (void)facebookLoginSuccess{//Facebook登录成功打点
    NSDictionary *paramsLog = [[NSDictionary alloc] initWithObjectsAndKeys:@"facebookLogin", FBSDKAppEventParameterNameRegistrationMethod,nil];
    [FBSDKAppEvents logEvent:FBSDKAppEventNameCompletedRegistration parameters: paramsLog];
}
@end
