//
//  CreateDance.swift
//  BodyDetection
//
//  Created by Kewal Kishan Gokuldas on 11/11/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import UIKit



class CreateDanceController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var SongUiTableView: UITableView!
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    var firstLabel = ["Side to Side", "Dance the Night" , "Levitating", "Cupid", "Strangers", "Blank Space"]
    var secondLabel =  ["Ariana", "Dua", "Dua", "Fifty Fifty", "Kenya", "Taylor"]

    
    @IBAction func moveToAR(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //let mainViewController = storyBoard.instantiateViewController(withIdentifier: "MainBoardController") as! MainBoardController
        let mainViewController = storyBoard.instantiateViewController(withIdentifier: "ARView")
        mainViewController.modalPresentationStyle = .fullScreen
        self.present(mainViewController, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return firstLabel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongsTableViewCell") as! SongsTableViewCell
        cell.artistLabel.text = secondLabel[indexPath.row]
        cell.songLabel.text = firstLabel[indexPath.row]

        return cell
    }
    
    private func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongsTableViewCell") as! SongsTableViewCell

        // Configure YourCustomCell using the outlets that you've defined.

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the cell after it's tapped
        tableView.deselectRow(at: indexPath, animated: true)

        // Get the data for the selected row
        let selectedSong = firstLabel[indexPath.row]
        let selectedArtist = secondLabel[indexPath.row]
        arwithSong(song: selectedSong, artist: selectedArtist)
        // Perform an action with the selected data
        //print("Selected song: \(selectedSong) by artist: \(selectedArtist)")

        // For example, navigate to another view controller
        // navigateToDetailsViewController(song: selectedSong, artist: selectedArtist)
    }
    
    func arwithSong(song: String, artist: String){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            if let mainViewController = storyBoard.instantiateViewController(withIdentifier: "ARView") as? ViewController {
                mainViewController.songName = song
                mainViewController.artistName = artist
                mainViewController.modalPresentationStyle = .fullScreen
                self.present(mainViewController, animated: true)
            } else {
                print("Failed to instantiate ARViewController.")
            }
    }
   
    
}
