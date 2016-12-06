//
//  ViewController.swift
//  WordScramble
//
//  Created by Noah Patterson on 12/5/16.
//  Copyright © 2016 noahpatterson. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UITableViewController {
    
    var allWords  = [String]()
    var usedWords = [String]()
    var wordShownCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(resetWord))
        
        
        if let startWordsPath = Bundle.main.path(forResource: "start", ofType: "txt") {
            if let startWords = try? String(contentsOfFile: startWordsPath) {
              allWords = startWords.components(separatedBy: "\n")
            }
        } else {
            allWords = ["silkworm"]
        }
        
        startGame()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            // [unowned self, ac] (action: UIAlertAction!) in -- action is the parameter required for the closure
            // [unowned self, ac] action in -- simplified because swift knows the type
            [unowned self, ac] _ in // simplifed because we don't use the parameter so it doesn't need a name
            let answer = ac.textFields![0]
            self.submit(answer: answer.text!)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func resetWord() {
        usedWords.removeAll(keepingCapacity: true)
        title = allWords[wordShownCount+1]
        wordShownCount += 1
    }
    
    func startGame() {
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: allWords) as! [String]
        title = allWords[0]
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    func submit(answer: String) {
        let lowerCasedAnswer = answer.lowercased()
        
        if !isOriginal(word: lowerCasedAnswer) {
            showErrorMessage(title: "Word used already", message: "be more creative...")
            return
        }
        
        if !isPossible(word: lowerCasedAnswer) {
            showErrorMessage(title: "Word isn't possible", message: "You can't spell that word from '\(title!.lowercased())'!")
            return
        }
        
        if !isReal(word: lowerCasedAnswer) {
            showErrorMessage(title: "Word not recognized", message: "You can't just make up words")
            return
        }
        
//        if (isOriginal(word: lowerCasedAnswer) && isPossible(word: lowerCasedAnswer) && isReal(word: lowerCasedAnswer)) {
            usedWords.insert(answer, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
//        }
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = title!.lowercased()

        for letter in word.characters {
            if let pos = tempWord.range(of: String(letter)) {
                tempWord.remove(at: pos.lowerBound)
            } else {
                return false
            }
        }
        return true
    }

    func isOriginal(word: String) -> Bool {
        return usedWords.contains(word) ? false : true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.utf16.count)
        let missspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return missspelledRange.location == NSNotFound
    }
    
    func showErrorMessage(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

