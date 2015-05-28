//
//  FlyersCollectionViewController.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import RealmSwift

let reuseIdentifier = "Flyer"

protocol FlyersCollectionViewControllerDelegate{
    func heightOfTransportArea()->CGFloat
}

class FlyersCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, FlyerCollectionViewCellDelegate {
    var runs: Results<PlaylistRun>!
    var delegate: FlyersCollectionViewControllerDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        reload(nil)
    }
    func reload(callback:(()->Void)?){
        runs = Realm().objects(PlaylistRun)
        if let run = runs.last{
            var urls = [String]()
            for item in run.items{
                urls.append(item.songKickArtist.imageUrl())
            }
            preload(urls){
                self.collectionView?.reloadData()
                callback?()                    
            }
        }
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return runs.count
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return runs[section].items.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FlyerCollectionViewCell
    
        let playlistItem = playlistItemAtIndexPath(indexPath)
        cell.playlistItem = playlistItem
        cell.delegate = self
        cell.baselineConstraint.constant = delegate.heightOfTransportArea()
        playlistItem?.determineSoundCloudUser({ (user, error) -> Void in
            playlistItem?.determineTracksAvailable({ (trackCount, error) -> Void in
                if cell.playlistItem == playlistItem{
                    cell.playlistItem = playlistItem // update if it's not been reused by now.
                }
            })
        })
        return cell
    }

    func playlistItemAtIndexPath(indexPath:NSIndexPath)->PlaylistItem?{
        return runs[indexPath.section].items[indexPath.row]
    }
    func flyerCellShowEventButtonPressed(event: SongKickEvent) {
        if let controller = storyboard?.instantiateViewControllerWithIdentifier("GigPage") as? GigInfoViewController{
            controller.event = event
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    func flyerCellPlayButtonPressed(item: PlaylistItem) {
        
    }
    func flyerCellTrackCountButtonPressed(item: PlaylistItem) {
        if let nav = storyboard?.instantiateViewControllerWithIdentifier("EditPlaylistItemNav") as? UINavigationController{
            if let root = nav.topViewController  as? EditPlaylistItemViewController{
                root.playlistItem = item
                presentViewController(nav, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: Layout Delegate
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        return CGSize(width: collectionView.frame.width , height: collectionView.frame.size.height)
    }
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}