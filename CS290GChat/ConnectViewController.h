//
//  ViewController.h
//  CS290GChat
//
//  Created by Johan Henkens on 5/8/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface ConnectViewController : UIViewController <GKSessionDelegate, GKPeerPickerControllerDelegate, UITextFieldDelegate>{
    GKSession *chatSession;
    GKPeerPickerController *peerPicker;
    NSMutableArray *chatPeers;
    BOOL disconnectTriggeredBack;
}
- (IBAction)connect:(id)sender;

@property (retain) GKSession *chatSession;


@end
