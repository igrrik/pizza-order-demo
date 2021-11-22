//
//  AuthViewController.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 26.10.2021.
//

import UIKit
import RxCocoa
import RxSwift

final class AuthViewController: UIViewController {
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signInButton: UIButton!

    private let viewModel: AuthViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.self), bundle: Bundle(for: Self.self))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBindings()
        configureActions()
    }

    private func configureBindings() {
        viewModel.username
            .drive(usernameTextField.rx.text)
            .disposed(by: disposeBag)

        viewModel.password
            .drive(passwordTextField.rx.text)
            .disposed(by: disposeBag)

        viewModel.isButtonEnabled
            .drive(signInButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.error
            .emit(onNext: { [weak self] errorString in
                self?.present(error: errorString)
            })
            .disposed(by: disposeBag)
    }

    private func configureActions() {
        usernameTextField.rx.text
            .compactMap { $0 }
            .bind(onNext: viewModel.change(username:))
            .disposed(by: disposeBag)

        passwordTextField.rx.text
            .compactMap { $0 }
            .bind(onNext: viewModel.change(password:))
            .disposed(by: disposeBag)

        signInButton.rx.tap
            .bind(onNext: viewModel.signIn)            
            .disposed(by: disposeBag)
    }
}

