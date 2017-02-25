//
//  ViewController.swift
//  FlickerSearch
//
//  Created by swarnima on 25/02/17.
//  Copyright © 2017 Swarnima. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var searchBarHeight: NSLayoutConstraint!
    
    var dataModel:SearchModel!
    var lastContentOffset: CGFloat! = 0.0
    //var dataArray = Array<PhotoModel>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeData()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
    }
    
    func initializeData() {
        
        dataModel = SearchModel()
        dataModel.currentPage = 1;
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (dataModel.photoArray != nil) {
            return (dataModel.photoArray)!.count
            
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ImageCell = tableView.dequeueReusableCell(withIdentifier: ImageCell.reuse_Identifier) as! ImageCell
        // if (dataModel.photoArray != nil && (dataModel.photoArray?.count)! >= indexPath.row) {
        cell.updateCellWithModel(model: dataModel.photoArray?[indexPath.row])
        //}
        
        
        
        return cell;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        dataModel.textToSearch = searchText
        dataModel.currentPage = 1
        
        dataModel.photoArray?.removeAll()
        weak var weakSelf = self
        
        
        dataModel.fetchFlickerData { (response) in
            
            weakSelf?.updateData();
            
            //            if response.isSuccess {
            //
            //                weakSelf?.updateData();
            //            }
        }
    }
    
    //    func fetchData(str:String, pageNum:Int) {
    //        dataModel.textToSearch = str
    //        dataModel.currentPage = 1
    //
    //        weak var weakSelf = self
    //
    //        dataModel.fetchFlickerData { (response) in
    //
    //            if response.isSuccess {
    //
    //                weakSelf?.updateData();
    //            }
    //        }
    //    }
    
    func updateData() {
        
        self.tableView.reloadData();
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        if (self.lastContentOffset < scrollView.contentOffset.y) {
            searchBarHeight.constant = 0.0
        } else if (self.lastContentOffset > scrollView.contentOffset.y) {
            searchBarHeight.constant = 50.0
        }
        
        
        if tableView.contentOffset.y > 0 && tableView.contentOffset.y >= (tableView.contentSize.height - tableView.bounds.size.height) {
            
            
            
        }
    }


}

