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
    var dataArray = Array<PhotoModel>()
    
    
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

        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ImageCell = tableView.dequeueReusableCell(withIdentifier: ImageCell.reuse_Identifier) as! ImageCell
        
        cell.updateCellWithModel(model: dataArray[indexPath.row])
        
        
        return cell;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        dataModel.textToSearch = searchText
        dataModel.currentPage = 1
        
        dataModel.photoArray?.removeAll()
        weak var weakSelf = self
        
        let result = FlickerDataHelper.fetchData(searchedStr: searchText, searchModel: dataModel)

        if result.isFound {
            
            dataArray = result.arr
            self.updateData()
            
        } else {
            dataModel.fetchFlickerData { (response) in
                FlickerDataHelper.saveSearchedData(arr: weakSelf?.dataModel.photoArray, searchedStr: (weakSelf?.dataModel.textToSearch)!)
                if weakSelf?.dataModel.photoArray != nil {
                     weakSelf?.dataArray = (weakSelf?.dataModel.photoArray)!
                }
               
                weakSelf?.updateData();
            }
        }
        
    }

    
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

