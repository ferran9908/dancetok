//
//  DashBoardController.swift
//  BodyDetection
//
//  Created by Kewal Kishan Gokuldas on 11/11/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import UIKit

class DashBoardController : UIViewController {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet var button1: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped() {
       // let alert = UIAlertController(title: "usERNAM", message: "DASD", preferredStyle: .alert)
        // self.present(alert, animated: true)
       
        if(username.text!.count < 5)
        {
            showToast(message: "Username error!")
        }
        else
        if(password.text!.count < 5)
        {
            showToast(message: "Password error!")
        }
        
        print("Button was tapped \(String(describing: username.text))  \(String(describing: password.text))");
        if(password.text == "admin" && username.text == "admin")
        {
            let storyBoard : UIStoryboard = UIStoryboard(name: "DashBoard", bundle:nil)
            //let mainViewController = storyBoard.instantiateViewController(withIdentifier: "MainBoardController") as! MainBoardController
            let mainViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarController")
            mainViewController.modalPresentationStyle = .fullScreen
            self.present(mainViewController, animated: true)
            print("Button was tapped asda ")
        }
    }
    
    func showToast(message: String, duration: TimeInterval = 3.0) {
        let toastLabel = PaddingLabel(frame: CGRect())
        toastLabel.textInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10) // Set your padding here
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true

        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if let keyWindow = keyWindow {
            keyWindow.addSubview(toastLabel)
            toastLabel.translatesAutoresizingMaskIntoConstraints = false
            toastLabel.bottomAnchor.constraint(equalTo: keyWindow.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
            toastLabel.centerXAnchor.constraint(equalTo: keyWindow.centerXAnchor).isActive = true
            toastLabel.leadingAnchor.constraint(greaterThanOrEqualTo: keyWindow.leadingAnchor, constant: 20).isActive = true
            toastLabel.trailingAnchor.constraint(lessThanOrEqualTo: keyWindow.trailingAnchor, constant: -20).isActive = true

            UIView.animate(withDuration: duration, delay: 0.1, options: .curveEaseOut, animations: {
                toastLabel.alpha = 1.0
            }) { _ in
                UIView.animate(withDuration: duration, delay: duration, options: .curveEaseIn, animations: {
                    toastLabel.alpha = 0.0
                }) { _ in
                    toastLabel.removeFromSuperview()
                }
            }
        }
    }
    
    class PaddingLabel: UILabel {
        var textInsets = UIEdgeInsets.zero {
            didSet { invalidateIntrinsicContentSize() }
        }

        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.inset(by: textInsets))
        }

        override var intrinsicContentSize: CGSize {
            let size = super.intrinsicContentSize
            return CGSize(width: size.width + textInsets.left + textInsets.right,
                          height: size.height + textInsets.top + textInsets.bottom)
        }

        override func sizeToFit() {
            super.sizeToFit()
            frame = frame.inset(by: UIEdgeInsets(top: -textInsets.top,
                                                 left: -textInsets.left,
                                                 bottom: -textInsets.bottom,
                                                 right: -textInsets.right))
        }
    }
}
