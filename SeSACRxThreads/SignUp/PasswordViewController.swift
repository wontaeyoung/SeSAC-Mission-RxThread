//
//  PasswordViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class PasswordViewController: UIViewController {
  
  private let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요").configured {
    $0.isSecureTextEntry = true
  }
  
  private let confirmPasswordTextField = SignTextField(placeholderText: "비밀번호를 한번 더 입력해주세요").configured {
    $0.isSecureTextEntry = true
  }
  
  private let passwordValidationLabel = UILabel()
  private let confirmPasswordValidationLabel = UILabel()
  private let nextButton = PointButton(title: "다음")
  
  private let disposebag = DisposeBag()
  private let viewModel = PasswordViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = Color.white
    
    configureLayout()
    bind()
  }
  
  func configureLayout() {
    view.addSubviews(
      passwordTextField,
      confirmPasswordTextField,
      passwordValidationLabel,
      confirmPasswordValidationLabel,
      nextButton
    )
    
    passwordTextField.snp.makeConstraints { make in
      make.height.equalTo(50)
      make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
      make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
    }
    
    passwordValidationLabel.snp.makeConstraints { make in
      make.height.equalTo(20)
      make.top.equalTo(passwordTextField.snp.bottom).offset(5)
      make.leading.equalTo(passwordTextField)
    }
    
    confirmPasswordTextField.snp.makeConstraints { make in
      make.height.equalTo(50)
      make.top.equalTo(passwordValidationLabel.snp.bottom).offset(20)
      make.horizontalEdges.equalTo(passwordTextField)
    }
    
    confirmPasswordValidationLabel.snp.makeConstraints { make in
      make.height.equalTo(20)
      make.top.equalTo(confirmPasswordTextField.snp.bottom).offset(5)
      make.leading.equalTo(passwordTextField)
    }
    
    nextButton.snp.makeConstraints { make in
      make.height.equalTo(50)
      make.top.equalTo(confirmPasswordValidationLabel.snp.bottom).offset(20)
      make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
    }
  }
  
  func bind() {
    let input = PasswordViewModel.Input(password: .init(), confirmPassword: .init())
    let output = viewModel.transform(input: input)
    
    output.lengthValidation
      .map { $0 ? "사용 가능한 비밀번호에요" : "비밀번호는 8자 이상 16자 이하만 가능해요" }
      .drive(passwordValidationLabel.rx.text)
      .disposed(by: disposebag)
    
    output.lengthValidation
      .map { self.validationColor(condition: $0) }
      .drive(passwordValidationLabel.rx.textColor)
      .disposed(by: disposebag)
    
    output.equalValidation
      .map { $0 ? "" : "비밀번호가 일치하지 않아요" }
      .drive(confirmPasswordValidationLabel.rx.text)
      .disposed(by: disposebag)
    
    output.equalValidation
      .map { self.validationColor(condition: $0) }
      .drive(confirmPasswordValidationLabel.rx.textColor)
      .disposed(by: disposebag)
    
    output.validation
      .debug()
      .drive(nextButton.rx.isEnabled)
      .disposed(by: disposebag)
    
    passwordTextField.rx.text.orEmpty
      .bind(to: input.password)
      .disposed(by: disposebag)
    
    passwordTextField.rx.text.orEmpty
      .map { $0.isEmpty }
      .bind(to: passwordValidationLabel.rx.isHidden)
      .disposed(by: disposebag)
    
    confirmPasswordTextField.rx.text.orEmpty
      .bind(to: input.confirmPassword)
      .disposed(by: disposebag)
    
    confirmPasswordTextField.rx.text.orEmpty
      .map { $0.isEmpty }
      .bind(to: confirmPasswordValidationLabel.rx.isHidden)
      .disposed(by: disposebag)
    
    nextButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.showNextView()
      }
      .disposed(by: disposebag)
  }
  
  private func validationColor(condition: Bool) -> UIColor {
    return condition ? .systemGreen : .systemRed
  }
  
  private func showNextView() {
    navigationController?.pushViewController(ShoppingViewController(), animated: true)
  }
}
