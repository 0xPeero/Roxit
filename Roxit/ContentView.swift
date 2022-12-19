//
//  ContentView.swift
//  Roxit
//
//  Created by Pierre Abdelsayed on 12/1/22.
//

import SwiftUI
import UserNotifications

// MARK: Location Class
class Locations: ObservableObject{
    @Published var gameGrid = [[Int]](repeating: [Int] (repeating: 0, count: 10), count: 10)
    var doorLocation = [[Int]]()
    var robotLocation = [[Int]]()
    var distanceBetweenDoorNBot = [[[Int]]](repeating: [[Int]](repeating: [], count: RoxitApp().amountofBots), count: RoxitApp().amountofBots)
    var closestdoorLocation = [[Int]]()

    func generateExit(Amount: Int){
        for _ in 1 ... Amount{
            var X = Int.random(in: 0...9)
            var Y = Int.random(in: 0...9)
            for i in 0 ..< robotLocation.count{
                if(robotLocation[i] == [X,Y]){
                    X = Int.random(in: 0...9)
                    Y = Int.random(in: 0...9)
                }
            }
            gameGrid[X][Y] = 2
            doorLocation.append([X,Y])
        }
        doorLocation = doorLocation.sorted(by:{$0[0] < $1[0]})
        print("Exit \(doorLocation)")
    }
    
    func generateBots(Amount: Int){
        for _ in 1 ... Amount {
            let X = Int.random(in: 0...9)
            let Y = Int.random(in: 0...9)
            gameGrid[X][Y] = 1
            robotLocation.append([X,Y])
        }
        robotLocation = robotLocation.sorted(by:{$0[0] < $1[0] })
        print("robot \(robotLocation)")
    }
    
    func calculateExitDistance(Amount: Int){
        for X in 0 ..< Amount{
            for Y in 0 ..< Amount{
                distanceBetweenDoorNBot[X][Y] = ([doorLocation[Y][0] - robotLocation[X][0],doorLocation[Y][1] - robotLocation[X][1]])
            }
            distanceBetweenDoorNBot[X] = distanceBetweenDoorNBot[X].sorted(by: {abs($0[1]) < abs($1[1])})
            distanceBetweenDoorNBot[X] = distanceBetweenDoorNBot[X].sorted(by: {abs($0[0]) < abs($1[0])})
            closestdoorLocation.append(distanceBetweenDoorNBot[X][0])
        }
        print("Distance \(distanceBetweenDoorNBot)")
        print("Exit Distance \(closestdoorLocation)")
    }
    
