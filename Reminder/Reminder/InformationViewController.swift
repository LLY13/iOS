//
//  InformationViewController.swift
//  Reminder
//
//  Created by Guobin Li on 23/10/17.
//  Updated by Longyi Li 27/10/17
//  Copyright © 2017 Lee. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation

class InformationViewController: UIViewController
{
    public var reminderEvent : NSManagedObject?
    var isTimeChecked : Bool = false
    var isLocationChecked : Bool = false
    var locationManager: CLLocationManager?
    var dateCur : Date?
    
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var locationTextField: UISearchBar!

    
    @IBOutlet weak var locationMap: MKMapView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        

   
        
        
        // initialize the view
        if reminderEvent != nil
        {
            // user has set up a time
            if reminderEvent?.value(forKeyPath: "time") != nil
            {
                isTimeChecked = true
                timeButton.setBackgroundImage(UIImage(named: ImageNames.Check.rawValue), for: .normal)
                timePicker.date = reminderEvent?.value(forKeyPath: "time") as! Date
            }
            // user hasn't set up a time
            else
            {
                isTimeChecked = false
                timeButton.setBackgroundImage(UIImage(named: ImageNames.Uncheck.rawValue), for: .normal)
            }
            
            // user has set up a location
            if reminderEvent?.value(forKeyPath: "location") != nil
            {
                isLocationChecked = true
                locationButton.setBackgroundImage(UIImage(named: ImageNames.Check.rawValue), for: .normal)
                locationTextField.text = reminderEvent?.value(forKeyPath: "location") as? String
                // show location in map
 
                searchBarSearchButtonClicked(locationTextField)
                
            }
            // user hasn't set up a location
            else
            {
                isLocationChecked = false
                locationButton.setBackgroundImage(UIImage(named: ImageNames.Uncheck.rawValue), for: .normal)
                //locationTextField.text = "11";
                
                //get user current location
                locationManager = CLLocationManager()
                locationManager?.requestWhenInUseAuthorization()
                locationManager?.startUpdatingLocation()
                locationManager?.desiredAccuracy = kCLLocationAccuracyBest
                
                let locValue:CLLocationCoordinate2D = locationManager!.location!.coordinate
                
                showMap(latitude: locValue.latitude, longtitude: locValue.longitude)
                
                
                //let viewRegion = MKCoordinateRegionMakeWithDistance(locationMap.userLocation.coordinate,15000,15000)
                //locationMap.setRegion(viewRegion, animated: true)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func timeButtonClickAction(_ sender: Any)
    {
        // reverse the status
        isTimeChecked = (!isTimeChecked)
        if isTimeChecked
        {
            timeButton.setBackgroundImage(UIImage(named: ImageNames.Check.rawValue), for: .normal)
        }
        else
        {
            timeButton.setBackgroundImage(UIImage(named: ImageNames.Uncheck.rawValue), for: .normal)
        }
    }

    @IBAction func locationButtonClickAction(_ sender: Any)
    {
        // reverse the status
        isLocationChecked = (!isLocationChecked)
        if isLocationChecked
        {
            locationButton.setBackgroundImage(UIImage(named: ImageNames.Check.rawValue), for: .normal)
        }
        else
        {
            locationButton.setBackgroundImage(UIImage(named: ImageNames.Uncheck.rawValue), for: .normal)
        }
        
    }
    
    
    @IBAction func DoneAction(_ sender: Any)
    {
        // save changes
        saveChanges()
        // redirect to main view
        self.view.removeFromSuperview()
    }
    
    //time changed
    @IBAction func dateChanged(_ sender: Any) {
        dateCur = timePicker.date
    }

    

    //search action
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        //hide searchbar
        searchBar.resignFirstResponder()
        //dismiss(animated: true, completion: nil)
        
        //create searchbar
        let searchRequest = MKLocalSearchRequest()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        
        activeSearch.start{ (response, error) in
            
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
  
            let annotations = self.locationMap.annotations
            self.locationMap.removeAnnotations(annotations)
                
            //getting data
            let latitude = response?.boundingRegion.center.latitude
            let longtitude = response?.boundingRegion.center.longitude
                
            self.showMap(latitude: latitude!, longtitude: longtitude!)
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    /**
     * @brief Show a location in map
     */
    private func showMap(latitude:CLLocationDegrees, longtitude:CLLocationDegrees)
    {
        //create annottataion
        let annotation = MKPointAnnotation()
        //annotation.title = searchBar.text
        annotation.coordinate = CLLocationCoordinate2DMake(latitude, longtitude)
        self.locationMap.addAnnotation(annotation)
        
        //zooming in an annotation
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longtitude)
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(coordinate, span)
        self.locationMap.setRegion(region, animated: true)
        
    }
    
    
    //function to store date
    private func saveDate(){
        
    }
    
    /**
     * @brief Save all the changes back to reminderEvent
     */
    private func saveChanges()
    {
        if reminderEvent != nil
        {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
        
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Event")
        
            fetchRequest.predicate = NSPredicate(format: "timeAdded == %@", reminderEvent?.value(forKeyPath: "timeAdded") as! CVarArg)
        
            do
            {
                // get the selected event stored in database
                let fetchResult = try managedContext.fetch(fetchRequest)
                if fetchResult.count != 0
                {
                    let managedObject = fetchResult[0]
                    if isTimeChecked
                    {
                        managedObject.setValue(dateCur, forKey: "time")
                    }
                    else
                    {
                        managedObject.setValue(nil, forKey: "time")
                    }
                    if isLocationChecked
                    {
                        if(locationTextField.text == ""){
                            managedObject.setValue(nil, forKey: "location")
                        }else{
                            managedObject.setValue(locationTextField.text, forKey: "location")
                        }
                        
                    }
                    else
                    {
                        managedObject.setValue(nil, forKey: "location")
                    }
                    // save the change
                    try managedContext.save()
                    //print(managedObject.value(forKey: "location")!)
                }
            }
            catch let error as NSError
            {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
        
    }
}
