//
//  TemplateViewController.swift
//
//  Created by WangBiN on 2025/5/9.
//

import UIKit
import CHTCollectionViewWaterfallLayout

class TemplateViewController: UIViewController ,UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    
    // MARK: - 属性
    private var collectionView: UICollectionView!
    private let viewModel = TemplateViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCollectionView()
        loadData()
    }
    
    private func setupCollectionView() {
        let layout = CHTCollectionViewWaterfallLayout()
        layout.columnCount = 2
        layout.minimumColumnSpacing = 2
        layout.minimumInteritemSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 0, left: 4, bottom: 4, right: 4)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        
        collectionView.register(TemplateCollectionViewCell.self, forCellWithReuseIdentifier: TemplateCollectionViewCell.identifier)
        collectionView.register(TemplateHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "TemplateHeaderView")
        
        view.addSubview(collectionView)
    }

    
    private func loadData() {
        // 假设 viewModel.templates 自动加载或你可以在这里请求网络/本地数据
        viewModel.loadTemplates {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc private func quickCreateAction() {
        print("一键成片按钮点击")
        // 跳转或弹窗等操作
    }


// MARK: - UICollectionViewDataSource & Delegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.templates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = viewModel.templates[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TemplateCollectionViewCell.identifier, for: indexPath) as! TemplateCollectionViewCell
        
        // 计算cell宽度
        let padding: CGFloat = 8
        let columns: CGFloat = 2
        let totalSpacing = (columns + 1) * padding
        let cellWidth = (collectionView.bounds.width - totalSpacing) / columns
        let imageRatio = model.imageHeight / model.imageWidth
        let coverImageHeight = cellWidth * imageRatio
        
        cell.configure(with: model, coverImageHeight: coverImageHeight)
        return cell
    }
    
    // Header视图
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "TemplateHeaderView",
                                                                         for: indexPath) as! TemplateHeaderView
            // 顶部tab切换
            header.onTopTabChanged = { [weak self] index in
                print("顶部tab切换到：\(index)")
                // self?.viewModel.currentTopTab = index
                // self?.reload根据tab刷新数据
            }
            // 二级tab切换
            header.onSecondTabChanged = { [weak self] index in
                print("二级tab切换到：\(index)")
                // self?.viewModel.currentSecondTab = index
                // self?.reload根据tab刷新数据
            }
            // 标签切换
            header.onTagChanged = { [weak self] index in
                print("标签切换到：\(index)")
                // self?.viewModel.currentTag = index
                // self?.reload根据标签刷新数据
            }
            header.quickCreateButton.addTarget(self, action: #selector(quickCreateAction), for: .touchUpInside)
            return header
        }
        return UICollectionReusableView()
    }
    

    // Header高度 - 正确的方法 (CHTCollectionViewDelegateWaterfallLayout)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        heightForHeaderIn section: Int) -> CGFloat {
        // 44(大标题) + 44(搜索) + 34(二级tab) + 32(标签) + 8(底部间距) + 12(顶部间距)
        //会动态调整
        // 这个值应该与 TemplateHeaderView.headerTotalHeight() 的计算结果一致
        return TemplateHeaderView.headerTotalHeight()//44 + 44 + 34 + 32 + 8 + 12
    }
    
    // Cell大小 - 实现这个必需的方法
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = viewModel.templates[indexPath.item]
        guard let layout = collectionViewLayout as? CHTCollectionViewWaterfallLayout else {
            // Fallback or assertion if layout is not CHTCollectionViewWaterfallLayout
            // This should ideally not happen if setup correctly
            return CGSize(width: 50, height: 50) // Default/fallback size
        }
        
        let columns = CGFloat(layout.columnCount)
        // Calculate total horizontal padding
        let horizontalPadding = layout.sectionInset.left + layout.sectionInset.right + (layout.minimumColumnSpacing * (columns - 1))
        
        // Calculate cell width
        let cellWidth = (collectionView.bounds.width - horizontalPadding) / columns
        
        let imageRatio = model.imageHeight / model.imageWidth
        let coverImageHeight = cellWidth * imageRatio
        let titleHeight: CGFloat = 26
        let authorBarHeight: CGFloat = 20 
        let cellHeight = coverImageHeight + 2 + titleHeight + 2 + authorBarHeight // Sum of components + vertical spacing
        
        return CGSize(width: cellWidth, height: cellHeight)
    }


}
