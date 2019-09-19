//
//  ViewController.swift
//  APPS Nano Challenge 2
//
//  Created by Wimba Juventio Chandra on 18/09/19.
//  Copyright © 2019 Wimba Juventio Chandra. All rights reserved.
//

import UIKit
import HealthKit
import LocalAuthentication

enum AuthenticationState {
    case loggedin, loggedout
}

var context = LAContext()

class ViewController: UIViewController
{
   var state = AuthenticationState.loggedout
    var jumlahcupsskrg = 0
    @IBOutlet weak var jumlahCups: UILabel!
    @IBOutlet weak var viewbunder: UIView!
    var healthStore: HKHealthStore?
    
    var typesToShare : Set<HKSampleType>
    {
        let waterType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)!
        return [waterType]
    }

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        viewbunder.layer.cornerRadius = 10
        
        healthStore = HKHealthStore()
      
        
         if HKHealthStore.isHealthDataAvailable() {
            self.healthStore = HKHealthStore()
            let allTypes = Set([HKObjectType.quantityType(forIdentifier: .dietaryWater)!])
            healthStore!.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
                if !success {
        // Do any additional setup after loading the view.
                    }
            }
        }
          getBIMIHealthData()
        
    }
    
    
    

    
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        //  Request access to write dietaryWater data to HealthStore
        self.healthStore?.requestAuthorization(toShare: typesToShare, read: nil, completion: { (success, error) in
            if (!success)
            {
                //  request was not successful, handle user denial
                return
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    
    }
    

    @IBAction func diTekan(_ sender: UIButton) {
        
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            
            let reason = "To verify it's you who's drinking"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in
                if success {
                    
                    // Move to the main thread because a state update triggers UI changes.
                    DispatchQueue.main.async { [unowned self] in
                        self.state = .loggedin
                        self.jumlahcupsskrg = self.jumlahcupsskrg + 1
                        self.jumlahCups.text = String(format: " %d / 8 Cups", self.jumlahcupsskrg)
                        self.addWaterAmountToHealthKit(miliLiters: 200)
                        self.state = .loggedout
                    }
                }
                    
                    //ELSE
                else {
                    
                    print(error?.localizedDescription ?? "Failed to authenticate")
                    // Fall back to a asking for username and password.`
                    // ...`
                }
                
            }
            
            
            
            
            
        }
        
        if state == .loggedin
        {
            state = .loggedout
        }
            
            
            
        else {
            
            // Get a fresh context for each login. If you use the same context on multiple attempts`
            //  (by commenting out the next line), then a previously successful authentication`
            //  causes the next policy evaluation to succeed without testing biometry again.`
            //  That's usually not what you want.
            context = LAContext()
            context.localizedCancelTitle = "Cancel"
            
        }
        
        
        print("test button")
        
    }


    func addWaterAmountToHealthKit(miliLiters : Double) {
        // 1
        let quantityType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)
        
        // string value represents US fluid
        // 2
        let quantitytUnit = HKUnit(from: "ml")
        let quantityAmount = HKQuantity(unit: quantitytUnit,doubleValue: miliLiters)
        
        
        let now = Date()
        // 3
        let sample = HKQuantitySample(type: quantityType!, quantity: quantityAmount, start: now, end: now)
        let correlationType = HKObjectType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.food)
        // 4
        let waterCorrelationForWaterAmount = HKCorrelation(type: correlationType!, start: now, end: now, objects: [sample])
        
        print("waterCorrelationForWaterAmount:\(waterCorrelationForWaterAmount)")
        
        
        
        // Send water intake data to healthStore…aka ‘Health’ app
        // 5
        self.healthStore?.save(waterCorrelationForWaterAmount, withCompletion: { (success, error) in
            if (error != nil) {
                NSLog("error occurred saving water data")
            }
            else
            {
                print("saved successfully")
            }
        })
    }
    
    func getBIMIHealthData(){
        //sample Type
        let sampleType = HKSampleType.quantityType(forIdentifier: .dietaryWater)!
        let heartRateUnit:HKUnit = HKUnit(from: "ml")
        //predicate boleh nil
        
        
        //limit
        let limit = 10
        let sortDes = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        //sortDesciptor boleh nil
        
        //query
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: limit, sortDescriptors: nil){ (sampleQuery, results, error)in
            
            guard let samples = results as?[HKQuantitySample] else { return }
            DispatchQueue.main.sync {
                
                for sample in samples {
                    let bmi = sample.quantity.doubleValue(for: heartRateUnit)
                    print("\(bmi)")
                }
            }
        }
        self.healthStore?.execute(sampleQuery)
    }

}


