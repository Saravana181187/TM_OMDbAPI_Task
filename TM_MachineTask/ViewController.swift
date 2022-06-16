//
//  ViewController.swift
//  TM_MachineTask
//
//  Created by Saravanakumar B on 6/15/22.
//

import UIKit
import Alamofire
import SDWebImage

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var moviesSearchBar: UISearchBar!
    @IBOutlet weak var searchBackView: UIView!
    @IBOutlet var moviesTableView: UITableView!
    
    var moviesArr = NSMutableArray()
    var nextPageUrl:String!
    var searchTextStr:String = "Marvel"
    var pagingIndex:Int = 1
    var noOfRows = Int()
    var itemLimitReached = Bool()
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moviesTableView.delegate = self
        moviesTableView.dataSource = self
        moviesTableView.tableFooterView = UIView()
        moviesTableView.separatorStyle = .none
        
        //self.moviesTableView.estimatedRowHeight = 122
        //self.moviesTableView.rowHeight = UITableView.automaticDimension
        
        self.moviesTableView.dataSource = self
        self.moviesTableView.delegate = self
        
        moviesSearchBar.delegate = self
        getMoviesData(title: searchTextStr)
        // Do any additional setup after loading the view.
        pagingIndex = 1
        itemLimitReached = false
    }
    
    //MARK: - UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.becomeFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        //items = films
        moviesTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let movieTitle = searchBar.text else { return }
        searchBar.resignFirstResponder()
        searchBar.text = nil
        searchTextStr = movieTitle
        pagingIndex = 1
        getMoviesData(title: movieTitle)
    }
    
    //MARK: - UITableViewDataSource & UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if moviesArr.count == 1{
            noOfRows = 1
            return 1
            
        }else if moviesArr.count == 0{
            noOfRows = 0
            
            return 0
        }
        else if moviesArr.count % 2 == 0{
            noOfRows = moviesArr.count/2
            
            return moviesArr.count/2
        }
        else{
            let temp  = moviesArr.count/2 + moviesArr.count % 2
            noOfRows = temp
            return temp
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoviesGalleryTableCell") as? MoviesGalleryTableCell
        cell?.selectionStyle = .none
        if moviesArr.count > 0 {
            cell?.movieBackView.isHidden = false
            cell?.movieBackSecondView.isHidden = false
            cell?.movieNoMoviesLbl.isHidden = true
            let actualIndex = indexPath.row + indexPath.row
            cell?.loadFirstFoodItems(item: moviesArr.object(at: actualIndex)as! NSDictionary)
            
            cell?.movieBackSecondView.isHidden = true
            if actualIndex+1 < moviesArr.count{
                cell?.loadSecondFoodItems(item: moviesArr.object(at: actualIndex+1)as! NSDictionary)
                cell?.movieBackSecondView.isHidden = false
            }
            cell?.movieBackView.tag = actualIndex
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.gestureTap(_:)))
            cell?.movieBackView.addGestureRecognizer(tap)
            cell?.movieBackView.isUserInteractionEnabled = true
            
            cell?.movieBackSecondView.tag = actualIndex + 1
            let firsttap = UITapGestureRecognizer(target: self, action: #selector(self.firstgestureTap(_:)))
            cell?.movieBackSecondView.addGestureRecognizer(firsttap)
            cell?.movieBackSecondView.isUserInteractionEnabled = true
            
        } else {
            cell?.movieNoMoviesLbl.isHidden = false
            cell?.movieBackView.isHidden = true
            cell?.movieBackSecondView.isHidden = true
        }
        
        if indexPath.row == noOfRows - 1 && self.moviesArr.count % 10 == 0 && self.itemLimitReached == false {
            pagingIndex += 1
            getMoviesData(title: searchTextStr)
            
        }
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
           // print("this is the last cell")
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))

            self.moviesTableView.tableFooterView = spinner
            self.moviesTableView.tableFooterView?.isHidden = false
        }
    }
    
    //MARK: - Tap Gestures for Movie Gallery
    @objc func gestureTap(_ sender: UITapGestureRecognizer) {
        let resultdata = NSMutableDictionary()
        let index = sender.view?.tag
        resultdata.addEntries(from: (moviesArr.object(at: index!)as! NSDictionary) as! [AnyHashable : Any])
        print(resultdata)
        
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailVC") as! MovieDetailVC
        nextViewController.receivedMovieData = resultdata
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @objc func firstgestureTap(_ sender: UITapGestureRecognizer) {
        let resultdata = NSMutableDictionary()
        let index = sender.view?.tag
        resultdata.addEntries(from: (moviesArr.object(at: index!)as! NSDictionary) as! [AnyHashable : Any])
        print(resultdata)
        
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailVC") as! MovieDetailVC
        nextViewController.receivedMovieData = resultdata
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    //MARK: - Home Api Parsing
    func getMoviesData(title: String) {
        print(OMDBAPI + "apikey=\(API_KEY)&s=\(title)&type=movie")
        var searchAPIStr:String = OMDBAPI + "apikey=\(API_KEY)&s=\(title)&type=movie&page=\(pagingIndex)"
        searchAPIStr = searchAPIStr.replacingOccurrences(of: " ", with: "%20")
        print(searchAPIStr)
        
        APIManager.apiPost(serviceName: searchAPIStr, parameters: nil) { (json:NSDictionary?, statusCode:Int?, error:NSError?) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            let responseDict:NSDictionary = json!
            print(responseDict)
            
            if self.pagingIndex > 1 {
                self.itemLimitReached = false
                if responseDict.value(forKey: "Search") != nil {
                    self.moviesArr.addObjects(from: responseDict.value(forKey: "Search") as! [Any])
                }
            } else {
                self.itemLimitReached = false
                self.moviesArr.removeAllObjects()
                if responseDict.value(forKey: "Search") != nil {
                    self.moviesArr.addObjects(from: responseDict.value(forKey: "Search") as! [Any])
                }
            }
            
            print("moviesArr is :: ", self.moviesArr)
            
            if self.moviesArr.count == 0 {
                let alert = UIAlertController(title: "TM_MachineTask", message: "Data Not Available", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            DispatchQueue.main.async {
                self.moviesTableView.reloadData()
            }
        }
    }
    
    
}