    func simulateGame(Amount: Int){
        for i in 0 ..< Amount{
            if (closestdoorLocation[i][1] > 0){
                gameGrid[robotLocation[i][0]][robotLocation[i][1]] = 0
                if(gameGrid[robotLocation[i][0]][robotLocation[i][1]+1] == 2){
                    gameGrid[robotLocation[i][0]][robotLocation[i][1]+1] = 2
                }else if(gameGrid[robotLocation[i][0]][robotLocation[i][1]+1] == 1){
                    break
                }else{
                    gameGrid[robotLocation[i][0]][robotLocation[i][1]+1] = 1
                }
                robotLocation[i] = [robotLocation[i][0],robotLocation[i][1]+1]
                closestdoorLocation[i] = [closestdoorLocation[i][0],closestdoorLocation[i][1]-1]
            }else if(closestdoorLocation[i][1] < 0){
                gameGrid[robotLocation[i][0]][robotLocation[i][1]] = 0
                if(gameGrid[robotLocation[i][0]][robotLocation[i][1]-1] == 2){
                    gameGrid[robotLocation[i][0]][robotLocation[i][1]-1] = 2
                }else if(gameGrid[robotLocation[i][0]][robotLocation[i][1]-1] == 1){
                    break
                }else{
                    gameGrid[robotLocation[i][0]][robotLocation[i][1]-1] = 1
                }
                robotLocation[i] = [robotLocation[i][0],robotLocation[i][1]-1]
                closestdoorLocation[i] = [closestdoorLocation[i][0],closestdoorLocation[i][1]+1]
            }else if (closestdoorLocation[i][0] > 0){
                gameGrid[robotLocation[i][0]][robotLocation[i][1]] = 0
                if (gameGrid[robotLocation[i][0]+1][robotLocation[i][1]] == 2){
                    gameGrid[robotLocation[i][0]+1][robotLocation[i][1]] = 2
                }else if(gameGrid[robotLocation[i][0]+1][robotLocation[i][1]] == 1){
                    break
                }else{
                    gameGrid[robotLocation[i][0]+1][robotLocation[i][1]] = 1
                }
                robotLocation[i] = [robotLocation[i][0]+1,robotLocation[i][1]]
                closestdoorLocation[i] = [closestdoorLocation[i][0]-1,closestdoorLocation[i][1]]
            }else if(closestdoorLocation[i][0] < 0){
                gameGrid[robotLocation[i][0]][robotLocation[i][1]] = 0
                if (gameGrid[robotLocation[i][0]-1][robotLocation[i][1]] == 2){
                    gameGrid[robotLocation[i][0]-1][robotLocation[i][1]] = 2
                }else if(gameGrid[robotLocation[i][0]-1][robotLocation[i][1]] == 1){
                    break
                }else{
                    gameGrid[robotLocation[i][0]-1][robotLocation[i][1]] = 1
                }
                robotLocation[i] = [robotLocation[i][0]-1,robotLocation[i][1]]
                closestdoorLocation[i] = [closestdoorLocation[i][0]+1,closestdoorLocation[i][1]]
            }
        }
    }
    
    
    init(Amount: Int){
        print("Runtime value init")
        generateBots(Amount: Amount)
        generateExit(Amount: Amount)
        calculateExitDistance(Amount: Amount)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: Grid Stack View
struct GridStack<Content: View>: View {
    let rows: Int
    let columns: Int
    let content: (Int, Int) -> Content

    var body: some View {
        VStack {
            ForEach(0 ..< rows, id: \.self) { row in
                HStack {
                    ForEach(0 ..< columns, id: \.self) { column in
                        content(row, column)
                            .font(.title)
                            .transition(.scale)
                    }
                }
            }
        }
    }

    init(rows: Int, columns: Int, @ViewBuilder content: @escaping (Int, Int) -> Content) {
        self.rows = rows
        self.columns = columns
        self.content = content
    }
}

// MARK: UI Page
struct ContentView: View {
    @State var showOptions = false
    @State var numofbots = RoxitApp().amountofBots
    @State var showingAlert = false
    @State var RobotText = ""
    @State var numberofRobotExited = 0
    @State var RobotTextPrinted = [Int](repeating: 0, count: RoxitApp().amountofBots)
    @ObservedObject var loc = Locations(Amount: RoxitApp().amountofBots)
    var body: some View {
            GridStack(rows: 10, columns: 10) { row, col in
                if (self.loc.gameGrid[row][col] == 0){
                    Text("⬜️")
                }else if(self.loc.gameGrid[row][col] == 1){
                    Text("🤖")
                }else{
                    Text("🟥")
                }
            }.onChange(of: loc.robotLocation, perform: { _ in
                DispatchQueue.main.async {
                    for i in 0 ..< RoxitApp().amountofBots{
                        if (loc.doorLocation.contains(loc.robotLocation[i]) && RobotTextPrinted[i] == 0){
                            withAnimation(){
                                RobotText.append("Robot \(i+1) has Exited at \(loc.robotLocation[i])\n")
                            }
                            RobotTextPrinted[i] = 1
                            numberofRobotExited += 1
                        }
                    }
                }
            })
            
            
            HStack{
                Spacer()
                Button{
                    self.showOptions.toggle()
                }label: {
                    Label("Settings", systemImage: "gearshape.fill")
                }.popover(isPresented: $showOptions) {
                    VStack{
                        Text("Settings")
                            .font(.largeTitle)
                        Stepper("Amount of Bots & Exit", value: $numofbots, in: 1...5)
                        Text("\(numofbots) selected")
                            .padding(.bottom,20)
                        Button{
                            RoxitApp().amountofBots = numofbots
                            self.showingAlert.toggle()
                        }label: {
                            Text("Apply")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }.alert("Settings Applied... Please Reload",isPresented: $showingAlert) {
                            Button("OK", role: .cancel) {
                                restartApplication(notText: "Settings Applied")
                                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in exit(0) }
                            }
                        }
                    }.padding(10)
                }
                Spacer()
                Button{
                    withAnimation(){
                        loc.simulateGame(Amount: RoxitApp().amountofBots)
                    }
                }label: {
                    Label("Step", systemImage: "forward.frame.fill")
                }
                Spacer()
            }.padding(.vertical,10)
        VStack{
            Text(RobotText)
                .transition(.slide)
            if (numberofRobotExited == RoxitApp().amountofBots){
                HStack{
                    Spacer()
                    Button{
                        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in exit(0) }
                    }label: {
                        Label("Exit", systemImage: "arrow.down.right.and.arrow.up.left")
                    }
                    Spacer()
                    Button{
                        restartApplication(notText: "Restarted Application")
                        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in exit(0) }
                    }label: {
                        Label("Restart", systemImage: "clock.arrow.circlepath")
                    }
                    Spacer()
                }
            }
        }.frame(height: 200)
    }
}


// MARK: Notification Sender
func restartApplication(notText: String){
    var localUserInfo: [AnyHashable : Any] = [:]
    localUserInfo["pushType"] = "restart"
    
    let content = UNMutableNotificationContent()
    content.title = notText
    content.body = "Tap to Reopen the Application"
    content.sound = UNNotificationSound.default
    content.userInfo = localUserInfo
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)

    let identifier = "com.pipo.Roxit"
    let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: trigger)
    let center = UNUserNotificationCenter.current()
    
    center.add(request)
}
