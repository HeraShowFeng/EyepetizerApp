//
//  EYEMenuViewController.swift
//  EyepetizerApp
//
//  Created by 梁亦明 on 16/4/2.
//  Copyright © 2016年 xiaoming. All rights reserved.
//

import UIKit

class EYEMenuViewController: UIViewController, GuillotineMenu {
    

    //MARK: --------------------------- Life Cycle --------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
//         返回按钮
//        self.navigationItem.leftBarButtonItem = leftBarButtonItem

        let blurEffect : UIBlurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.bounds
        self.view.addSubview(blurView)
        self.view.addSubview(tableView)
        tableView.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.top.equalTo(self.view).offset(UIConstant.UI_NAV_HEIGHT)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    //MARK: --------------------------- Event Responce --------------------------
    @objc private func dismissButtonTapped(sende: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    //MARK: --------------------------- Getter and Setter --------------------------
    /// tableview
    private let menuViewCellId = "menuViewCellId"
    let itemArray = ["我的缓存", "功能开关", "我要投稿", "更多应用"]
    private lazy var tableView: UITableView = {
        var tableView: UITableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.tableHeaderView = EYEMenuHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 200))
        tableView.sectionHeaderHeight = 200
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView
    }()
    
    //GuillotineMenu protocol
    lazy var dismissButton: UIButton! = {
        var dismissButton = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        dismissButton.setImage(UIImage(named: "ic_action_menu"), for: .normal)
        dismissButton.addTarget(self, action: #selector(EYEMenuViewController.dismissButtonTapped(sende:)), for: .touchUpInside)
        return dismissButton
    }()
    lazy var titleLabel: UILabel! = {
        var titleLabel = UILabel()
        titleLabel.numberOfLines = 1
        titleLabel.text = "Eyepetizer"
        titleLabel.font = UIFont.customFont_Lobster(fontSize: UIConstant.UI_FONT_16)
        titleLabel.textColor = UIColor.black
        titleLabel.sizeToFit()
        return titleLabel
    }()
}

extension EYEMenuViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: menuViewCellId)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: menuViewCellId)
        }
        cell?.backgroundColor = UIColor.clear
        cell?.contentView.backgroundColor = UIColor.clear
        cell?.selectionStyle = .none
        cell?.textLabel?.textAlignment = .center
        cell?.textLabel?.text = itemArray[indexPath.row]
        return cell!
    }
}
