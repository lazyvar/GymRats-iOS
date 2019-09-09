//
//  LeaderboardCell.swift
//  GymRats
//
//  Created by Mack on 9/8/19.
//  Copyright © 2019 Mack Hasz. All rights reserved.
//

import UIKit

class LeaderboardCell: UITableViewCell {

    var users: [User] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var workouts: [Workout] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UINib(nibName: "HumanCell", bundle: nil), forCellWithReuseIdentifier: "hu")
        collectionView.dataSource = self
        collectionView.delegate = self
    }

}

extension LeaderboardCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
    }
    
}

extension LeaderboardCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hu", for: indexPath) as! HumanCell
        let usa = users[indexPath.row]
        let workoutsForUser = workouts.filter { $0.gymRatsUserId == usa.id }.count

        cell.userImageView.load(avatarInfo: usa)
        cell.humanLabel.text = "\(usa.fullName)\n\(workoutsForUser)"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
}
