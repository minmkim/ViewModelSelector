//
//  LoginViewController.swift
//  ViewModelsAsFunctions
//
//  Created by DJ Mitchell on 12/22/18.
//  Copyright © 2018 Killectro. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    @IBOutlet private var usernameTextField: UITextField!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var loginButton: UIButton!
    @IBOutlet weak var countryField: UILabel!

    private let tapGesture = UITapGestureRecognizer()

    private let _didSelectCountry = PublishRelay<Country>()

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()

        let (
            loginButtonEnabled,
            showSuccessMessage,
            presentCountrySelector,
            countryFieldText
        ) = loginViewModel(
            usernameChanged: usernameTextField.rx.text.orEmpty.asObservable(),
            passwordChanged: passwordTextField.rx.text.orEmpty.asObservable(),
            loginTapped: loginButton.rx.tap.asObservable(),
            countryFieldTapped: tapGesture.rx.event.map { _ in () }.asObservable().debug("tap"),
            didSelectCountry: _didSelectCountry.asObservable()
        )

        disposeBag.insert(
            loginButtonEnabled
                .bind(to: loginButton.rx.isEnabled),

            showSuccessMessage
                .subscribe(onNext: { [weak self] message in
                    self?.showSuccessMessage(message)
                }),

            presentCountrySelector.debug("present")
                .flatMap(CountrySelector.init
                    >>> presentController
                )
                .flatMap { $0.didSelectCountry }
                .bind(to: _didSelectCountry),

            countryFieldText
                .bind(to: countryField.rx.text)
        )
    }

    private func setupViews() {
        loginButton.setBackgroundImage(
            .from(color: .black),
            for: .normal
        )

        loginButton.setBackgroundImage(
            .from(color: .lightGray),
            for: .disabled
        )

        countryField.addGestureRecognizer(tapGesture)
        countryField.isUserInteractionEnabled = true
    }

    private func showSuccessMessage(_ message: String) {
        let alert = UIAlertController(
            title: "Success!",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            .init(
                title: "OK",
                style: .default,
                handler: nil
            )
        )

        present(alert, animated: true, completion: nil)
    }
}

private extension UIImage {
    static func from(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)

        UIGraphicsBeginImageContext(rect.size)
        defer { UIGraphicsEndImageContext() }

        let context = UIGraphicsGetCurrentContext()

        context?.setFillColor(color.cgColor)
        context?.fill(rect)

        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UIViewController {

    func presentController<T: UIViewController>(_ controller: T) -> Observable<T> {
        return Observable.create { [weak self] obs in
            self?.navigationController?.present(
                UINavigationController(rootViewController: controller),
                animated: true,
                completion: {
                    obs.onNext(controller)
                    obs.onCompleted()
                }
            )
            return Disposables.create()
        }
    }
}

infix operator >>>

public func >>> <A, B, C>(_ a2b: @escaping (A) -> B, _ b2c: @escaping (B) -> C) -> (A) -> C {
    return { a in b2c(a2b(a)) }
}
