//
//  NutritionixAPI.swift
//  Nutrify
//  Description: Create HTTP request calls to the Nutritionix database using Alamofire. Return food search results
//
//  Created by Alex Benasutti on 4/27/20.
//  Last Modified: 4/27/20
//  Copyright © 2020 Alex Benasutti. All rights reserved.
//

import Foundation
import Alamofire

// DataManagerError: Handles invalid requests/errors
enum DataManagerError: Error {
    case unknown
    case failedRequest
    case invalidResponse
}

// NetworkingClient: Main manager of Nutritionix HTTP requests
// execute: instant searching (used for autocomplete, NOT YET IMPLEMENTED)
// fetchFoodData: detailed searches for nutrient information of common and branded foods
class NetworkingClient {
    
    // Response type for instant searches
    typealias WebServiceResponse = ([[String: Any]]?, Error?) -> Void
    // Response type for natural searches
    typealias NutritionCompletionHandler = ([Meal]?, DataManagerError?) -> ()
    
    // Headers are required to access the database information
    let headers: HTTPHeaders = [
        "x-app-key": API.APPLICATION_KEY,
        "x-app-id": API.APPLICATION_ID,
        "Content-Type": "application/json"
    ]
    
    // execute: instant searching (used for autocomplete, NOT YET IMPLEMENTED)
    // url: URL to send a request to
    // query: food to be searched for
    // completion: Response handler for Alamofire request
    func execute(_ url: URL, query: String, completion: @escaping WebServiceResponse) {
        
        // query: food to be searched (e.g. grilled cheese)
        // detailed: show more information about the instant searched food
        let parameters = ["query": query, "detailed": true] as [String : Any]
        
        // Send Alamofire request to acquire JSON data corresponding to the search
        AF.request(url, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            // search successful
            case let .success(value):
                debugPrint(value)
                if let jsonArray = value as? [[String: Any]] {
                    completion(jsonArray, nil)
                }
                else if let jsonDict = value as? [String: Any] {
                    completion([jsonDict], nil)
                }
            // search failure
            case let .failure(error):
                debugPrint(error)
                completion(nil, error)
            }
        }
        
    }
    
    // fetchFoodData: detailed searches for nutrient information of common and branded foods
    // foodName: food to be searched for
    // completion: Response handler for Alamofire request
    func fetchFoodData(foodName: String, completion: @escaping NutritionCompletionHandler) {
        
        // set parameters for AF request
        let parameters = ["query": foodName]
        
        // Send AF to make a natural search on Nutritionix
        AF.request("https://trackapi.nutritionix.com/v2/natural/nutrients/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            // Search successful
            case let .success(value):
                // if value is nested array
                if let jsonArray = value as? [[String: Any]] {
                    completion(nil, .failedRequest)
                }
                // if value is single array
                else if let jsonDict = value as? [String: Any] {
                    // Parse JSON for necessary data
                    let result_dict = response.value as! NSDictionary
                    let result_array = result_dict["foods"] as! NSArray
                    // Send resultant array to create a meal
                    let meals = self.mapToMeal(jsonDictionaries: result_array)
                    debugPrint(meals)
                    // Send meals back to caller
                    completion(meals, nil)
                }
            // Search failure
            case let .failure(error):
                debugPrint(error)
                // Send error back to caller
                completion(nil, .failedRequest)
            }
        }
    }
    
    // mapToMeal: Parse JSON for necessary information to create a Meal
    // jsonDictionaries: Nutritionix JSON food data to be parsed
    // returns - mealArray: array of the food name, calories, and macronutrient data
    func mapToMeal(jsonDictionaries: NSArray) -> [Meal] {
        
        // Create a mutable array to be populated
        let mutableArray = NSMutableArray()
        
        // Search through each meal object in the json
        for object in jsonDictionaries {
            
            debugPrint(object)
            
            // If good to parse
            if let dict = object as? NSDictionary {
                // set name
                debugPrint(dict["food_name"] as Any)
                guard let name = dict["food_name"] as? String else { return [] }
                debugPrint(name)
                // set calories
                debugPrint(dict["nf_calories"] as Any)
                guard let calories = dict["nf_calories"] as? NSNumber else { return [] }
                debugPrint(calories)
                // set fat
                guard let fat = dict["nf_total_fat"] as? NSNumber else { return [] }
                debugPrint(fat)
                // set carbs
                guard let carbs = dict["nf_total_carbohydrate"] as? NSNumber else { return [] }
                debugPrint(carbs)
                // set protein
                guard let protein = dict["nf_protein"] as? NSNumber else { return [] }
                debugPrint(protein)
                
                // Populate array
                mutableArray.add(Meal(
                    name: name,
                    calories: calories,
                    fat: fat,
                    carbs: carbs,
                    protein: protein
                ))
            }
        }
        
        // Set array as Meal type
        guard let mealArray = mutableArray as? [Meal] else { return [] }
        
        debugPrint(mealArray)
        
        // Return Meal
        return mealArray
    }
}
