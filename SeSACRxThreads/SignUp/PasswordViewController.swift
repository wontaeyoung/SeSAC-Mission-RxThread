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
  
  let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
  let nextButton = PointButton(title: "다음")
  
  let descriptionLabel = UILabel()
  let validText = Observable.just("8자 이상 입력해주세요")
  let disposebag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = Color.white
    
    configureLayout()
    bind()
  }
  
  private func showNextView() {
    navigationController?.pushViewController(PhoneViewController(), animated: true)
  }
  
  func configureLayout() {
    view.addSubview(passwordTextField)
    view.addSubview(descriptionLabel)
    view.addSubview(nextButton)
    
    passwordTextField.snp.makeConstraints { make in
      make.height.equalTo(50)
      make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
      make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
    }
    
    descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(passwordTextField.snp.bottom).offset(10)
      make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
      make.height.equalTo(20)
    }
    
    nextButton.snp.makeConstraints { make in
      make.height.equalTo(50)
      make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
      make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
    }
  }
  
  func bind() {
    validText
      .bind(to: descriptionLabel.rx.text)
      .disposed(by: disposebag)
    
    let validation = passwordTextField.rx.text.orEmpty
      .map { $0.count }
      .map { $0 >= 8 }
      .share(replay: 1)
    
    validation
      .map { $0 ? UIColor.systemPink : UIColor.lightGray }
      .bind(to: nextButton.rx.backgroundColor)
      .disposed(by: disposebag)
    
    validation
      .bind(to: nextButton.rx.isEnabled, descriptionLabel.rx.isHidden)
      .disposed(by: disposebag)
    
    nextButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.showNextView()
      }
      .disposed(by: disposebag)
  }
}
