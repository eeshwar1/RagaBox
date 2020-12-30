//
//  ViewController.swift
//  RagaBox
//
//  Created by Venkateswaran Venkatakrishnan on 12/29/20.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController, AVAudioPlayerDelegate {

    var players =  [NSURL: AVAudioPlayer]()
    var duplicatePlayers = [AVAudioPlayer] ()
    
    var abhogi: [String] = ["C3","D3","D#3","F3","A3","C4", "C4","A3","F3","D#3","D3","C3"]
    
    var kharaharapriya: [String] = ["C3","D3","D#3","F3","G3","A3","A#3","C4", "C4","A#3","A3","G3","F3","D#3","D3","C3"]
    
    var shanmukhapriya: [String] = ["C3","D3","D#3","F#3","G3","G#3","A#3","C4", "C4","A#3","G#3","G3","F#3","D#3","D3","C3"]
    
    var ahiri: [String] = ["C3","D3","F3","E3","F3","G3","A3","B3","C4", "C4","B3","A3","G3","F3","E3","F3","D3","C3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func playSound(_ sender: Any) {
        
        playNotes(notes: abhogi,withDelay: 0.4)
   
       
    }
    
    func playNotes(notes: [String], withDelay: Double)
    {
        for (index, note) in notes.enumerated() {
            
            // print("Note(\(index)): \(note)")
            let delay = withDelay*Double(index)
            let _ = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(playNoteNotification(notification:)), userInfo: ["note":note], repeats: false)
        }
    }
    
    @objc func playNoteNotification(notification: NSNotification) {
       
        if let note = notification.userInfo?["note"] as? String {
            
            // print("Playing sound: \(note)")
            playNote(note)
            
        }
        
    }
    
    func playNote(_ note: String) {
        
        guard let notePath = Bundle.main.path(forResource: note, ofType: "mp3") else {
            print("Could not locate note file. Exiting")
            return
        }
        
        let noteURL = NSURL(fileURLWithPath: notePath)
        
        if let player = players[noteURL] { // player for sound has been found
            if player.isPlaying == false {
                // player is not in use, so use that one
                player.prepareToPlay()
                player.play()
            } else {
                
                // player is in use, create a new, duplicate player and use that instead
                // use try! because we know the URL worked before
                let duplicatePlayer = try! AVAudioPlayer(contentsOf: noteURL as URL)
                
                // assign delegate for duplicatePlayer so delegate can remove the duplicate once it has stopped playing
                
                duplicatePlayer.delegate = self
                
                // add duplicate to array so it does not get removed from memory before finishing
                duplicatePlayers.append(duplicatePlayer)
                
                duplicatePlayer.prepareToPlay()
                duplicatePlayer.play()
                
                
            }
            
        }
        else {
                
                // player has not been found, create a new player with the URL if possible
                
                do {
                    let player = try AVAudioPlayer(contentsOf: noteURL as URL)
                    self.players[noteURL] = player
                    player.prepareToPlay()
                    player.play()
                    
                } catch {
                    print("Could not play note: \(note)")
                }
            }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

