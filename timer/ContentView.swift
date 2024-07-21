//
//  ContentView.swift
//  timer
//
//  Created by Ehsan Rahimi on 7/19/24.
//

import SwiftUI

let defaultTime: CGFloat = 180

struct ContentView: View {
    let strokeStyle = StrokeStyle(lineWidth: 15, lineCap: .round)
    @State var setTimer: CGFloat = defaultTime
    @State var timeLeft: CGFloat = defaultTime
    @State var timerStarted = false
    @State var buttonScale: CGFloat = 1.0
    @State var resetButtonScale: CGFloat = 1.0
    let colors: [Color] = [Color(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)), Color(#colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)), Color(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)), Color(#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1))]
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var timerColor: Color {
        let ratio = timeLeft / setTimer
        switch ratio {
        case 0.65...:
            return colors[0]
        case 0.30...:
            return colors[1]
        case 0.15...:
            return colors[2]
        default:
            return colors[3]
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(1)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Picker("Time", selection: $setTimer) {
                    ForEach(1 ..< 500) { time in // Adjust range as needed
                        Text("\(time) seconds").tag(CGFloat(time))
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity, maxHeight: 300)
                .onChange(of: setTimer, initial: true) { _, newValue in
                    timeLeft = newValue
                }
                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), style: strokeStyle)

                    Circle()
                        .trim(from: 0.0, to: 1.0 - (setTimer - timeLeft) / setTimer)
                        .stroke(timerColor, style: strokeStyle)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: timeLeft)
                        .shadow(color: timerColor.opacity(0.7), radius: 10, x: 0, y: 4)

                    VStack {
                        Text("\(Int(timeLeft))")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Seconds Left")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .opacity(0.8)
                    }
                }
                .frame(width: 300, height: 300)

                Spacer()

                HStack(spacing: 40.0) {
                    Image(systemName: timerStarted ? "stop.circle.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.white)
                        .scaleEffect(buttonScale)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                        .onTapGesture {
                            timerStarted.toggle()
                            withAnimation {
                                buttonScale = 1.2
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    buttonScale = 1.0
                                }
                            }
                        }

                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.white)
                        .scaleEffect(resetButtonScale)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                        .onTapGesture {
                            timerStarted = false
                            timeLeft = setTimer
                            withAnimation {
                                resetButtonScale = 1.2
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    resetButtonScale = 1.0
                                }
                            }
                        }
                }
                .padding(.bottom, 40)
            }
        }
        .onReceive(timer, perform: { _ in
            guard timerStarted else { return }
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                timeLeft = setTimer
                timerStarted = false
            }
        })
    }
}

#Preview {
    ContentView()
}
