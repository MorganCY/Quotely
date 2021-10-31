//
//  JournalListViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/27.
//

import Foundation
import UIKit

class JournalListViewController: UIViewController {

    var journals = [Journal]() {
        didSet {
            tableView.reloadData()
        }
    }
    var selectedMonth = Date().getCurrentTime(format: .MM) {
        didSet {
            fetchJournals()
        }
    }
    var selectedYear = Date().getCurrentTime(format: .yyyy)
    let startDate = DateComponents(calendar: .current, year: 2021, month: 2, day: 2).date!

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.backgroundColor = .clear
            collectionView.registerCellWithNib(identifier: JournalListCollectionViewCell.identifier, bundle: nil)
            collectionView.showsHorizontalScrollIndicator = false
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.registerCellWithNib(
                identifier: JournalListTableViewCell.identifier,
                bundle: nil
            )
            tableView.backgroundColor = .clear
            tableView.separatorStyle = .none
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchJournals()

        navigationController?.setupBackButton(color: .white)

        tabBarController?.tabBar.isHidden = true

        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .left)

        collectionView(collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
    }

    override func viewWillDisappear(_ animated: Bool) {

        tabBarController?.tabBar.isHidden = false
    }

    func fetchJournals() {

        JournalManager.shared.fetchJournal(
            month: selectedMonth,
            year: selectedYear) { result in

            switch result {

            case .success(let journals):
                self.journals = journals

            case .failure(let error):
                print(error)
            }
        }
    }
}

extension JournalListViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        let monthlist = Date.getMonthAndYearBetween(from: startDate, to: Date()).reversed() as [String]
        return monthlist.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let monthlist = Date.getMonthAndYearBetween(from: startDate, to: Date()).reversed() as [String]

        guard let item = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: JournalListCollectionViewCell.self),
            for: indexPath
        ) as? JournalListCollectionViewCell else { fatalError("Cannot create item")
        }

        item.layoutItem(month: monthlist[indexPath.item])

        return item
    }
}

extension JournalListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        cell.alpha = 0

        UIView.animate(
            withDuration: 0.5,
            delay: 0.1 * Double(indexPath.row),
            animations: {
                cell.alpha = 1
        })
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let item = collectionView.cellForItem(at: indexPath) as? JournalListCollectionViewCell else { return }

        item.setSelectedStyle()

        let monthlist = Date.getMonthAndYearBetween(from: startDate, to: Date()).reversed() as [String]

        self.selectedMonth = monthlist[indexPath.item]
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        guard let item = collectionView.cellForItem(at: indexPath) as? JournalListCollectionViewCell else { return }

        item.setSelectedStyle()
    }
}

extension JournalListViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        return CGSize(width: view.frame.width * 0.22, height: view.frame.height * 0.15)
    }

}

extension JournalListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let animation = AnimationFactory.takeTurnsFadingIn(duration: 0.5, delayFactor: 0.1)
        let animator = Animator(animation: animation)
            animator.animate(cell: cell, at: indexPath, in: tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        journals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: JournalListTableViewCell.identifier,
            for: indexPath
        ) as? JournalListTableViewCell else {
            fatalError("Cannot create cell")
        }

        let row = indexPath.row

        cell.layoutCell(
            date: Date.dateFormatter.string(from: Date.init(milliseconds: journals[row].createdTime)),
            month: selectedMonth,
            emoji: UIImage.sfsymbol(SFSymbol(rawValue: journals[row].emoji) ?? .smile) ?? UIImage(),
            content: journals[row].content,
            time: Date.timeFormatter.string(from: Date.init(milliseconds: journals[row].createdTime))
        )

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
