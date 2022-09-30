//
//  EYEPopularWeekController.swift
//  EyepetizerApp
//
//  Created by 梁亦明 on 16/3/20.
//  Copyright © 2016年 xiaoming. All rights reserved.
//

import UIKit
import Alamofire

class EYEPopularWeekController: UIViewController, LoadingPresenter {

    /// 加载view
    var loaderView : EYELoaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(collectionView)
        
        // 获取数据
        setupLoaderView()
        getData()
    }
    //MARK: --------------------------- Private Methods --------------------------
    private func getData(api : String = EYEAPIHeaper.API_Popular_Weakly) {
        setLoaderViewHidden(false)
        Alamofire.request(.GET, api).responseSwiftyJSON ({ [unowned self](request, response, json, error) -> Void in
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
    private var modelList : [ItemModel] = [ItemModel]()
    
    /// collectionView
    private lazy var collectionView : EYECollectionView = {
        
        let rect = CGRect.init(x: 0, y: 0, width: UIConstant.SCREEN_WIDTH, height: UIConstant.SCREEN_HEIGHT-UIConstant.UI_TAB_HEIGHT-UIConstant.UI_CHARTS_HEIGHT-UIConstant.UI_NAV_HEIGHT)
        var collectionView : EYECollectionView = EYECollectionView(frame: rect, collectionViewLayout:EYECollectionLayout())
        let layout = collectionView.collectionViewLayout as! EYECollectionLayout
        layout.footerReferenceSize = CGSize(width: collectionView.width, height: 50)
        collectionView.register(EYEPopularFooterView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: EYEPopularFooterView.reuseIdentifier)

        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
   
}

 //MARK: --------------------------- UICollectionViewDelegate,UICollectionViewDataSource --------------------------
extension EYEPopularWeekController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modelList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = cell as! EYEChoiceCell
        cell.model = modelList[indexPath.row]
        cell.index = "\(indexPath.row+1)"
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EYEChoiceCell.reuseIdentifier, for: indexPath as IndexPath) as! EYEChoiceCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if self.parent is EYEPopularController {
            (parent as! EYEPopularController).selectCell = collectionView.cellForItem(at: indexPath as IndexPath) as! EYEChoiceCell
        }
        
        let model = modelList[indexPath.row]
        self.navigationController?.pushViewController(EYEVideoDetailController(model: model), animated: true)
    }
    
    /**
     *  section FootView
     */
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let footView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: EYEPopularFooterView.reuseIdentifier, for: indexPath as IndexPath)
        return footView
    }
}


