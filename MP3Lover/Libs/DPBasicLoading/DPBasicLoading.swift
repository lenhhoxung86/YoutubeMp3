//
//  DPBasicLoading.swift
//  BasicLoading
//
//  Created by Dwi Putra on 1/17/16.
//  Copyright © 2016 dwipp. All rights reserved.
//

import UIKit

class DPBasicLoading: UIView {
    private let centerView: UIView = UIView()
    private let label = UILabel()
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    convenience init(table:UITableView){
        self.init(frame: table.frame)
        label.font = UIFont.systemFont(ofSize: 14)
        table.backgroundView=self
        table.tableFooterView = UIView()
    }
    
    convenience init(table:UITableView, fontName:String){
        self.init(frame: table.frame)
        label.font = UIFont(name: fontName, size: 14)
        table.backgroundView=self
        table.tableFooterView = UIView()
    }
    
    
    convenience init(collection:UICollectionView) {
        self.init(frame: collection.frame)
        label.font = UIFont.systemFont(ofSize: 14)
        collection.backgroundView=self
    }
    
    convenience init(collection:UICollectionView, fontName:String) {
        self.init(frame: collection.frame)
        label.font = UIFont(name: fontName, size: 14)
        collection.backgroundView=self
    }
    
    private func setupView(){
        backgroundColor = UIColor.clear
        centerView.backgroundColor = UIColor.clear
        centerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(centerView)
        
        let views = ["centerView": centerView, "superview": self]
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[superview]-(<=1)-[centerView]",
            options: .alignAllCenterX,
            metrics: nil,
            views: views)
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[superview]-(<=1)-[centerView]",
            options: .alignAllCenterY,
            metrics: nil,
            views: views)
        self.addConstraints(vConstraints)
        self.addConstraints(hConstraints)
    }
    
    private func setupLoading(text:String){
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.gray
        centerView.addSubview(label)
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        centerView.addSubview(activityIndicator)
        
        let viewLoading = ["label": label, "activity": activityIndicator]
        let hConstraintsLoading = NSLayoutConstraint.constraints(withVisualFormat: "|-[activity]-[label]-|", options: [], metrics: nil, views: viewLoading)
        let vConstraintsLabel = NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: [], metrics: nil, views: viewLoading)
        let vConstraintsActivity = NSLayoutConstraint.constraints(withVisualFormat: "V:|[activity]|", options: [], metrics: nil, views: viewLoading)
        
        centerView.addConstraints(hConstraintsLoading)
        centerView.addConstraints(vConstraintsLabel)
        centerView.addConstraints(vConstraintsActivity)
    }
    
    
    func startLoading(text:String){
        setupView()
        setupLoading(text: text)
    }
    
    
    func endLoading(){
        centerView.removeFromSuperview()
        self.removeFromSuperview()
    }
}
