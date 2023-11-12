//
//  VideoCollectionViewCell.swift
//  BodyDetection
//
//  Created by Kewal Kishan Gokuldas on 11/11/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import UIKit
import AVFoundation

protocol VideoCollectionViewCellDelegate : AnyObject {
    func didTapLikeButton(with model : VideoModel)
    func didTapCommentButton(with model : VideoModel)
    func didTapDanceButton(with model : VideoModel)
    
}

class VideoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "VideoCollectionViewCell"
    
    private let videoContainer = UIView()
    //LABELS
    private let usernameLabel : UILabel = {
       let label = UILabel()
        label.textAlignment = .left
        label.textColor = .label
        return label
    }()
    
    private let captionLabel : UILabel = {
       let label = UILabel()
        label.textAlignment = .left
        label.textColor = .label
        return label
    }()
    
    private let audioLabel : UILabel = {
       let label = UILabel()
        label.textAlignment = .left
        label.textColor = .label
        return label
    }()
    
    //Button
    private let likeButton : UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
        return button
    }()
    
    private let danceButton : UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
        return button
    }()
    
    private let commentButton : UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: "text.bubble.fill"), for: .normal)
        return button
    }()
    
    weak var delegate: VideoCollectionViewCellDelegate?
    
    
    var player : AVPlayer?
    
    private var model : VideoModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .black
        contentView.clipsToBounds = true
        addSubviews()
    }
    
    private func addSubviews()
    {
        contentView.addSubview(videoContainer)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(captionLabel)
        contentView.addSubview(audioLabel)
        contentView.addSubview(likeButton)
        contentView.addSubview(danceButton)
        contentView.addSubview(commentButton)
        
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchDown)
        danceButton.addTarget(self, action: #selector(didTapDanceButton), for: .touchDown)
        commentButton.addTarget(self, action: #selector(didTapCommentButton), for: .touchDown)
        
        videoContainer.clipsToBounds = true
        contentView.sendSubviewToBack(videoContainer)
    }
    
    @objc private func didTapLikeButton(){
        guard let model = model else {
            return
        }
        delegate?.didTapLikeButton(with: model)
    }
    
    @objc private func didTapCommentButton(){
        guard let model = model else {
            return
        }
        delegate?.didTapCommentButton(with: model)
    }
    
    
    @objc private func didTapDanceButton(){
        guard let model = model else {
            return
        }
        delegate?.didTapDanceButton(with: model)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Buttons
        videoContainer.frame = contentView.bounds
        
        let size = contentView.frame.size.width / 10
        let width = contentView.frame.size.width
        let height = contentView.frame.size.height - 120
        likeButton.frame = CGRect(x : width - size, y : height - size, width : size, height : size)
        commentButton.frame = CGRect(x : width - size, y : height - (size * 2) - 10, width : size, height : size)
        danceButton.frame = CGRect(x : width - size, y : height - (size * 3) - 10, width : size, height : size)
        
        audioLabel.frame = CGRect(x : 5 , y : height - 40, width : width - size - 10, height : 50)
        audioLabel.tintColor = .black
        usernameLabel.frame = CGRect(x : 5 , y : height - 80, width : width - size - 10, height : 50)
        captionLabel.frame = CGRect(x : 5 , y : height - 60, width : width - size - 10, height : 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with model : VideoModel)
    {
        self.model = model
        configureVideo()
            
            captionLabel.text = model.caption
            usernameLabel.text = model.username
        audioLabel.text = model.audioTrack
      
    }
    
                                
    override func prepareForReuse() {
            super.prepareForReuse()
        captionLabel.text = nil
        audioLabel.text = nil
        usernameLabel.text = nil
        }
                                
    private func configureVideo()
    {
        guard let model = model else{
            return
        }
        guard let path = Bundle.main.path(forResource: model.videoFileName, ofType: model.videoFileFormat)
        else{
            return
        }
       player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerview = AVPlayerLayer()
        playerview.player = player
        playerview.frame = contentView.bounds
        playerview.videoGravity = .resizeAspectFill
        videoContainer.layer.addSublayer(playerview)
        player?.volume = 0
        player?.play()
    }
    
}

