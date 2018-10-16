//
//  ViewController.swift
//  simplesounds
//
//  Created by Eric Marschner on 9/27/17.
//  Copyright © 2017 Eric Marschner. All rights reserved.
//

import AudioToolbox
import AVFoundation
import UIKit

class ViewController: UIViewController {
    
    public static let PER_PAGE: Int = 9
    public var page: Int = 0

    var player: AVAudioPlayer?
    var startCenter: CGPoint = .zero
    var buts: [UIButton] = []
    
    let impact = UIImpactFeedbackGenerator()
    
    @IBOutlet weak var button0: UIButton!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!
    @IBOutlet weak var button7: UIButton!
    @IBOutlet weak var button8: UIButton!
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.buts = [button0, button1, button2, button3, button4, button5, button6, button7, button8]
        var count = 0 + (ViewController.PER_PAGE * page)
        for but in buts {
            but.tag = count
            count = count + 1
            but.layer.borderWidth = 1.0
            but.layer.borderColor = UIColor.black.cgColor
            but.titleLabel?.lineBreakMode = .byWordWrapping
            but.titleLabel?.textAlignment = .center
        }
        
        setupNav()
        setupView()
        setupButtons()
        setupChevrons()
    }
    
    func setupNav() {
        self.navigationItem.hidesBackButton = true
        self.title = "\(page + 1)"
        
        var editTitle: String = "Edit"
        if (isEditing) {
            editTitle = "End Edit"
        }
        let rightButtonItem = UIBarButtonItem.init(
            title: editTitle,
            style: .done,
            target: self,
            action: #selector(editTapped)
        )
        
        self.navigationItem.rightBarButtonItem = rightButtonItem
    }
    
    func setupView() {
        self.view.backgroundColor = UIColor.black
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        leftSwipe.direction = .left
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        rightSwipe.direction = .right
        
        self.view.addGestureRecognizer(leftSwipe)
        self.view.addGestureRecognizer(rightSwipe)
        self.view.isUserInteractionEnabled = true
    }
    
    func setupButtons() {
        var count = 0 + (ViewController.PER_PAGE * page)
        for but in buts {
            let str = AppDelegate.groupDefaults().string(forKey: String(count)) ?? String(count)
            but.setTitle(str, for: .normal)
            count = count + 1
            
            if count < 4 {
                but.backgroundColor = colorForFeatured()
            } else {
                but.backgroundColor = colorForPage(page: page + 1)
            }
            but.setTitleColor(UIColor.white, for: .normal)
            
            resetButton(but: but)
            
            if !isEditing {
                but.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
                but.addTarget(self, action: #selector(touchDown), for: .touchDown)
                
                let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(buttonSwipe(_:)))
                leftSwipe.direction = .left
                but.addGestureRecognizer(leftSwipe)
                
                let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(buttonSwipe(_:)))
                rightSwipe.direction = .right
                but.addGestureRecognizer(rightSwipe)
            } else {
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedView(_:)))
                but.isUserInteractionEnabled = true
                but.addGestureRecognizer(panGesture)
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedView(_:)))
                but.addGestureRecognizer(tapGesture)
                
                but.shake()
            }
        }
    }
    
    func setupChevrons() {
        leftButton.isHidden = page == 0 ? true : false
    }
    
    @objc func editTapped(sender: UIBarButtonItem) {
        isEditing = !isEditing
        setupNav()
        setupButtons()
    }
    
    func resetButton(but: UIButton) {
        but.layer.removeAllAnimations()
        
        but.removeTarget(self, action: #selector(touchUp), for: .touchUpInside)
        but.removeTarget(self, action: #selector(touchDown), for: .touchDown)

        if let gestures = but.gestureRecognizers {
            for gesture in gestures {
                but.removeGestureRecognizer(gesture)
            }
        }
    }
    
    @objc func swipe(_ sender:UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left:
            swipeNext()
        case .right:
            swipePrev()
        default:
            print("")
        }
    }
    
    @objc func buttonSwipe(_ sender:UISwipeGestureRecognizer) {
        if sender.state == .ended {
            player?.stop()
        }
    }
    
    @IBAction func swipePrev() {
        if (page > 0) {
            self.navigationController?.popViewController(animated: true);
            setupChevrons()
        }
    }
    
    @IBAction func swipeNext() {
        let nextPage = page + 1;
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            vc.page = nextPage
            self.navigationController?.pushViewController(vc, animated: true)
            setupChevrons()
        }
    }
    
    @objc func tappedView(_ gesture:UIPanGestureRecognizer) {
        if let v = gesture.view {
            let vstr = AppDelegate.groupDefaults().string(forKey: String(v.tag)) ?? String(v.tag)
            
            let controller = UIAlertController(title: vstr, message: "Choose:", preferredStyle: .actionSheet)
            let renameAction = UIAlertAction(title: "Rename", style: .default, handler: { (action) -> Void in
                self.rename(tag: v.tag)
            })
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                self.delete(tag: v.tag)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            })
            controller.addAction(renameAction)
            controller.addAction(deleteAction)
            controller.addAction(cancelAction)
            self.navigationController!.present(controller, animated: true) {
                print("presented")
            }
        }
    }
    
    @objc func draggedView(_ gesture:UIPanGestureRecognizer) {
        let v = gesture.view!
        //print("dragging \(v.tag)")
        if gesture.state == .began {
            startCenter = v.center
            impact.impactOccurred()
        }
        if gesture.state == .changed {
            self.view.bringSubview(toFront: v)
            let translation = gesture.translation(in: self.view)
            v.center = CGPoint(x: v.center.x + translation.x, y: v.center.y + translation.y)
            gesture.setTranslation(CGPoint.zero, in: self.view)
        }
        if gesture.state == .ended {
            var moved = false
            var count = 0;
            for but in buts {
                if v.tag != but.tag {
                    let vcvt = cvtFrame(v: v).insetBy(dx: 20, dy: 20)
                    let bcvt = cvtFrame(v: but).insetBy(dx: 20, dy: 20)
                    if vcvt.intersects(bcvt) {
                        let vstr = AppDelegate.groupDefaults().string(forKey: String(v.tag)) ?? String(v.tag)
                        let butstr = AppDelegate.groupDefaults().string(forKey: String(but.tag)) ?? String(but.tag)

                        AppDelegate.groupDefaults().set(vstr, forKey: String(but.tag))
                        AppDelegate.groupDefaults().set(butstr, forKey: String(v.tag))
                        
                        moved = true
                        break
                    }
                }
                count = count + 1;
            }
            v.center = startCenter
            setupButtons()
            if (moved) {
                impact.impactOccurred()
            }
        }
    }
    
    func cvtFrame(v:UIView) -> CGRect {
        let hstackview = v.superview!
        let vstackview = hstackview.superview!
        let frame = hstackview.convert(v.frame, to: vstackview)
        //print("\(frame)")
        let frame2 = vstackview.convert(frame, to: self.view)
        //print("\(frame2)")
        return frame2
    }
    
    func delete(tag: Int) {
        let vstr = AppDelegate.groupDefaults().string(forKey: String(tag)) ?? String(tag)
        let alert = UIAlertController(title: "Confirm", message: "Delete \(vstr)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { action in
            //TODO delete file??
            AppDelegate.groupDefaults().set(String(tag), forKey: String(tag))
            self.setupButtons()
        })
        alert.addAction(UIAlertAction(title: "No", style: .default) { action in
        })
        self.navigationController!.present(alert, animated: true, completion: nil)
    }
    
    func rename(tag: Int) {
        let vstr = AppDelegate.groupDefaults().string(forKey: String(tag)) ?? String(tag)
        let alertController = UIAlertController(title: "Rename", message: "", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Done", style: .default) { (_) in
            if let name = alertController.textFields?[0].text {
                if name != vstr {
                    self.renameAudioFile(tag: tag, toName: name)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.text = vstr
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func renameAudioFile(tag: Int, toName: String) {
        let fm = FileManager.default
        let vstr = AppDelegate.groupDefaults().string(forKey: String(tag)) ?? String(tag)
        let types = ["mp3","m4a","wav"]
        for t in types {
            let soundfile = fm.groupDirectory.appendingPathComponent(vstr).appendingPathExtension(t)
            if fm.fileExists(atPath: soundfile.path) {
                let newfilename = fm.groupDirectory.appendingPathComponent(toName).appendingPathExtension(t)
                do {
                    try fm.moveItem(at: soundfile, to: newfilename)
                    AppDelegate.groupDefaults().set(toName, forKey: String(tag))
                    self.setupButtons()
                } catch {
                    print("\(error)")
                }
                break
            }
        }
    }
    
    @objc func touchDown(sender: UIButton) {
        let fm = FileManager.default
        if let label = sender.titleLabel {
            let types = ["mp3","m4a","wav"]
            var url: URL?
            for t in types {
                let soundfile = fm.groupDirectory.appendingPathComponent(label.text!).appendingPathExtension(t)
                if fm.fileExists(atPath: soundfile.path) {
                    url = soundfile
                    break
                }
                
            }
            if let u = url {
                impact.impactOccurred()
                playSound(url: u)
            }
        }
    }
    
    @objc func touchUp(sender: UIButton) {
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
    
    func colorForPage(page:Int) -> UIColor {
        if page % 2 == 0 {
            return UIColor.brightBlueColor
        }
        return UIColor.red
    }
    
    func colorForFeatured() -> UIColor {
        return UIColor.deepRedColor
    }

}

extension UIButton {
    
    private func degreesToRadians(_ x: CGFloat) -> CGFloat {
        return .pi * x / 180.0
    }
    
    func shake(duration: Double = 0.25, displacement: CGFloat = 1.0, degreesRotation: CGFloat = 2.0) {
            let negativeDisplacement = -1.0 * displacement
            let position = CAKeyframeAnimation.init(keyPath: "position")
            position.beginTime = 0.8
            position.duration = duration
            position.values = [
                NSValue(cgPoint: CGPoint(x: negativeDisplacement, y: negativeDisplacement)),
                NSValue(cgPoint: CGPoint(x: 0, y: 0)),
                NSValue(cgPoint: CGPoint(x: negativeDisplacement, y: 0)),
                NSValue(cgPoint: CGPoint(x: 0, y: negativeDisplacement)),
                NSValue(cgPoint: CGPoint(x: negativeDisplacement, y: negativeDisplacement))
            ]
            position.calculationMode = "linear"
            position.isRemovedOnCompletion = false
            position.repeatCount = Float.greatestFiniteMagnitude
            position.beginTime = CFTimeInterval(Float(arc4random()).truncatingRemainder(dividingBy: Float(25)) / Float(100))
            position.isAdditive = true
            
            let transform = CAKeyframeAnimation.init(keyPath: "transform")
            transform.beginTime = 2.6
            transform.duration = duration
            transform.valueFunction = CAValueFunction(name: kCAValueFunctionRotateZ)
            transform.values = [
                degreesToRadians(-1.0 * degreesRotation),
                degreesToRadians(degreesRotation),
                degreesToRadians(-1.0 * degreesRotation)
            ]
            transform.calculationMode = "linear"
            transform.isRemovedOnCompletion = false
            transform.repeatCount = Float.greatestFiniteMagnitude
            transform.isAdditive = true
            transform.beginTime = CFTimeInterval(Float(arc4random()).truncatingRemainder(dividingBy: Float(25)) / Float(100))
            
            self.layer.add(position, forKey: "pos")
            self.layer.add(transform, forKey: "trans")
    }
    
}

