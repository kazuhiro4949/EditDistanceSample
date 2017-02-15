//
//  EditDistanceConverter.swift
//  Diff
//
//  Copyright © 2017年 kahayash. All rights reserved.
//

import UIKit

class EditDistanceConverter {
    class func convertToTableView<T: Comparable>(old: [T], new: [T]) -> (_ tableView: UITableView) -> Void {
        return { (tableView: UITableView) in
            DispatchQueue.global().async {
                let diff = EditDistanceCalculator(from: old, to: new)
                let ses = diff.compose()
                DispatchQueue.main.async {
                    tableView.beginUpdates()
                    ses.forEach({ (ses) in
                        switch ses.edit {
                        case .add:
                            tableView.insertRows(at: [IndexPath(row: ses.index, section: 0)], with: .fade)
                        case .delete:
                            tableView.deleteRows(at: [IndexPath(row: ses.index, section: 0)], with: .fade)
                        case .common:
                            break
                        }
                    })
                    tableView.endUpdates()
                }
            }

        }
    }
    
    class func convertToTableView<T: Comparable>(from ses: [Ses<T>]) -> (_ tableView: UITableView) -> Void {
        return { (tableView: UITableView) in
            DispatchQueue.main.async {
                tableView.beginUpdates()
                ses.forEach({ (ses) in
                    switch ses.edit {
                    case .add:
                        tableView.insertRows(at: [IndexPath(row: ses.index, section: 0)], with: .fade)
                    case .delete:
                        tableView.deleteRows(at: [IndexPath(row: ses.index, section: 0)], with: .fade)
                    case .common:
                        break
                    }
                })
                tableView.endUpdates()
            }
        }
    }
    
    class func convertToCollectionViewView<T: Comparable>(old: [T], new: [T]) -> (_ collectionView: UICollectionView, _ completion: ((Bool) -> Void)?) -> Void {
        return { (collectionView: UICollectionView, _ completion: ((Bool) -> Void)?) in
            DispatchQueue.global().async {
                let diff = EditDistanceCalculator(from: old, to: new)
                let ses = diff.compose()
                DispatchQueue.main.async {
                    collectionView.performBatchUpdates({
                        ses.forEach({ (ses) in
                            switch ses.edit {
                            case .add:
                                collectionView.insertItems(at: [IndexPath(item: ses.index, section: 0)])
                            case .delete:
                                collectionView.deleteItems(at: [IndexPath(item: ses.index, section: 0)])
                            case .common:
                                break
                            }
                        })
                    }, completion: { (finish) in
                        completion?(finish)
                    })
                }
            }

        }
    }
}
