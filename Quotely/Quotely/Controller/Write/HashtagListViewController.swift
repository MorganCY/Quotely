//
//  HashtagListViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/30.
//

import Foundation
import UIKit

class HashtagListViewController: UIViewController {

    let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }

    var hashtagList = [Hashtag]() {
        didSet {
            filteredHashtagList = hashtagList
        }
    }
    var filteredHashtagList = [Hashtag]() {
        didSet {
            tableView.reloadData()
        }
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.registerCellWithNib(identifier: HashtagListTableViewCell.identifier, bundle: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "標籤列表"
        setupSearchBar()
        filteredHashtagList = hashtagList

        fetchHashtags()
    }

    @IBAction func addHashtag(_ sender: UIBarButtonItem) {

        let alert = UIAlertController(title: "新增標籤", message: nil, preferredStyle: .alert)
        alert.addTextField()

        let submitAction = UIAlertAction(title: "提交", style: .default
        ) { [unowned alert] _ in

            guard let writeVC =
                    UIStoryboard.write
                    .instantiateViewController(
                        withIdentifier: String(describing: WriteViewController.self)
                    ) as? WriteViewController else {

                        return
                    }

            guard let textField = alert.textFields?[0] else {

                return
            }

            guard let newHashtag = textField.text else { return }

            self.dismiss(animated: true) {

                writeVC.hashtags.append(newHashtag)
            }
        }

        alert.addAction(submitAction)

        present(alert, animated: true)
    }

    func fetchHashtags() {

        HashtagManager.shared.fetchHashtag(
            postID: nil) { result in

                switch result {

                case .success(let hashtagList):
                    self.hashtagList = hashtagList

                case .failure(let error):
                    print(error)
                }
            }
    }

    func setupSearchBar() {

        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    func search(_ searchText: String) {
        if searchText.isEmpty {
            filteredHashtagList = hashtagList
        } else {
            filteredHashtagList = hashtagList.filter {
                $0.title.contains(searchText)
            }
        }
        tableView.reloadData()
    }
}

extension HashtagListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        let searchText = searchBar.text ?? ""
        search(searchText)
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        filteredHashtagList = hashtagList
    }
}

extension HashtagListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        filteredHashtagList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: HashtagListTableViewCell.identifier,
            for: indexPath
        ) as? HashtagListTableViewCell else {

            fatalError("Cannot create cell")
        }

        cell.layoutCell(hashtag: filteredHashtagList[indexPath.row])
        cell.hideSelectionStyle()

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let animation = AnimationFactory.takeTurnsFadingIn(duration: 0.3, delayFactor: 0.1)
        let animator = Animator(animation: animation)
            animator.animate(cell: cell, at: indexPath, in: tableView)
    }
}
