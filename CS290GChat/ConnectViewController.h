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
}

- (IBAction)connect:(id)sender;

@property (nonatomic,strong) GKSession *chatSession;
@property (nonatomic,strong) GKPeerPickerController *peerPicker;
@property (nonatomic,strong) NSMutableArray *chatPeers;
@property (nonatomic,strong) ECC *curve;
@property (atomic,strong) BigPoint* receivedPublicPoint;
@property (atomic,assign) BOOL haveReceivedPublicPoint;
@property (atomic,assign) BOOL isReady;
@property (atomic,assign) BOOL otherPeerIsReady;

@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UILabel *connectingLabel;


@end
