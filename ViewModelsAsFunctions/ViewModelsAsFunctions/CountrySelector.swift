//
//  CountrySelector.swift
//  ViewModelsAsFunctions
//
//  Created by Min Kim on 4/24/19.
//  Copyright © 2019 Killectro. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class CountrySelector: UIViewController {

    lazy var didSelectCountry = _didSelectCountry.asObservable()
    private let _didSelectCountry = PublishRelay<Country>()

    private lazy var tableView = UITableView(frame: .zero, style: .plain)

    private let disposeBag = DisposeBag()

    init(_ countries: [Country]) {
        super.init(nibName: nil, bundle: nil)
        setupViews()
        setupConstraints()

        disposeBag.insert(
            Observable.of(countries)
                .bind(to: tableView.rx.items) { tv, index, country in
                    let cell = tv.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: IndexPath(row: index, section: 0))
                    cell.textLabel?.text = country.name
                    return cell
            },

            tableView.rx.modelSelected(Country.self)
                .bind(to: _didSelectCountry),

            didSelectCountry
                .subscribe(onNext: { [weak self] _ in
                    self?.dismiss(animated: true, completion: nil)
                })
        )
    }

    private func setupViews() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupConstraints() {
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct Country {
    var name: String
}
