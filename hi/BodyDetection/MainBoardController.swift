//
//  MainBoardController.swift
//  BodyDetection
//
//  Created by Kewal Kishan Gokuldas on 11/11/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import UIKit


struct VideoModel {
    let caption : String
    let username : String
    let audioTrack : String
    let videoFileName : String 
    let videoFileFormat : String 
}

class MainBoardController : UIViewController {
    
    private var collectionView : UICollectionView?
    
    private var data = [VideoModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0..<10 {
            let model = VideoModel(caption: "Dacing my heart out", username: "Kewal", audioTrack: "Kinni Kinni", videoFileName: "dancea",  videoFileFormat:  "mp4")
            data.append(model)
        }
        
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
        layout.sectionInset = UIEdgeInsets(top : 0, left : 0, bottom : 0, right : 0)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.isPagingEnabled = true
        collectionView?.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
        collectionView?.dataSource = self
        view.addSubview(collectionView!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
}

extension MainBoardController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = data[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.identifier , for: indexPath) as! VideoCollectionViewCell
        cell.configure(with: model)
        cell.delegate = self
        return cell
    }
}

extension MainBoardController : VideoCollectionViewCellDelegate {
    func didTapLikeButton(with model: VideoModel) {
        print("Like clicked")
    }
    
    func didTapCommentButton(with model: VideoModel) {
        print("Comment clicked")
    }
    
    func didTapDanceButton(with model: VideoModel) {
        print("Dance clicked")
    }
    
    
}
