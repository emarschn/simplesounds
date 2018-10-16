//
//  TodayViewController.swift
//  todayext
//
//  Created by Eric Marschner on 12/27/17.
//  Copyright © 2017 Eric Marschner. All rights reserved.
//

import AudioToolbox
import AVFoundation
import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    var dir: URL?
    var player: AVAudioPlayer?

    @IBOutlet weak var button0: UIButton?
    @IBOutlet weak var button1: UIButton?
    @IBOutlet weak var button2: UIButton?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.simplesounds.share")
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        setupButtons()
        
        completionHandler(NCUpdateResult.newData)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupButtons()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupButtons() {
        let buts = [button0, button1, button2]
        var count = 0
        for but in buts {
            
            but?.backgroundColor = UIColor.deepRedColor
            but?.setTitleColor(UIColor.white, for: .normal)
            
            but?.layer.borderWidth = 1.0
            but?.layer.borderColor = UIColor.black.cgColor
            but?.titleLabel?.lineBreakMode = .byWordWrapping
            but?.titleLabel?.textAlignment = .center

            but?.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
            but?.addTarget(self, action: #selector(touchDown), for: .touchDown)
            
            let str = self.groupDefaults().string(forKey: String(count)) ?? String(count)
            but?.setTitle(str, for: .normal)
            count = count + 1
        }
        
    }
    
    @IBAction func touchDown(sender: UIButton) {
        let fm = FileManager.default
        if let label = sender.titleLabel {
            let types = ["mp3","m4a","wav"]
            var url: URL?
            for t in types {
                let soundfile = self.dir!.appendingPathComponent(label.text!).appendingPathExtension(t)
                if fm.fileExists(atPath: soundfile.path) {
                    url = soundfile
                    break
                }
                
            }
            if let u = url {
                playSound(url: u)
            }
        }
    }
    
    @IBAction func touchUp(sender: UIButton) {
        player?.stop()
    }
    
    func playSound(url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func groupDefaults() -> UserDefaults {
        let defaults = UserDefaults.init(suiteName: "group.com.simplesounds.share")
        return defaults!
    }
    
}
