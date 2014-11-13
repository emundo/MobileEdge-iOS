//
//  MOBAppDelegate.m
//  MobileEdge
//
//  Created by luc  on 30.07.14.
//  Copyright (c) 2014 BOSS. All rights reserved.
//

#import "MOBAppDelegate.h"
#import "EncryptedStore.h"
#import "MOBCore.h"
#import "TorController.h"
#import <SodiumObjc.h>
#import <AFNetworkActivityLogger.h>


@implementation MOBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    //NSPersistentStoreCoordinator *coordinator = [EncryptedStore makeStore:[self managedObjectModel]
                                                                 //passcode:@"SuperSafeMobileEdgePasscode;)"];
    // Override point for customization after application launch.
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
#ifdef DEBUG
    DDLogDebug(@"IN DEBUG MODE");
    // #define _AFNETWORKING_ALLOW_INVALID_SSL_CERTIFICATES_
    // has no effect
    #endif
    self.mobileEdgeCore = [[MOBCore alloc] initWithAnonymizerSettings: [[MOBTorSettings alloc] init]];
    [self.mobileEdgeCore.anonymizer.settings whitelistDomainForSelfSignedCertificates: @"localhost"];
    [self.mobileEdgeCore.anonymizer.settings whitelistDomainForSelfSignedCertificates: @"127.0.0.1"];
    [self.mobileEdgeCore.anonymizer.settings whitelistDomainForSelfSignedCertificates: @"192.168.1.124"];
    [self.mobileEdgeCore.anonymizer.settings whitelistDomainForSelfSignedCertificates: @"192.168.1.131"];
    [self.mobileEdgeCore.anonymizer.settings whitelistDomainForSelfSignedCertificates: @"129.187.100.231"];
    DDLogVerbose(@"%@", [[NACLAsymmetricKeyPair keyPair].privateKey.data base64EncodedStringWithOptions:0]);
    MOBIdentity *myIdentity = [[MOBIdentity alloc] init]; // load an Identity (key pair).
    MOBAxolotl *axolotl = [[MOBAxolotl alloc] initWithIdentity: myIdentity]; //TODO: Create Axolotl instance (identity)
    NACLAsymmetricPublicKey *mobileEdgePK;
    MOBRemoteIdentity *remote = [[MOBRemoteIdentity alloc] initWithPublicKey: mobileEdgePK
                                                                  serviceURL:[NSURL URLWithString:@"test.mobileedge.de"]];// load a remote identity (pubkey + url).
    //TODO: perform key exchange with remote identity.
    //NSURL *baseURL = [NSURL URLWithString:@"https://129.187.100.231:8888"];
    NSURL *baseURL = [NSURL URLWithString:@"https://check.torproject.org"];
    //MOBHTTPRequestOperationManager *operationManager = [[MOBHTTPRequestOperationManager alloc] initWithBaseURL: baseURL];
    KeyExchangeSendBlock sendBlock;
    //sendBlock = ^(NSData *keyExchangeMessage, KeyExchangeFinalizeBlock finalizeBlock)
    sendBlock = ^(NSDictionary *keyExchangeMessage, KeyExchangeFinalizeBlock finalizeBlock)
    {
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL: baseURL];
        NSDictionary *parameters = @{ @"type" : @"KEYXC", @"keys" : keyExchangeMessage };
        #ifdef DEBUG
        manager.securityPolicy.allowInvalidCertificates=YES;    //allow unsigned //TODO: FIXME!!!!!!
        DDLogDebug(@"ACCEPTING INVALID CERTS! Deactivate in Production!");
        #endif
        manager.responseSerializer = [AFJSONResponseSerializer serializer];   //set up for JSOn
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        NSMutableIndexSet *indeces = [[NSMutableIndexSet alloc] initWithIndexSet: manager.responseSerializer.acceptableStatusCodes];
        [indeces addIndex: 400];
        manager.responseSerializer.acceptableStatusCodes = indeces;
        [manager POST: @"/"
                    parameters: parameters
                       success: ^(AFHTTPRequestOperation *operation, id responseObject) {
                           DDLogDebug(@"Received response: Status code: %ld \nResponse object: %@", (long) operation.response.statusCode, responseObject);
                           if (400 == operation.response.statusCode)
                           {
                               DDLogDebug(@"Status code was 400");
                           }
                           else
                           {
                               finalizeBlock(responseObject);
                           }
                       }
                       failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
                           DDLogError(@"Error during key exchange. %@", error);
                       }];
    };
    ConnectSuccessfulBlock onConnect= ^()
    {
        [axolotl performKeyExchangeWithBob: remote
            andSendKeyExchangeMessageUsing: sendBlock
                                     error: nil]; // TODO: error handling
    };
    [self.mobileEdgeCore.anonymizer connectOnFinishExecuteBlock: onConnect failure: NULL];
    //TODO: output shared secret
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
