//
//  VirtualOfficeViewController.swift
//  QuickDoc
//
//  Created by Edward Suczewski on 2/23/17.
//  Copyright © 2017 Edward Suczewski. All rights reserved.
//

import UIKit
import Firebase
import TwilioVideo

protocol VirtualOfficeDelegate {
    func virtualOfficeDismissed()
}

class VirtualOfficeViewController: UIViewController {
    
    // MARK: Properties
    
    var delegate: VirtualOfficeDelegate?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Video SDK components
    
    // videoClient
    var videoClient: TVIVideoClient?
    
    // localMedia
    var localMedia: TVILocalMedia?
    var localVideoTrack: TVILocalVideoTrack?
    var localAudioTrack: TVILocalAudioTrack?
    var camera: TVICameraCapturer?
    
    // connect to a room
    var room: TVIRoom?
    var participant: TVIParticipant?
    
    // MARK: Outlets
    @IBOutlet weak var endCallButton: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoStatusLabel: UILabel!
    @IBOutlet weak var selfView: UIView!
    
    // MARK: Actions
    @IBAction func endCallButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTapGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: true)
        setUpLocalMedia()
        connectVideo()
        if VirtualOfficeController.sharedInstance.userIsPatient {
            videoStatusLabel.isHidden = true
        } else {
            videoStatusLabel.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        room = nil
        participant = nil
        self.delegate?.virtualOfficeDismissed()
    }
    
    // MARK: Methods

    func connectVideo() {
        guard let name = FIRAuth.auth()?.currentUser?.uid,
            let provider = FIRAuth.auth()?.currentUser?.providerID.trimmingCharacters(in: .whitespaces) else {
                return
        }
        let urlString = "https://cybermed-token-server.herokuapp.com/token?identity=" + name + "&device=" + provider
        guard let url = NSURL(string: urlString) else {
            // unwind segue
            return
        }
        var urlRequest = URLRequest(url: url as URL)
        urlRequest.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: urlRequest) { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                if let token = json["token"] as? String {
                    self.videoClient = TVIVideoClient(token: token)
                    self.connectToARoom()
                }
            } catch let error as NSError {
                print(error)
                // unwind segue
            }
            }.resume()
    }
    
    func setUpLocalMedia() {
        localMedia = TVILocalMedia()
        localAudioTrack = localMedia?.addAudioTrack(true)
        camera = TVICameraCapturer()
        if let camera = camera {
            localVideoTrack = localMedia?.addVideoTrack(true, capturer: camera)
            localVideoTrack?.attach(self.selfView)
        }
    }

    
    func connectToARoom() {
        guard let virtualOfficeIdentifier = VirtualOfficeController.sharedInstance.currentVirtualOffice?.identifier else {
            return
            // unwind segue
        }
        let connectOptions = TVIConnectOptions { (builder) in
            builder.name = virtualOfficeIdentifier
            builder.localMedia = self.localMedia
        }
        room = videoClient?.connect(with: connectOptions, delegate: self)
    }
    
    func cleanupRemoteParticipant() {
        if ((self.participant) != nil) {
            if ((self.participant?.media.videoTracks.count)! > 0) {
                self.participant?.media.videoTracks[0].detach(self.videoView)
            }
        }
        self.participant = nil
    }
    
    func setUpTapGestureRecognizers() {
        let toggleButtonTGR = UITapGestureRecognizer(target: self, action: #selector(toggleButtonTapped))
        self.videoView.addGestureRecognizer(toggleButtonTGR)
    }
    
    func toggleButtonTapped() {
        if endCallButton.isHidden {
            endCallButton.isHidden = false
        } else {
            endCallButton.isHidden = true
        }
    }


}

extension VirtualOfficeViewController : TVIRoomDelegate {
    func didConnect(to room: TVIRoom) {
        
        
        print("Connected to room \(room.name) as \(room.localParticipant?.identity)")
        
        if (room.participants.count > 0) {
            self.participant = room.participants[0]
            self.participant?.delegate = self
        }
    }
    
    func room(_ room: TVIRoom, didDisconnectWithError error: Error?) {
        print("Disconncted from room \(room.name), error = \(error)")
        
        self.cleanupRemoteParticipant()
        self.room = nil
        
    }
    
    func room(_ room: TVIRoom, didFailToConnectWithError error: Error) {
        print("Failed to connect to room with error")
        self.room = nil
        
    }
    
    func room(_ room: TVIRoom, participantDidConnect participant: TVIParticipant) {
        if (self.participant == nil) {
            self.participant = participant
            self.participant?.delegate = self
        }
        print("Room \(room.name), Participant \(participant.identity) connected")
    }
    
    func room(_ room: TVIRoom, participantDidDisconnect participant: TVIParticipant) {
        if (self.participant == participant) {
            cleanupRemoteParticipant()
        }
        print("Room \(room.name), Participant \(participant.identity) disconnected")
    }
}

// MARK: TVIParticipantDelegate
extension VirtualOfficeViewController : TVIParticipantDelegate {
    func participant(_ participant: TVIParticipant, addedVideoTrack videoTrack: TVIVideoTrack) {
        print("Participant \(participant.identity) added video track")
        
        if (self.participant == participant) {
            self.videoStatusLabel.isHidden = true
            videoTrack.attach(self.videoView)
        }
    }
    
    func participant(_ participant: TVIParticipant, removedVideoTrack videoTrack: TVIVideoTrack) {
        print("Participant \(participant.identity) removed video track")
        if (self.participant == participant) {
            if !VirtualOfficeController.sharedInstance.userIsPatient {
                self.videoStatusLabel.isHidden = false
            } else {
                VirtualOfficeController.sharedInstance.currentVirtualOffice?.status = "closed"
            }
            videoTrack.detach(self.videoView)
        }
    }
    
    func participant(_ participant: TVIParticipant, addedAudioTrack audioTrack: TVIAudioTrack) {
        print("Participant \(participant.identity) added audio track")
        
    }
    
    func participant(_ participant: TVIParticipant, removedAudioTrack audioTrack: TVIAudioTrack) {
        print("Participant \(participant.identity) removed audio track")
    }
    
    func participant(_ participant: TVIParticipant, enabledTrack track: TVITrack) {
        var type = ""
        if (track is TVIVideoTrack) {
            type = "video"
        } else {
            type = "audio"
        }
        print("Participant \(participant.identity) enabled \(type) track")
    }
    
    func participant(_ participant: TVIParticipant, disabledTrack track: TVITrack) {
        var type = ""
        if (track is TVIVideoTrack) {
            type = "video"
        } else {
            type = "audio"
        }
        print("Participant \(participant.identity) disabled \(type) track")
    }
}

