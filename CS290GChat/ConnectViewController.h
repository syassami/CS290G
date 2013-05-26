//
//  ViewController.h
//  CS290GChat
//
//  Created by Johan Henkens on 5/8/13.
//  Copyright (c) 2013 Johan Henkens. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import <CS290GECC/CS290GECC.h>

@interface ConnectViewController : UIViewController <GKSessionDelegate, GKPeerPickerControllerDelegate>{
    GKSession *chatSession;
    GKPeerPickerController *peerPicker;
    NSMutableArray *chatPeers;
    BOOL __haveReceivedPublicPoint;
    BOOL __isReady;
    BOOL __otherPeerIsReady;
    ECC *__curve;
    BigPoint *__receivedPublicPoint;
}
- (IBAction)connect:(id)sender;

@property (retain) GKSession *chatSession;
@property (nonatomic, retain) ECC *curve;
@property (atomic, retain) BigPoint* receivedPublicPoint;
@property (atomic,assign) BOOL haveReceivedPublicPoint;
@property (atomic,assign) BOOL isReady;
@property (atomic,assign) BOOL otherPeerIsReady;

@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UILabel *connectingLabel;


@end
