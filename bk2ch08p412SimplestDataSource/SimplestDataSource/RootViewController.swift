

import UIKit
func delay(_ delay:Double, closure:@escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

extension CGRect {
    init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
        self.init(x:x, y:y, width:w, height:h)
    }
}
extension CGSize {
    init(_ width:CGFloat, _ height:CGFloat) {
        self.init(width:width, height:height)
    }
}
extension CGPoint {
    init(_ x:CGFloat, _ y:CGFloat) {
        self.init(x:x, y:y)
    }
}
extension CGVector {
    init (_ dx:CGFloat, _ dy:CGFloat) {
        self.init(dx:dx, dy:dy)
    }
}



class RootViewController: UITableViewController {
    
    let cellID = "Cell"
    
    var pep : [String]! = ["Manny", "Moe", "Jack"] // pretend model might not be ready
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // so this is still legal; you can give a tvc a refresh control in iOS 10
        // however, what's new is that this is _actually_ the table's refresh control
//        self.refreshControl = UIRefreshControl()
//        self.refreshControl!.addTarget(self, action: #selector(doRefresh), for: .valueChanged)
//        print(self.tableView!.refreshControl)
        
        // so you can write it like this instead:
        
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl!.addTarget(self, action: #selector(doRefresh), for: .valueChanged)
        
        // moreover, when you do, your code just keeps on working;
        // this is also still the table view controller's refresh control!
        
        // showing that the refresh control's background color covers the table's background
        let v = UIView()
        v.backgroundColor = .yellow
        self.tableView.backgroundView = v
        self.tableView.refreshControl?.backgroundColor = .green
        
        // self.edgesForExtendedLayout = []
        self.edgesForExtendedLayout = .all
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .always
        } else {
            self.automaticallyAdjustsScrollViewInsets = true
        }
        
        self.tableView.tintColor = .red
        // proving that the refresh control is unaffected
        // self.tableView.refreshControl?.tintColor = .yellow
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.pep == nil {
            return 0
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pep.count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath) 

        cell.textLabel!.text = pep[indexPath.row]
        return cell
    }

    @IBAction func doRefresh(_ sender: Any) {
        print("refreshing...")
        delay(3) {
            (sender as! UIRefreshControl).endRefreshing()
            print("done")
        }
    }

    @IBAction func doRefreshManually(_ sender: Any) {
        // all this talk of `self.refreshControl` works, even though we didn't assign this way
        // NB I failed to notice that my old code wasn't working because of the content inset
        // NB also iOS 10 vs iOS 11, in iOS 11 it's the adjusted content inset
        
        // another weird thing; it fails the second time, because after the first time...
        // the refresh control seems to take on a zero height!
        // okay, made it work by forcing the refresh control back to its real size
        
        if #available(iOS 11.0, *) {
            self.refreshControl!.sizeToFit()
            let top = self.tableView.adjustedContentInset.top
            let y = self.refreshControl!.frame.maxY + top
            self.tableView.setContentOffset(CGPoint(0, -y), animated:true)
        } else {
            self.refreshControl!.sizeToFit()
            let top = self.tableView.contentInset.top
            let y = self.refreshControl!.frame.maxY + top
            self.tableView.setContentOffset(CGPoint(0, -y), animated:true)
        }

        self.refreshControl!.beginRefreshing()
        self.doRefresh(self.refreshControl!)
    }
}
