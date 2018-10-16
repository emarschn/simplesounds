//
//  ShareViewController.swift
//  shareext
//
//  Created by Eric Marschner on 12/7/17.
//  Copyright © 2017 Eric Marschner. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: UIViewController {
    
    var dir: URL?
    var audioURL: URL?
    var saveKey: String = "0"
    
    @IBOutlet var titleKey: UILabel!
    @IBOutlet var contentView: UIView!
    @IBOutlet var backView: UIView!
    @IBOutlet var textfield: UITextField!
    @IBOutlet var imageView: UIImageView!

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dir = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.simplesounds.share")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.saveKey = self.nextGroup()
        self.titleKey.text = self.saveKey
        setupAudio()
        
        self.view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height);
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = .identity
        }) { (success: Bool) in
            UIView.animate(withDuration: 0.25, animations: {
                self.backView.alpha = 0.65
            })
        }
        
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func setupAudio() {
        if let inputItem = extensionContext!.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first as? NSItemProvider {
                itemProvider.loadItem(forTypeIdentifier: kUTTypeAudio as String) { [unowned self] (audioURL, error) in
                    if let audioURL = audioURL as? URL {
                        print("audioUrl = \(audioURL)")
                        self.audioURL = audioURL
                        let name = audioURL.deletingPathExtension().lastPathComponent
                        DispatchQueue.main.async {
                            self.textfield.text = name
                            let scale = UIScreen.main.scale;
                            let imageSizeInPixel =  CGSize(width:self.imageView.bounds.width * scale,height:self.imageView.bounds.height * scale);
                            generateWaveformImage(audioURL: audioURL, imageSizeInPixel: imageSizeInPixel, waveColor: UIColor.red) {[weak self] (waveFormImage) in
                                if let waveFormImage = waveFormImage {
                                    self?.imageView.image = waveFormImage;
                                    print("image.size = \(waveFormImage.size),scale=\(waveFormImage.scale)")
                                } else {
                                    print("fail")
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    func saveAudioFile() {
        if let a = self.audioURL {
            let name = textfield.text!
            if name.count > 0 {
                var copyTo = self.dir!.appendingPathComponent(name)
                copyTo = copyTo.appendingPathExtension(a.pathExtension)
                do {
                    try FileManager.default.copyItem(at: a, to: copyTo)
                } catch {
                    print("\(error)")
                }
                self.groupDefaults().set(name, forKey: self.saveKey)
                DispatchQueue.main.async {
                    self.dismiss()
                }
            }
        } else {
            contentView.shake()
        }
    }
    

    @IBAction func saveTapped(sender: UIButton) {
        saveAudioFile()
    }
    
    @IBAction func cancelTapped(sender: UIButton) {
        dismiss()
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height);
        }) { (success: Bool) in
            let error = NSError(domain: "com.simplesounds", code: -1, userInfo: nil)
            self.extensionContext?.cancelRequest(withError: error)
        }
    }
    
    func groupDefaults() -> UserDefaults {
        let defaults = UserDefaults.init(suiteName: "group.com.simplesounds.share")
        
        return defaults!
    }
    
    func nextGroup() -> String {
        let fm = FileManager.default
        let types = ["mp3","m4a","wav"]
        var key: Int = 0
        repeat {
            var found = false
            for t in types {
                if let label = groupDefaults().string(forKey: "\(key)") {
                    let soundfile = fm.groupDirectory.appendingPathComponent(label).appendingPathExtension(t)
                    if fm.fileExists(atPath: soundfile.path) {
                        found = true
                        break
                    }
                }
            }
            if (!found) {
                return "\(key)"
            }
            key = key + 1
        } while (true)
    }
    
}

extension UIView {
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x:self.center.x - 10, y:self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x:self.center.x + 10, y:self.center.y))
        self.layer.add(animation, forKey: "position")
    }
    
}
