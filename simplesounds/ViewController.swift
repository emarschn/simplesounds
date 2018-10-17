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

struct ColorChange {
    var tag: Int
    var startColor: CGColor
    var endColor: CGColor
}

class ViewController: UIViewController {
    
    public static var colorChanges: [ColorChange]?
    public static var editMode: Bool = false


    public let PER_PAGE: Int = 9
    public let NUM_FEATURED: Int = 3

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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupNav()
        setupView()
        setupButtons()
        setupChevrons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        renderButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        handleColorChangeAnimation()
    }
    
    func setupNav() {
        self.navigationItem.hidesBackButton = true
        self.title = "\(page + 1)"
        
        var editTitle: String = "Edit"
        if (ViewController.editMode) {
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
        self.buts = [button0, button1, button2, button3, button4, button5, button6, button7, button8]
        var count = (PER_PAGE * page)
        for but in buts {
            but.tag = count
            count = count + 1
            but.layer.borderWidth = 1.0
            but.layer.borderColor = UIColor.black.cgColor
            but.titleLabel?.lineBreakMode = .byWordWrapping
            but.titleLabel?.textAlignment = .center
        }
    }
    
    func setupChevrons() {
        leftButton.isHidden = page == 0 ? true : false
    }
    
    func renderButtons() {
        var count = 0 + (PER_PAGE * page)
        for but in buts {
            let str = AppDelegate.groupDefaults().string(forKey: String(count)) ?? String(count)
            but.setTitle(str, for: .normal)
            
            if count < NUM_FEATURED {
                but.layer.backgroundColor = colorForFeatured().cgColor
            } else {
                but.layer.backgroundColor = colorForPage(page: page + 1).cgColor
            }
            
            if let colorChanges = ViewController.colorChanges {
                for colorChange in colorChanges {
                    if (count == colorChange.tag) {
                        but.layer.backgroundColor = colorChange.startColor
                    }
                }
            }
            
            but.setTitleColor(UIColor.white, for: .normal)
            
            resetButton(but: but)
            
            if !ViewController.editMode {
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
            
            count = count + 1
        }
    }
    
    func handleColorChangeAnimation() {
        if let colorChanges = ViewController.colorChanges {
            for colorChange in colorChanges {
                for but in buts {
                    if (but.tag == colorChange.tag) {
                        but.layer.backgroundColor = colorChange.startColor
                        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseInOut, animations: {
                            but.layer.backgroundColor = colorChange.endColor
                        }) { (finished) in
                            ViewController.colorChanges = nil
                        }
                        break;
                    }
                }
            }
        }
    }
    
    @objc func editTapped(sender: UIBarButtonItem) {
        ViewController.editMode = !ViewController.editMode
        setupNav()
        renderButtons()
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
        }
    }
    
    @IBAction func swipeNext() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            vc.page = page + 1
            self.navigationController?.pushViewController(vc, animated: true)
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
                //
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
            let translation = gesture.translation(in: self.view)
            v.center = CGPoint(x: v.center.x + translation.x, y: v.center.y + translation.y)
            gesture.setTranslation(CGPoint.zero, in: self.view)
            //print("\(v.center)")
            v.layer.zPosition = 999
            for but in buts {
                if v.tag != but.tag {
                    let vcvt = cvtFrame(v: v).insetBy(dx: 20, dy: 20)
                    let bcvt = cvtFrame(v: but).insetBy(dx: 20, dy: 20)
                    if vcvt.intersects(bcvt) {
                        but.layer.zPosition = 0
                    } else {
                        but.layer.zPosition = 999
                    }
                }
            }
        }
        if gesture.state == .ended {
            let translation = gesture.translation(in: self.view)
            v.center = CGPoint(x: v.center.x + translation.x, y: v.center.y + translation.y)
            if (v.center.x < 16 && page > 0) {
                self.move(tag: v.tag, page: page - 1, last: true)
                self.swipePrev()
                v.center = startCenter
                renderButtons()
                return
            } else if (v.center.x > self.view.frame.size.width - 16) {
                self.move(tag: v.tag, page: page + 1, last: false)
                self.swipeNext()
                v.center = startCenter
                renderButtons()
                return
            }
            
            var moved = false
            var count = 0;
            for but in buts {
                if v.tag != but.tag {
                    let vcvt = cvtFrame(v: v).insetBy(dx: 20, dy: 20)
                    let bcvt = cvtFrame(v: but).insetBy(dx: 20, dy: 20)
                    if vcvt.intersects(bcvt) {
                        let vstr = AppDelegate.groupDefaults().string(forKey: String(v.tag)) ?? String(v.tag)
                        let butstr = AppDelegate.groupDefaults().string(forKey: String(but.tag)) ?? String(but.tag)

                        ViewController.colorChanges = []
                        AppDelegate.groupDefaults().set(vstr, forKey: String(but.tag))
                        AppDelegate.groupDefaults().set(butstr, forKey: String(v.tag))
                        
                        if (page == 0) {
                            if (but.tag < NUM_FEATURED && v.tag > NUM_FEATURED) {
                                let colorChange = ColorChange(tag: but.tag, startColor: v.layer.backgroundColor!, endColor: colorForFeatured().cgColor)
                                ViewController.colorChanges?.append(colorChange)
                                let colorChange2 = ColorChange(tag: v.tag, startColor: but.layer.backgroundColor!, endColor: colorForPage(page: page + 1).cgColor)
                                ViewController.colorChanges?.append(colorChange2)
                            } else if (v.tag < NUM_FEATURED && but.tag > NUM_FEATURED) {
                                let colorChange = ColorChange(tag: but.tag, startColor: v.layer.backgroundColor!, endColor: colorForPage(page: page + 1).cgColor)
                                ViewController.colorChanges?.append(colorChange)
                                let colorChange2 = ColorChange(tag: v.tag, startColor: but.layer.backgroundColor!, endColor: colorForFeatured().cgColor)
                                ViewController.colorChanges?.append(colorChange2)
                            }
                        }
                        
                        moved = true
                        break
                    }
                }
                count = count + 1;
            }
            v.center = startCenter
            renderButtons()
            handleColorChangeAnimation()
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
    
    func move(tag: Int, page: Int, last: Bool) {
        var replaceTag = String(8 * (page + 1))
        if (!last) {
            replaceTag = String((8 + 1) * (page))
        }
        let fromStr = AppDelegate.groupDefaults().string(forKey: String(tag)) ?? String(tag)
        let toStr = AppDelegate.groupDefaults().string(forKey: replaceTag) ?? replaceTag
        AppDelegate.groupDefaults().set(fromStr, forKey: replaceTag)
        AppDelegate.groupDefaults().set(toStr, forKey: String(tag))
        
        let colorChange = ColorChange(tag: Int(replaceTag)!, startColor: colorForPage(page: page).cgColor, endColor: colorForPage(page: page + 1).cgColor)
        ViewController.colorChanges = [colorChange]
    }
    
    func delete(tag: Int) {
        let vstr = AppDelegate.groupDefaults().string(forKey: String(tag)) ?? String(tag)
        let alert = UIAlertController(title: "Confirm", message: "Delete \(vstr)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { action in
            //TODO delete file??
            AppDelegate.groupDefaults().set(String(tag), forKey: String(tag))
            self.renderButtons()
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
                    self.renderButtons()
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

