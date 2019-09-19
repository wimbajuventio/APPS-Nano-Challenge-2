//
//  ViewController.swift
//  APPS Nano Challenge 2
//
//  Created by Wimba Juventio Chandra on 18/09/19.
//  Copyright © 2019 Wimba Juventio Chandra. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController
{
    
    var healthStore: HKHealthStore?
    var typesToShare : Set<HKSampleType>
    {
        let waterType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)!
        return [waterType]
    }

    
    override func viewDidLoad()
        
    {
        
        super.viewDidLoad()
        addWaterAmountToHealthKit(miliLiters: 10.0)

        
         if HKHealthStore.isHealthDataAvailable() {
            let healthStore = HKHealthStore()
            let allTypes = Set([HKObjectType.quantityType(forIdentifier: .dietaryWater)!])
            healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
                if !success {
        // Do any additional setup after loading the view.
                    
    }
        
            }
            
        }
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
    
    @IBAction func diTekan(_ sender: Any) {
        print("test button")
        addWaterAmountToHealthKit(miliLiters: 0.1)
    }
    
    func addWaterAmountToHealthKit(miliLiters : Double) {
        // 1
        let quantityType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)
        
        // string value represents US fluid
        // 2
        let quantitytUnit = HKUnit(from: "fl_oz_us")
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

}


