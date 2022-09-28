//
//  EYEPopularHistoryController.swift
//  EyepetizerApp
//
//  Created by 梁亦明 on 16/3/23.
//  Copyright © 2016年 xiaoming. All rights reserved.
//

import UIKit
import Alamofire

class EYEPopularHistoryController: UIViewController, LoadingPresenter {

    var loaderView: EYELoaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        setupLoaderView()
        
        getData()
    }
    
    //MARK: --------------------------- Private Methods --------------------------
    private func getData() {
        setLoaderViewHidden(hidden: false)
        Alamofire.request(.GET, EYEAPIHeaper.API_Popular_Historical).responseSwiftyJSON ({ [unowned self](request, response, json, error) -> Void in
            // 字典转模型 刷新数据
            if json != .null && error == nil {
                let dataDict = json.rawValue as! NSDictionary
                let itemArray = dataDict["videoList"] as! NSArray
                
                self.modelList = itemArray.map({ (dict) -> ItemModel in
                    ItemModel(dict: dict as? NSDictionary)
                })
                
                self.collectionView.reloadData()
            }
            
            self.setLoaderViewHidden(true)
            })

    }
    
    //MARK: --------------------------- Getter or Setter --------------------------
    // 模型
    var modelList : [ItemModel] = [ItemModel]()
    
    /// collectionView
    private lazy var collectionView : EYECollectionView = {
        
        let rect = CGRect.init(x: 0, y: 0, width: UIConstant.SCREEN_WIDTH, height: UIConstant.SCREEN_HEIGHT-UIConstant.UI_TAB_HEIGHT-UIConstant.UI_CHARTS_HEIGHT-UIConstant.UI_NAV_HEIGHT)
        var collectionView : EYECollectionView = EYECollectionView(frame: rect, collectionViewLayout:EYECollectionLayout())
        // 注册header
        let layout = collectionView.collectionViewLayout as! EYECollectionLayout
        layout.footerReferenceSize = CGSize(width: collectionView.width, height: 50)
        collectionView.register(EYEPopularFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: EYEPopularFooterView.reuseIdentifier)

        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
}

extension EYEPopularHistoryController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EYEChoiceCell.reuseIdentifier, for: indexPath) as! EYEChoiceCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modelList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.parent is EYEPopularController {
            (self.parent as! EYEPopularController).selectCell = collectionView.cellForItem(at: indexPath) as! EYEChoiceCell
        }
        let model = modelList[indexPath.row]
        self.navigationController?.pushViewController(EYEVideoDetailController(model: model), animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! EYEChoiceCell
        cell.model = modelList[indexPath.row]
        cell.index = "\(indexPath.row+1)"
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: EYEPopularFooterView.reuseIdentifier, for: indexPath)
        return footView
    }
}
