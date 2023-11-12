//
//  CreateDance.swift
//  BodyDetection
//
//  Created by Kewal Kishan Gokuldas on 11/11/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import UIKit



class CreateDanceController : UIViewController {
    @IBOutlet weak var SongUiTableView: UITableView!
    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func moveToAR(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //let mainViewController = storyBoard.instantiateViewController(withIdentifier: "MainBoardController") as! MainBoardController
        let mainViewController = storyBoard.instantiateViewController(withIdentifier: "ARView")
        mainViewController.modalPresentationStyle = .fullScreen
        self.present(mainViewController, animated: true)
    }
   
    
}
