//
//  ViewController.swift
//  RagaBox
//
//  Created by Venkateswaran Venkatakrishnan on 12/29/20.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController, AVAudioPlayerDelegate {

    var players = [NSURL: AVAudioPlayer]()
    var duplicatePlayers = [AVAudioPlayer]()
    
    var ragas = [Raga]()
    
//    let ragaNotes = ["abhogi" : ["C3","D3","D#3","F3","A3","C4", "C4","A3","F3","D#3","D3","C3"],
//
//                  "kharaharapriya":  ["C3","D3","D#3","F3","G3","A3","A#3","C4", "C4","A#3","A3","G3","F3","D#3","D3","C3"],
//
//                    "shanmughapriya" :  ["C3","D3","D#3","F#3","G3","G#3","A#3","C4", "C4","A#3","G#3","G3","F#3","D#3","D3","C3"],
//
//                    "ahiri":  ["C3","D3","F3","E3","F3","G3","A3","B3","C4", "C4","B3","A3","G3","F3","E3","F3","D3","C3"],
//
//                    "reetigowla": ["C3", "D#3", "D3", "D#3", "F3", "A#3", "A3", "F3", "A#3", "A#3", "C4",
//                        "C4", "A#3", "A3", "F3", "D#3", "F3", "G3","F3", "D#3", "D3", "C3"],
//                    "hamsanandhi": ["C3","C#3","E3","F#3","A3","B3","C4",
//                         "C4","B3","A3","F#3","E3","C#3","C3"],
//                    "charukesi": ["C3","D3","E3","F3","G3","G#3","A#3","C4",
//                         "C4","A#3","G#3","G3","F3","E3","D3","C3"]]
    
    @IBOutlet weak var popupButtonMelaRaga: NSPopUpButton!
    @IBOutlet weak var popupButtonRaga: NSPopUpButton!
    @IBOutlet weak var labelNote: NSTextField!
    @IBOutlet weak var sliderTempo: NSSlider!
    @IBOutlet weak var labelTempo: NSTextField!
    
    @IBOutlet weak var labelRaga: NSTextField!
    @IBOutlet weak var labelMelakarta: NSTextField!
    @IBOutlet weak var labelArohanaNotes: NSTextField!
    @IBOutlet weak var labelAvarohanaNotes: NSTextField!
    
    var tempo: Double = 0.6
    var delay: Double = 0.4
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ragas = loadJson(fileName: "ragas")!
    
        let melaRagaNames: Set<String> = Set(ragas.filter{ $0.mela_raga != "" }.map{ $0.mela_raga })
        
//      print("Mela Raga count: \(melaRagaNames.count)")
//      print("Raga count: \(ragaNames.count)")
        
        popupButtonMelaRaga.removeAllItems()
        popupButtonMelaRaga.addItem(withTitle: "-")
        popupButtonMelaRaga.addItems(withTitles: melaRagaNames.sorted())
        
        populateRagaList(ragaList: ragas, melaRagaName: "-")
        
        sliderTempo.doubleValue = self.tempo
        self.labelTempo.stringValue = String(format: "%.1f",self.tempo)
        
        displayRagaDetails(ragaName: popupButtonRaga.title)
        
  
    }
    
    @IBAction func playSound(_ sender: Any) {

        
        let ragaName = popupButtonRaga.title
        
        let filteredRagas = ragas.filter({$0.name == ragaName})
        
        if filteredRagas.count > 0 {
            var notes = filteredRagas[0].arohana.components(separatedBy: " ")
            notes.append(contentsOf: filteredRagas[0].avarohana.components(separatedBy: " "))
            playNotes(notes: notes,withDelay: self.delay)
            // print("notes : \(notes)")
        }
        else {
                   print("Notes not defined for raga \(ragaName)")
        }
        self.labelNote.stringValue = ""
   
       
    }
    

    func playNotes(notes: [String], withDelay: Double)
    {
        var lastDelay = 0.0
        for (index, note) in notes.enumerated() {
  
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
        
        guard let notePath = Bundle.main.path(forResource: note, ofType: "mp3", inDirectory: "Carnatic") else {
            print("Could not locate note file \(note).mp3. Exiting")
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
    
    @IBAction func sliderTempoChanged(_ sender: Any) {
        
        self.tempo = sliderTempo.doubleValue
        self.delay = 1.0 - self.tempo
        labelTempo.stringValue = String(format: "%.1f ",self.tempo)
    }
    
    
    @IBAction func popupButtonMelaRagaChanged(_ sender: Any) {
        
        let melaRagaName = self.popupButtonMelaRaga.title
        
        
        if melaRagaName != "-" {
            
            let filteredRagaList = ragas.filter{$0.mela_raga == melaRagaName}.map{ $0 }
            
            populateRagaList(ragaList: filteredRagaList, melaRagaName: melaRagaName)
            
        }
        else {
            
            populateRagaList(ragaList: ragas, melaRagaName: "-")
        }
       
        
    }
    
    func populateRagaList(ragaList: [Raga], melaRagaName: String) {
        
        popupButtonRaga.removeAllItems()
        
        if melaRagaName != "-" {
            popupButtonRaga.addItem(withTitle: melaRagaName)
        }
        
        popupButtonRaga.addItems(withTitles: ragaList.map{ $0.name }.sorted())
        displayRagaDetails(ragaName: self.popupButtonRaga.title)
    }
    
    @IBAction func popupButtonRagaChanged(_ sender: Any) {
        
        let ragaName = self.popupButtonRaga.title
        
        
        displayRagaDetails(ragaName: ragaName)
       
        
    }
    
    func displayRagaDetails(ragaName: String) {
        
        let filteredRagas = ragas.filter({$0.name == ragaName})
        
        if filteredRagas.count > 0 {
            
            let currentRaga = filteredRagas[0]
            
            labelRaga.stringValue = currentRaga.name
            labelMelakarta.stringValue = currentRaga.mela_raga
            labelArohanaNotes.stringValue = currentRaga.arohana
            labelAvarohanaNotes.stringValue = currentRaga.avarohana
          
        }
        else {
            print("Details not found for raga \(ragaName)")
        }
    }

}

