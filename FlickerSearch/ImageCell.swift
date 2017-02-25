//
//  ImageCellTableViewCell.swift
//  FlickerSearch
//
//  Created by swarnima on 25/02/17.
//  Copyright © 2017 Swarnima. All rights reserved.
//

import UIKit

class ImageCell: UITableViewCell {

    static let reuse_Identifier = "image_cell"
    
    @IBOutlet var imgView: UIImageView!
    
    @IBOutlet var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateCellWithModel(model:PhotoModel?) {
        
        if model != nil {
            
            title.text = model?.title
            downloadAndDisplayImg(urlString: (model?.imgUrl)!)

        }
    }
    
    func downloadAndDisplayImg(urlString:String) {
        
        URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                //print(error)
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data!)
                self.imgView.image = image
            }

            
        }).resume()
    }
    

}
