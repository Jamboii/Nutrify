//
//  CreateAccountViewController.swift
//  Nutrify
//
//  Created by Alex Benasutti on 3/22/20.
//  Copyright © 2020 Alex Benasutti. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var surveyModels = [Question]()
    var currentQuestion: Question?
    
    required init?(coder aDecoder: NSCoder)
    {
        self.surveyModels = []
        self.currentQuestion = Question(text: "",
                                        answer: Answer(text: "", valid: false, answerType: "nil"),
                                        answers: [],
                                        answerType: "nil")
        super.init(coder: aDecoder)
    }
    
    @IBOutlet var label: UILabel!
    @IBOutlet var table: UITableView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        setUpQuestions()
        configureUI(question: surveyModels.first!)
    }
    
//    override func viewDidLayoutSubviews()
//    {
//        super.viewDidLayoutSubviews()
//    }
    
    private func configureUI(question: Question)
    {
        label.text = question.text
        currentQuestion = question
        table.reloadData()
    }
    
    private func checkAnswer(answer: Answer, question: Question) -> Bool
    {
        return answer.answerType == question.answerType
    }
    
    private func setUpQuestions()
    {
        surveyModels.append(Question(text: "What is your height?",
                                     answer: Answer(text: "", valid: false, answerType: "Double"),
                                     answers: [Answer(text: "180cm", valid: true, answerType: "Double")],
                                     answerType: "Double"))
        surveyModels.append(Question(text: "What is your weight?",
                                     answer: Answer(text: "", valid: false, answerType: "Double"),
                                     answers: [Answer(text: "142lbs", valid: true, answerType: "Double")],
                                     answerType: "Double"))
        surveyModels.append(Question(text: "What is your birth date?",
                                     answer: Answer(text: "", valid: false, answerType: "String"),
                                     answers: [Answer(text: "April 6, 1999", valid: true, answerType: "String")],
                                     answerType: "String"))
        surveyModels.append(Question(text: "What is your gender?",
                                     answer: Answer(text: "", valid: false, answerType: "String"),
                                     answers: [Answer(text: "Male", valid: true, answerType: "String"),
                                               Answer(text: "Female", valid: true, answerType: "String")],
                                     answerType: "String"))
        surveyModels.append(Question(text: "What are your exercise habits?",
                                     answer: Answer(text: "", valid: false, answerType: "String"),
                                     answers: [Answer(text: "Light", valid: true, answerType: "String"),
                                               Answer(text: "Moderate", valid: true, answerType: "String"),
                                               Answer(text: "Active", valid: true, answerType: "String")],
                                     answerType: "String"))
        surveyModels.append(Question(text: "What is your overall weight goal?",
                                     answer: Answer(text: "", valid: false, answerType: "Double"),
                                     answers: [Answer(text: "150lbs", valid: true, answerType: "Double")],
                                     answerType: "Double"))
        surveyModels.append(Question(text: "What is your weekly weight goal?",
                                     answer: Answer(text: "", valid: false, answerType: "Double"),
                                     answers: [Answer(text: "+0.75lbs", valid: false, answerType: "Double")],
                                     answerType: "Double"))
    }
    
    // Table view functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentQuestion?.answers.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = currentQuestion?.answers[indexPath.row].text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let question = currentQuestion else
        {
            return
        }
        
        let answer = question.answers[indexPath.row]
        
        if checkAnswer(answer: answer, question: question)
        {
            // correct, next question
            if let index = surveyModels.firstIndex(where: { $0.text == question.text })
            {
                if index < (surveyModels.count - 1)
                {
                    // next question
                    let nextQuestion = surveyModels[index + 1]
                    print("\(nextQuestion.text)")
                    // currentQuestion = nil
                    configureUI(question: nextQuestion)
                }
                else
                {
                    // end of survey
                    let alert = UIAlertController(title: "Done", message: "Survey completed", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    present(alert, animated: true)
                }
            }
        }
        else
        {
            // wrong
            let alert = UIAlertController(title: "Incorrect", message: "Invalid answer", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
        }
    }
}

struct Question
{
    let text: String
    let answer: Answer
    let answers: [Answer]
    let answerType: String
}

struct Answer
{
    let text: String
    let valid: Bool // true or false
    let answerType: String
}
