//
//  ProfileController.swift
//  BodyDetection
//
//  Created by Kewal Kishan Gokuldas on 11/11/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import UIKit

class ProfileController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var compete = ["Nikhil", "Abhay", "Richard", "Abhi"]
    var songs = ["What is love", "Kinni Kinni" , "Bol Na Halke Halke", "Bhaire Naine"]
    var dates = ["11/11/2023", "11/10/2023" , "11/10/2023", "11/09/2023"]
    var firstLabel = ["What is love", "Kinni Kinni" , "Bol Na Halke Halke", "Bhaire Naine"]
    var secondLabel = ["11/11/2023", "11/10/2023" , "11/10/2023", "11/09/2023"]
    var thirdLabel = ["", "" , "", ""]
    var percentage = ["45%", "30%", "60%", "90%"]
    var blank = ["", "" , "", ""]
    
    @IBOutlet weak var competeButton: UIButton!
    @IBOutlet weak var myStepsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        competeButton.addTarget(self, action: #selector(competePressed), for: .touchDown)
        myStepsButton.addTarget(self, action: #selector(mystepsPressed), for: .touchDown)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @objc func competePressed() {
        print("compete pressed")
        firstLabel = compete
        secondLabel = percentage
        thirdLabel = songs
        tableView.reloadData()
        if #available(iOS 15.0, *) {
            competeButton.configuration?.baseForegroundColor = .tintColor
            competeButton.setTitleColor(.tintColor, for: .normal)
            myStepsButton.configuration?.baseForegroundColor = .label
            myStepsButton.setTitleColor(.label, for: .normal)
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func mystepsPressed() {
        print("my steps pressed")
        firstLabel = songs
        secondLabel = dates
        thirdLabel = blank
        tableView.reloadData()
        if #available(iOS 15.0, *) {
            competeButton.configuration?.baseForegroundColor = .label
            competeButton.setTitleColor(.label, for: .normal)
            myStepsButton.configuration?.baseForegroundColor = .tintColor
            myStepsButton.setTitleColor(.tintColor, for: .normal)
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell") as! ProfileTableViewCell
        cell.danceLabel.text = firstLabel[indexPath.row]
        cell.danceDate.text = secondLabel[indexPath.row]
        cell.dancerLabel.text = thirdLabel[indexPath.row]

        return cell
    }
    
    private func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell") as! ProfileTableViewCell

        // Configure YourCustomCell using the outlets that you've defined.

        return cell
    }
}
