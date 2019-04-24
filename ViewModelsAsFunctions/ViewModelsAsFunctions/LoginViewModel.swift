//
//  LoginViewModel.swift
//  ViewModelsAsFunctions
//
//  Created by DJ Mitchell on 12/22/18.
//  Copyright © 2018 Killectro. All rights reserved.
//

import Foundation
import RxSwift

func loginViewModel(
    usernameChanged: Observable<String>,
    passwordChanged: Observable<String>,
    loginTapped: Observable<Void>,
    countryFieldTapped: Observable<Void>,
    didSelectCountry: Observable<Country>
) -> (
    loginButtonEnabled: Observable<Bool>,
    showSuccessMessage: Observable<String>,
    presentCountrySelector: Observable<[Country]>,
    countryFieldText: Observable<String>
) {
    let loginButtonEnabled = Observable
        .combineLatest(
            usernameChanged,
            passwordChanged,
            didSelectCountry
        ) { username, password, _ in
            !username.isEmpty && !password.isEmpty
        }
        .startWith(false)
        .distinctUntilChanged()

    let showSuccessMessage = loginTapped
        // Later examples will show how we do real networking here,
        // for now we will just hard-code it
        .map { "Login Successful!" }

    let presentCountrySelector = countryFieldTapped
        .flatMap(fetchCountries)

    let countryFieldText = didSelectCountry
        .map { $0.name }

    return (
        loginButtonEnabled,
        showSuccessMessage,
        presentCountrySelector,
        countryFieldText
    )
}

private func fetchCountries() -> Observable<[Country]> {
    let countries = [
        Country(name: "Country1"),
        Country(name: "Country2"),
        Country(name: "Country3"),
        Country(name: "Country4"),
        Country(name: "Country5"),
    ]
    return .of(countries)
}
