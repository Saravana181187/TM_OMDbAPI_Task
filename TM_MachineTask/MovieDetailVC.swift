//
//  MovieDetailVC.swift
//  TM_MachineTask
//
//  Created by Saravanakumar B on 6/16/22.
//

import UIKit
import SDWebImage
import Alamofire

class MovieDetailVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var directorNameLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var directorNameLblBackView: UIView!
    @IBOutlet weak var directorNameLblBackViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var moreBtnTopConstraints: NSLayoutConstraint!

    var receivedMovieData = NSMutableDictionary()
    var movieDetailData = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        posterImageView.layer.cornerRadius = 5.0
        directorNameLblBackViewHeightConstraints.constant = 0
        moreBtnTopConstraints.priority = UILayoutPriority.init(999)
        self.directorNameLblBackView.isHidden = true
        self.directorNameLbl.isHidden = true
        self.descLbl.isHidden = true
        moreBtn.isSelected = false
        moreBtn.setTitle("Read More", for: .normal)
        // for fun, you can animate the change with this code
        UIView.animate(withDuration: 1.0) {
            self.view.layoutIfNeeded()
        }
        
        showMovieData()
        // Do any additional setup after loading the view.
    }
    
    func showMovieData() {
        if receivedMovieData.count != 0 {
            let imgURL = URL(string: receivedMovieData.object(forKey: "Poster") as! String)
            posterImageView.sd_setImage(with: imgURL, placeholderImage:  UIImage(named: "no-image-icon"))
            
            titleLabel.text = receivedMovieData.object(forKey: "Title") as? String
            yearLabel.text = receivedMovieData.object(forKey: "Year") as? String
            typeLabel.text = receivedMovieData.object(forKey: "Type") as? String
            
            getMovieDetail(imdbID: receivedMovieData.object(forKey: "imdbID") as! String)
        }
    }
    
    //MARK: - Home Api Parsing
    func getMovieDetail(imdbID: String) {
        print ("get more data")
        
        print(OMDBAPI + "apikey=\(API_KEY)&i=" + imdbID)
        var detailAPIStr = OMDBAPI + "apikey=\(API_KEY)&i=" + imdbID
        detailAPIStr = detailAPIStr.replacingOccurrences(of: " ", with: "%20")
        
        APIManager.apiPost(serviceName: detailAPIStr, parameters: nil) { (json:NSDictionary?, statusCode:Int?, error:NSError?) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            let responseDict:NSDictionary = json!
            print(responseDict)
            self.movieDetailData = responseDict
            DispatchQueue.main.async {
                self.directorNameLbl.text = responseDict.object(forKey: "Director") as? String
                self.descLbl.text = responseDict.object(forKey: "Plot") as? String
            }
        }
    }
    
    @IBAction func moreBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.setTitle("Read More", for: .normal)
            self.directorNameLblBackView.isHidden = false
            self.directorNameLbl.isHidden = false
            self.descLbl.isHidden = false
        } else {
            sender.setTitle("Read Less", for: .normal)
            self.directorNameLblBackView.isHidden = true
            self.directorNameLbl.isHidden = true
            self.descLbl.isHidden = true
            
        }
    }

}
