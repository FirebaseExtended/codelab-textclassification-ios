// Copyright 2019 The TensorFlow Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var textFieldBottomConstraint: NSLayoutConstraint!

  // TODO: Add an TFLNLClassifier property.

  func loadModel() -> String? {
    return Bundle.main.path(forResource: "text_classification", ofType: "tflite")
  }

  private var results: [ClassificationResult] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationController?.navigationBar.barTintColor =
        UIColor(red: 1, green: 0x6F / 0xFF, blue: 0, alpha: 1)
    navigationController?.navigationBar.titleTextAttributes = [
      NSAttributedString.Key.foregroundColor: UIColor.white
    ]
    navigationController?.navigationBar.isTranslucent = false

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    tableView.dataSource = self
    textField.delegate = self

    // Initialize a TextClassification instance
    _ = loadModel()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillShow(_:)),
                                           name: UIResponder.keyboardWillShowNotification,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillHide(_:)),
                                           name: UIResponder.keyboardWillHideNotification,
                                           object: nil)
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    NotificationCenter.default.removeObserver(self)
  }

  /// Classify the text and display the result.
  private func classify(text: String) {
    
    // TODO: Run sentiment analysis on the input text

    tableView.reloadData()
  }

}

extension ViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return results.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let result = results[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
    var displayText = "Input: \(result.text)\nOutput:\n"
    for (key, value) in result.results {
      displayText.append("\t\(key): \(value)\n")
    }
    cell.textLabel?.text = displayText.trimmingCharacters(in: .whitespacesAndNewlines)
    cell.textLabel?.numberOfLines = 0
    return cell
  }

}

extension ViewController: UITextFieldDelegate {

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
      classify(text: text)
    }
    textField.resignFirstResponder()
    return true
  }

  @objc func keyboardWillShow(_ notification: Notification) {
    if let keyboardFrame =
        notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let keyboardRectangle = keyboardFrame.cgRectValue
      let keyboardHeight = keyboardRectangle.height
      textFieldBottomConstraint.constant = -keyboardHeight
      UIView.animate(withDuration: 0.2) {
        self.view.layoutIfNeeded()
      }
    }
  }

  @objc func keyboardWillHide(_ notification: Notification) {
    textFieldBottomConstraint.constant = 0
    UIView.animate(withDuration: 0.2) {
      self.view.layoutIfNeeded()
    }
  }

}

struct ClassificationResult {

  var text: String
  var results: [String: NSNumber]

}
