//
//  QuoteTableViewController.swift
//  InspoQuotes
//
//  Created by Angela Yu on 18/08/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import StoreKit

class QuoteTableViewController: UITableViewController {
    
    let productId = "com.maready.InspoQuotes.MyQuotePremiumAccess"
    var quotesToShow = [
        "Our greatest glory is not in never falling, but in rising every time we fall. — Confucius",
        "All our dreams can come true, if we have the courage to pursue them. – Walt Disney",
        "It does not matter how slowly you go as long as you do not stop. – Confucius",
        "Everything you’ve ever wanted is on the other side of fear. — George Addair",
        "Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill",
        "Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis"
    ]
    
    let premiumQuotes = [
        "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine. ― Roy T. Bennett",
        "I learned that courage was not the absence of fear, but the triumph over it. The brave man is not he who does not feel afraid, but he who conquers that fear. – Nelson Mandela",
        "There is only one thing that makes a dream impossible to achieve: the fear of failure. ― Paulo Coelho",
        "It’s not whether you get knocked down. It’s whether you get up. – Vince Lombardi",
        "Your true success in life begins only when you make the commitment to become excellent at what you do. — Brian Tracy",
        "Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going. – Chantal Sutherland"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemOrange
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        SKPaymentQueue.default().add(self)
        if isPremiumUser() {
            showPremiumQuotes()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        if isPremiumUser() {
            return quotesToShow.count
        }
        // else
        return quotesToShow.count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)

        if indexPath.row < quotesToShow.count {
            cell.textLabel!.textColor = UIColor.black
            cell.accessoryType = .none
            cell.textLabel!.text = quotesToShow[indexPath.row]
        } else {
            cell.textLabel!.text = "Buy more quotes"
            cell.textLabel!.textColor = UIColor.orange
            cell.accessoryType = .disclosureIndicator
        }
        cell.textLabel!.numberOfLines = 0

        return cell
    }
    
    // MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == quotesToShow.count {
            purchasePremiumQuotes()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
        print("Restore button pressed...")
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    // MARK: - In-App Purchase methods
    
    func purchasePremiumQuotes() {
        if SKPaymentQueue.canMakePayments() {
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productId
            SKPaymentQueue.default().add(paymentRequest)
            print("paymentRequest initialized...")
            
        } else {
            print("User cannot make payments...")
        }
    }

}

extension QuoteTableViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print(".transactionState: \(transaction.transactionState)")
            switch transaction.transactionState {
                case .purchased:
                    print("purchase successful...")
                    SKPaymentQueue.default().finishTransaction(transaction)
                    UserDefaults.standard.set(true, forKey: productId)
                    showPremiumQuotes()
                case .failed:
                    if let error = transaction.error {
                        let errorDescription = error.localizedDescription
                        print("Purchase Failed: \(errorDescription)")
                    }
                    SKPaymentQueue.default().finishTransaction(transaction)
                default:
                    print("purchase default state (neither successful nor failed...")
            }
        }
    }
    
    func showPremiumQuotes() {
        quotesToShow.append(contentsOf: premiumQuotes)
        navigationItem.setRightBarButtonItems(nil, animated: true)
        tableView.reloadData()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("Payments restored...")
        UserDefaults.standard.set(true, forKey: productId)
        showPremiumQuotes()
    }
    
    func isPremiumUser() -> Bool {
        return UserDefaults.standard.bool(forKey: productId)
    }
    
}
