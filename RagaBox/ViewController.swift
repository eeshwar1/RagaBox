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
    
    let ragaNotes = ["abhogi" : ["C3","D3","D#3","F3","A3","C4", "C4","A3","F3","D#3","D3","C3"],
    
                  "kharaharapriya":  ["C3","D3","D#3","F3","G3","A3","A#3","C4", "C4","A#3","A3","G3","F3","D#3","D3","C3"],
    
                    "shanmughapriya" :  ["C3","D3","D#3","F#3","G3","G#3","A#3","C4", "C4","A#3","G#3","G3","F#3","D#3","D3","C3"],
    
                    "ahiri":  ["C3","D3","F3","E3","F3","G3","A3","B3","C4", "C4","B3","A3","G3","F3","E3","F3","D3","C3"],
                    
                    "reetigowla": ["C3", "E3", "D3", "E3", "F3", "B3", "A3", "F3", "B3", "B3", "C4",
                        "C4", "B3", "A3", "F3", "E3", "F3", "G3","F3", "E3", "D3", "C3"]]
    
    @IBOutlet weak var popupButton: NSPopUpButton!
    @IBOutlet weak var labelNote: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        popupButton.removeAllItems()
        popupButton.addItems(withTitles: Array(ragaNotes.keys).sorted())
    }
    
    @IBAction func playSound(_ sender: Any) {

        
        let raga = popupButton.title
       
        // print("Selected Raga is \(raga)")
        if let notes = ragaNotes[raga.lowercased()] {
            // print("Notes are \(String(describing: notes))")
            playNotes(notes: notes,withDelay: 0.5)
        }
        else {
            print("Notes not defined for raga \(raga)")
        }
        
        self.labelNote.stringValue = ""
   
       
    }
    
    func playNotes(notes: [String], withDelay: Double)
    {
        var lastDelay = 0.0
        for (index, note) in notes.enumerated() {
            
            // print("Note(\(index)): \(note)")
            let delay = withDelay*Double(index)
            lastDelay = delay
            let _ = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(playNoteNotification(notification:)), userInfo: ["note":note], repeats: false)
        }
        lastDelay = lastDelay + withDelay
        let _ = Timer.scheduledTimer(timeInterval: lastDelay, target: self, selector: #selector(donePlaying(notification:)), userInfo: nil, repeats: false)
       
    }
    
    @objc func donePlaying(notification: NSNotification) {
        
        self.labelNote.stringValue = ""
    }
    @objc func playNoteNotification(notification: NSNotification) {
       
        if let note = notification.userInfo?["note"] as? String {
       
            self.labelNote.stringValue = note
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
    
  
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let index = duplicatePlayers.firstIndex(of: player) {
            duplicatePlayers.remove(at: index)
        }
  
    }

}

