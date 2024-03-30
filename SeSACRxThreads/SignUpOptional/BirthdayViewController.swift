//
//  BirthdayViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class BirthdayViewController: UIViewController {
  
  let birthDayPicker: UIDatePicker = {
    let picker = UIDatePicker()
    picker.datePickerMode = .date
    picker.preferredDatePickerStyle = .wheels
    picker.locale = Locale(identifier: "ko-KR")
    picker.maximumDate = Date()
    return picker
  }()
  
  let infoLabel: UILabel = {
    let label = UILabel()
    return label
  }()
  
  let containerStackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.distribution = .equalSpacing
    stack.spacing = 10
    return stack
  }()
  
  let yearLabel: UILabel = {
    let label = UILabel()
    label.textColor = Color.black
    label.snp.makeConstraints {
      $0.width.equalTo(100)
    }
    return label
  }()
  
  let monthLabel: UILabel = {
    let label = UILabel()
    label.textColor = Color.black
    label.snp.makeConstraints {
      $0.width.equalTo(100)
    }
    return label
  }()
  
  let dayLabel: UILabel = {
    let label = UILabel()
    label.textColor = Color.black
    label.snp.makeConstraints {
      $0.width.equalTo(100)
    }
    return label
  }()
  
  let disposeBag = DisposeBag()
  let yearText = PublishSubject<Int>()
  let monthText = PublishSubject<Int>()
  let dayText = PublishSubject<Int>()
  
  let nextButton = PointButton(title: "가입하기")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = Color.white
    
    configureLayout()
    bind()
    
    nextButton.addTarget(self, action: #selector(nextButtonClicked), for: .touchUpInside)
  }
  
  @objc func nextButtonClicked() {
    print("가입완료")
  }
  
  
  func configureLayout() {
    view.addSubview(infoLabel)
    view.addSubview(containerStackView)
    view.addSubview(birthDayPicker)
    view.addSubview(nextButton)
    
    infoLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(150)
      $0.centerX.equalToSuperview()
    }
    
    containerStackView.snp.makeConstraints {
      $0.top.equalTo(infoLabel.snp.bottom).offset(30)
      $0.centerX.equalToSuperview()
    }
    
    [yearLabel, monthLabel, dayLabel].forEach {
      containerStackView.addArrangedSubview($0)
    }
    
    birthDayPicker.snp.makeConstraints {
      $0.top.equalTo(containerStackView.snp.bottom)
      $0.centerX.equalToSuperview()
    }
    
    nextButton.snp.makeConstraints { make in
      make.height.equalTo(50)
      make.top.equalTo(birthDayPicker.snp.bottom).offset(30)
      make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
    }
  }
  
  private func bind() {
    yearText
      .map { "\($0)년"}
      .bind(to: yearLabel.rx.text)
      .disposed(by: disposeBag)
    
    monthText
      .map { "\($0)월"}
      .bind(to: monthLabel.rx.text)
      .disposed(by: disposeBag)
    
    dayText
      .map { "\($0)일"}
      .bind(to: dayLabel.rx.text)
      .disposed(by: disposeBag)
    
    birthDayPicker.rx.date
      .map {
        return Calendar.current.dateComponents(
          [.year, .month, .day],
          from: $0)
      }
      .bind(with: self) { owner, date in
        
        owner.yearText.onNext(date.year!)
        owner.monthText.onNext(date.month!)
        owner.dayText.onNext(date.day!)
      }
      .disposed(by: disposeBag)
    
    let validation = birthDayPicker.rx.date
      .map { Calendar.current.dateComponents([.year], from: $0, to: .now) }
      .compactMap { $0.year }
      .withUnretained(self)
      .map { $0.isAdult(year: $1) }
    
    validation
      .bind(to: nextButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    validation
      .withUnretained(self)
      .map { $0.validationInfoText(isAdult: $1) }
      .bind(to: infoLabel.rx.text)
      .disposed(by: disposeBag)
    
    validation
      .withUnretained(self)
      .map { $0.validationInfoTextColor(isAdult: $1) }
      .bind(to: infoLabel.rx.textColor)
      .disposed(by: disposeBag)
    
    validation
      .withUnretained(self)
      .map { $0.validationNextButtonColor(isAdult: $1) }
      .bind(to: nextButton.rx.backgroundColor)
      .disposed(by: disposeBag)
  }
  
  private func isAdult(year: Int) -> Bool {
    return year >= 17
  }
  
  private func validationInfoText(isAdult: Bool) -> String {
    return isAdult ? "가입 가능한 나이입니다" : "만 17세 이상만 가입 가능합니다"
  }
  
  private func validationInfoTextColor(isAdult: Bool) -> UIColor {
    return isAdult ? .systemBlue : .systemRed
  }
  
  private func validationNextButtonColor(isAdult: Bool) -> UIColor {
    return isAdult ? .systemBlue : .lightGray
  }
}
