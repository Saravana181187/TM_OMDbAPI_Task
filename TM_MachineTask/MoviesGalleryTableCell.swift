//
//  MoviesGalleryTableCell.swift
//  TM_MachineTask
//
//  Created by Saravanakumar B on 6/16/22.
//

import UIKit
import SDWebImage

class MoviesGalleryTableCell: UITableViewCell {
    
    @IBOutlet weak var movieCardView: UIView!
    @IBOutlet weak var movieNoMoviesLbl: UILabel!
    @IBOutlet weak var movieBackView: UIView!
    @IBOutlet weak var movieTitleLbl: UILabel!
    @IBOutlet weak var movieYearLbl: UILabel!
    @IBOutlet weak var moviePosterImgView: UIImageView!
    @IBOutlet weak var movieBackSecondView: UIView!
    @IBOutlet weak var movieTitleSecondLbl: UILabel!
    @IBOutlet weak var movieYearSecondLbl: UILabel!
    @IBOutlet weak var moviePosterSecondImgView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        moviePosterImgView.layer.cornerRadius = 5.0
        moviePosterSecondImgView.layer.cornerRadius = 5.0
    }
    
    //MARK: - Get Image from URL
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.moviePosterImgView.image = UIImage(data: data)
            }
        }
    }
    
    func downloadSecondImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.moviePosterSecondImgView.image = UIImage(data: data)
            }
        }
    }
    
    func loadFirstFoodItems(item:NSDictionary){
        let imgURL = URL(string: item.object(forKey: "Poster") as! String)
        moviePosterImgView.sd_setImage(with: imgURL, placeholderImage:  UIImage(named: "no-image-icon"))
        
        movieTitleLbl.text = item.object(forKey: "Title") as? String
        movieYearLbl.text = item.object(forKey: "Year") as? String
    }
    
    func loadSecondFoodItems(item:NSDictionary){
        let imgSecondURL = URL(string: item.object(forKey: "Poster") as! String)
        self.downloadSecondImage(from: imgSecondURL!)
        
        moviePosterSecondImgView.sd_setImage(with: imgSecondURL, placeholderImage: UIImage(named: "user_profile"), options: SDWebImageOptions.refreshCached, progress: nil, completed: { (image, error, cache, url) in
            if error == nil {
                self.moviePosterSecondImgView.image = image
                print("image is there")
            } else {
                print("error is there")
            }
        })
        
        movieTitleSecondLbl.text = item.object(forKey: "Title") as? String
        movieYearSecondLbl.text = item.object(forKey: "Year") as? String
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
