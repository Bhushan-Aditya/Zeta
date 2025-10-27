// WelcomeView.swift
import SwiftUI

// MARK: - Starfield Components (These should be directly in this file or imported)

struct StarInfo: Identifiable {
    let id = UUID()
    let position: CGPoint
    let size: CGFloat
    let initialDelay: Double
    let animationDuration: Double
    let parallaxFactor: CGFloat
}

struct TwinklingStarView: View {
    let star: StarInfo
    let geometrySize: CGSize
    @Binding var dragOffset: CGSize
    @State private var isDimmed: Bool = Bool.random()

    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.85))
            .frame(width: star.size, height: star.size)
            .opacity(isDimmed ? 0.25 : 1.0)
            .blur(radius: star.size > 2.2 ? 0.3 : 0)
            .position(
                x: star.position.x * geometrySize.width,
                y: star.position.y * geometrySize.height
            )
            .offset(
                x: dragOffset.width / star.parallaxFactor,
                y: dragOffset.height / star.parallaxFactor
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + star.initialDelay) {
                    withAnimation(Animation.easeInOut(duration: star.animationDuration)
                        .repeatForever(autoreverses: true)) {
                        isDimmed.toggle()
                    }
                }
            }
    }
}

struct StarfieldView: View {
    let geometry: GeometryProxy
    @Binding var dragOffset: CGSize
    @State private var stars: [StarInfo] = []
    private let numberOfStars = 45

    var body: some View {
        ZStack {
            ForEach(stars) { star in
                TwinklingStarView(star: star, geometrySize: geometry.size, dragOffset: $dragOffset)
            }
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .allowsHitTesting(false)
        .onAppear {
            if stars.isEmpty {
                generateStars(screenSize: geometry.size)
            }
        }
    }

    private func generateStars(screenSize: CGSize) {
        for _ in 0..<numberOfStars {
            stars.append(StarInfo(
                position: CGPoint(x: CGFloat.random(in: 0.01...0.99),
                                  y: CGFloat.random(in: 0.01...0.99)),
                size: CGFloat.random(in: 1.0...2.5),
                initialDelay: Double.random(in: 0...3.0),
                animationDuration: Double.random(in: 1.5...4.0),
                parallaxFactor: CGFloat.random(in: 10...25)
            ))
        }
    }
}


// MARK: - Supporting Views (These should be directly in this file or imported)

struct ParallaxBackgroundElements: View {
    let geometry: GeometryProxy
    @Binding var dragOffset: CGSize
    @State private var animateTriggers: [Bool] = Array(repeating: false, count: 4)

    var body: some View {
        ZStack {
            ForEach(0..<4) { i in
                let sf = CGFloat(i % 2 == 0 ? 1.0 : 0.75)
                let x = geometry.size.width * (0.15 + CGFloat(i) * 0.22)
                let y = geometry.size.height * (i % 3 == 0 ? 0.22 : (i % 3 == 1 ? 0.52 : 0.82))
                
                let baseOrbOpacityForGradient = 0.20
                let animatedEffectAlpha = animateTriggers[i] ? 0.75 : 1.0
                
                Circle().fill(
                    RadialGradient(gradient: Gradient(colors: [Color.zetaSoftOrange.opacity(baseOrbOpacityForGradient), .clear]), center: .center, startRadius: 10, endRadius: 130 * sf)
                )
                .frame(width: 260 * sf, height: 260 * sf)
                .opacity(0.55 * animatedEffectAlpha)
                .blur(radius: 12)
                .position(x: x, y: y)
                .offset(x: dragOffset.width / (3.8 + CGFloat(i) * 0.7), y: dragOffset.height / (3.8 + CGFloat(i) * 0.7))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.6) {
                        if !animateTriggers[i] {
                             withAnimation(Animation.easeInOut(duration: Double.random(in: 3.0...5.0)).repeatForever(autoreverses: true)) {
                                animateTriggers[i].toggle()
                             }
                        }
                    }
                }
            }
            .allowsHitTesting(false)
        }
    }
}

struct MascotView: View {
    @Binding var scaleEffect: CGFloat; @Binding var opacity: CGFloat; @Binding var floatOffsetY: CGFloat
    @Binding var shadowOpacity: CGFloat; @Binding var shadowRadius: CGFloat; @Binding var showElements: Bool
    let globalBobbingOffset: CGFloat; @Binding var dragOffset: CGSize
    var body: some View {
        ZStack {
            Ellipse().fill(Color.black.opacity(showElements ? shadowOpacity : 0))
                .frame(width: 170 * scaleEffect, height: 35 * scaleEffect).offset(y: 75 * scaleEffect)
                .blur(radius: shadowRadius).animation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true), value: shadowOpacity)
            Circle().fill(RadialGradient(gradient: Gradient(colors: [Color.orange.opacity(0.45), Color.orange.opacity(0.25)]), center: .center, startRadius: 15, endRadius: 85))
                .frame(width: 150, height: 150).opacity(showElements ? 0.75 : 0)
            Image("SleepingChildMascot").resizable().aspectRatio(contentMode: .fit).frame(height: 135) // Ensure "SleepingChildMascot" is in your Assets
                .scaleEffect(scaleEffect).shadow(color: .black.opacity(0.08), radius: 7, x: 0, y: 5)
                .offset(y: floatOffsetY + globalBobbingOffset / 1.8)
        }
        .opacity(opacity).offset(x: dragOffset.width * 0.75, y: dragOffset.height * 0.75)
    }
}

struct WelcomeScreenButtons: View {
    @Binding var navigateToCharacterQuestion: Bool; @Binding var navigateToParentZone: Bool
    @Binding var createStoryButtonScale: CGFloat; @Binding var parentZoneButtonScale: CGFloat
    @Binding var buttonGlowIntensity: CGFloat; @Binding var showElements: Bool
    var body: some View {
        VStack(spacing: 18) {
            Button {
                withAnimation(.spring(response:0.3,dampingFraction:0.55)){createStoryButtonScale=0.90};DispatchQueue.main.asyncAfter(deadline:.now()+0.12){withAnimation(.spring(response:0.35,dampingFraction:0.6)){createStoryButtonScale=1.0};navigateToCharacterQuestion=true} // This now triggers the .fullScreenCover
            } label: { HStack(spacing:10){ZStack{Image(systemName:"wand.and.stars").font(.system(size:20)).symbolEffect(.pulse,options:.repeating.speed(0.65));Image(systemName:"sparkle").font(.system(size:9)).offset(x:7,y:-8).opacity(0.75).symbolEffect(.variableColor.iterative.reversing,options:.repeating.speed(0.75))};Text("Create a Story").font(.custom("Avenir-Heavy",size:19))}.padding(.horizontal,18).frame(width:270,height:56).foregroundStyle(.white).background(createStoryButtonBackground).shadow(color:Color.welcomeViewButtonPurpleDark.opacity(0.35),radius:9,x:0,y:4).shadow(color:Color.purple.opacity(0.15+buttonGlowIntensity*0.15),radius:10,x:0,y:1.5)
            }.scaleEffect(createStoryButtonScale).opacity(showElements ?1:0).animation(.interpolatingSpring(stiffness:140,damping:16).delay(0.7),value:showElements)
            Button {
                withAnimation(.spring(response:0.3,dampingFraction:0.55)){parentZoneButtonScale=0.90};DispatchQueue.main.asyncAfter(deadline:.now()+0.12){withAnimation(.spring(response:0.35,dampingFraction:0.6)){parentZoneButtonScale=1.0};navigateToParentZone=true}
            } label: { HStack(spacing:8){ZStack{Image(systemName:"lock.fill").font(.system(size:13)).offset(y:-0.5);Circle().stroke(Color.welcomeViewButtonOrangePrimary,lineWidth:1.2).frame(width:22,height:22)};Text("Parent Zone").font(.custom("Avenir-Medium",size:17))}.padding(.horizontal,18).frame(width:220,height:44).foregroundStyle(LinearGradient(colors:[Color.welcomeViewButtonOrangePrimary,Color.orange],startPoint:.leading,endPoint:.trailing)).background(Capsule().fill(LinearGradient(colors:[.white,Color.zetaSoftOrange.opacity(0.25)],startPoint:.top,endPoint:.bottom))).overlay(Capsule().stroke(LinearGradient(colors:[Color.welcomeViewButtonOrangePrimary.opacity(0.65),Color.orange.opacity(0.45)],startPoint:.leading,endPoint:.trailing),lineWidth:1.2)).shadow(color:Color.welcomeViewButtonOrangePrimary.opacity(0.20),radius:6,x:0,y:2.5)
            }.scaleEffect(parentZoneButtonScale).opacity(showElements ?1:0).animation(.interpolatingSpring(stiffness:140,damping:16).delay(0.8),value:showElements)
        }
    }
    @ViewBuilder private var createStoryButtonBackground:some View{ZStack{Capsule().fill(LinearGradient(colors:[Color.welcomeViewButtonPurpleDark,(Color.purple),(Color.blue)],startPoint:.leading,endPoint:.trailing));Capsule().fill(LinearGradient(colors:[(Color.purple).opacity(0.1+buttonGlowIntensity*0.25),.clear],startPoint:.topLeading,endPoint:.center)).blendMode(.overlay);Capsule().strokeBorder(LinearGradient(colors:[.white.opacity(0.55),.white.opacity(0.08)],startPoint:.topLeading,endPoint:.bottomTrailing),lineWidth:1.2);ForEach(0..<3){i in Image(systemName:"star.fill").font(.system(size:CGFloat.random(in:3...5))).foregroundStyle(.white.opacity(0.25+buttonGlowIntensity*0.25)).offset(x:CGFloat.random(in:-75...75),y:CGFloat.random(in:-10...10)).opacity(buttonGlowIntensity>0.15 ?1:0).animation(.easeInOut(duration:1.2).repeatForever(autoreverses:true).delay(Double(i)*0.35),value:buttonGlowIntensity)}}}
}

struct ParentZoneView: View { // This is just a placeholder for your actual Parent Zone
    var body: some View { ZStack{LinearGradient(gradient:Gradient(colors:[Color.zetaBackgroundGradientStart,Color.zetaBackgroundGradientEnd]),startPoint:.top,endPoint:.bottom).ignoresSafeArea();Text("Parent Zone Placeholder").font(.largeTitle).foregroundColor(Color.welcomeViewTextPrimary)}}}

// MARK: - Main Welcome View

struct WelcomeView: View {
    // --- State Variables ---
    @State private var navigateToCharacterQuestion = false // This now triggers the .fullScreenCover
    @State private var navigateToParentZone = false
    @State private var showElementsWithDelay = false
    @State private var titleTextOffset: CGFloat = 30
    @State private var subtitleTextOffset: CGFloat = 50
    @State private var mascotScaleEffect: CGFloat = 0.8
    @State private var mascotOpacity: CGFloat = 0
    @State private var mascotFloatOffsetY: CGFloat = 0
    @State private var mascotShadowOpacity: CGFloat = 0.5
    @State private var mascotShadowRadius: CGFloat = 10
    @State private var createStoryButtonScale: CGFloat = 1.0
    @State private var parentZoneButtonScale: CGFloat = 1.0
    @State private var buttonGlowIntensity: CGFloat = 0.0
    @State private var floatingCircleOffset: CGFloat = 0
    @State private var parallaxDragOffset: CGSize = .zero
    // StoryElements is managed by the StoryCreationCoordinatorView, so no @State for it here.

    private let gradientDragSensitivity: CGFloat = 75.0
    
    // --- Computed Properties for Interactive Gradient and Hue ---
    private func calculateInteractiveUnitPoint(baseValue:CGFloat,dragValue:CGFloat)->CGFloat{clamp(baseValue+(dragValue/gradientDragSensitivity),min:-0.5,max:1.5)}
    private var interactiveStartPoint:UnitPoint{UnitPoint(x:calculateInteractiveUnitPoint(baseValue:0.0,dragValue:parallaxDragOffset.width),y:calculateInteractiveUnitPoint(baseValue:0.0,dragValue:parallaxDragOffset.height))}
    private var interactiveEndPoint:UnitPoint{UnitPoint(x:calculateInteractiveUnitPoint(baseValue:1.0,dragValue:parallaxDragOffset.width),y:calculateInteractiveUnitPoint(baseValue:1.0,dragValue:parallaxDragOffset.height))}
    private var computedHueAngle:Angle{Angle(degrees:sin(floatingCircleOffset/30.0)*2.5)}

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // --- Background Elements ---
                    LinearGradient(gradient:Gradient(colors:[Color.zetaBackgroundGradientStart.opacity(0.9),Color.zetaBackgroundGradientEnd.opacity(1.0),(Color.purple).opacity(0.65)]),startPoint:interactiveStartPoint,endPoint:interactiveEndPoint)
                        .ignoresSafeArea().hueRotation(computedHueAngle)
                        .animation(.easeInOut(duration:6.0).repeatForever(autoreverses:true),value:floatingCircleOffset)

                    StarfieldView(geometry: geometry, dragOffset: $parallaxDragOffset)
                    ParallaxBackgroundElements(geometry: geometry, dragOffset: $parallaxDragOffset)
                    
                    // --- Main Content View ---
                    mainContentView(geometry: geometry)
                }
                .gesture(DragGesture().onChanged{value in let maxOffset:CGFloat=20;parallaxDragOffset=CGSize(width:clamp(value.translation.width/10,min:-maxOffset,max:maxOffset),height:clamp(value.translation.height/10,min:-maxOffset,max:maxOffset))}.onEnded{_ in withAnimation(.spring(response:0.45,dampingFraction:0.65)){parallaxDragOffset = .zero}})
                .onAppear(perform: performEntryAnimations)
                .navigationDestination(isPresented: $navigateToParentZone) { ParentZoneView() }
                // Removed the old .navigationDestination for CharacterQuestionView
            }
        }
        .statusBar(hidden:true)
        .fullScreenCover(isPresented: $navigateToCharacterQuestion) { // << MODIFIED HERE
            StoryCreationCoordinatorView(isPresented: $navigateToCharacterQuestion)
        }
    }
        
    @ViewBuilder private func mainContentView(geometry:GeometryProxy)->some View{
        VStack(spacing:0){
            Spacer().frame(height:geometry.safeAreaInsets.top > 20 ?geometry.safeAreaInsets.top:25)
            Text("ZETA")
                .font(.custom("Avenir-Heavy",size:32))
                .foregroundStyle(LinearGradient(colors:[Color.welcomeViewTextPrimary,Color.welcomeViewTextPrimary.opacity(0.75)],startPoint:.top,endPoint:.bottom))
                .tracking(12)
                .shadow(color:Color.welcomeViewTextPrimary.opacity(0.20),radius:2.5,x:0,y:1.5)
                .opacity(showElementsWithDelay ?1:0)
                .animation(.easeOut(duration:0.8).delay(0.25),value:showElementsWithDelay)
                .offset(y:floatingCircleOffset/3.0)
            VStack(spacing:10){
                Text("Welcome to Zeta")
                    .font(.custom("Avenir-Heavy",size:28))
                    .foregroundStyle(Color.welcomeViewTextPrimary)
                    .shadow(color:Color.welcomeViewTextPrimary.opacity(0.15),radius:1,x:0,y:1)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .opacity(showElementsWithDelay ?1:0)
                    .offset(y:showElementsWithDelay ?0:titleTextOffset)
                    .animation(.interpolatingSpring(stiffness:90,damping:13).delay(0.35),value:showElementsWithDelay)
                    .offset(y:showElementsWithDelay ? (floatingCircleOffset/3.5):titleTextOffset+(floatingCircleOffset/3.5))
                Text("Create magical bedtime stories that spark your child's imagination")
                    .font(.custom("Avenir-Medium",size:17))
                    .foregroundStyle(Color.welcomeViewTextPrimary.opacity(0.80))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal,30)
                    .opacity(showElementsWithDelay ?1:0)
                    .offset(y:showElementsWithDelay ?0:subtitleTextOffset)
                    .animation(.interpolatingSpring(stiffness:90,damping:13).delay(0.45),value:showElementsWithDelay)
                    .offset(y:showElementsWithDelay ? (floatingCircleOffset/4.0):subtitleTextOffset+(floatingCircleOffset/4.0))
            }
            .padding(.top,15)
            Spacer()
            MascotView(
                scaleEffect:$mascotScaleEffect,
                opacity:$mascotOpacity,
                floatOffsetY:$mascotFloatOffsetY,
                shadowOpacity:$mascotShadowOpacity,
                shadowRadius:$mascotShadowRadius,
                showElements:$showElementsWithDelay,
                globalBobbingOffset:floatingCircleOffset/2.5,
                dragOffset:$parallaxDragOffset
            )
            .padding(.bottom,15)
            Spacer()
            WelcomeScreenButtons(
                navigateToCharacterQuestion:$navigateToCharacterQuestion,
                navigateToParentZone:$navigateToParentZone,
                createStoryButtonScale:$createStoryButtonScale,
                parentZoneButtonScale:$parentZoneButtonScale,
                buttonGlowIntensity:$buttonGlowIntensity,
                showElements:$showElementsWithDelay
            )
            .padding(.bottom,geometry.safeAreaInsets.bottom>0 ?geometry.safeAreaInsets.bottom+5:35)
        }
    }
    
    private func performEntryAnimations(){
        withAnimation(.easeInOut(duration:7.0).repeatForever(autoreverses:true)){floatingCircleOffset = -12}
        showElementsWithDelay=true
        withAnimation(.interpolatingSpring(stiffness:70,damping:11).delay(0.6)){mascotScaleEffect=1.0;mascotOpacity=1.0}
        withAnimation(.easeInOut(duration:3.5).repeatForever(autoreverses:true).delay(0.7)){mascotFloatOffsetY = -7;mascotShadowRadius=8;mascotShadowOpacity=0.30}
        withAnimation(Animation.easeInOut(duration:2.5).repeatForever(autoreverses:true).delay(1.2)){buttonGlowIntensity=0.7}
    }
    
    private func clamp(_ val:CGFloat,min:CGFloat,max:CGFloat)->CGFloat{Swift.min(max,Swift.max(min,val))}
}

// Ensure you have color definitions like these (e.g., in ColorExtensions.swift):
// extension Color {
//    static let zetaBackgroundGradientStart = Color("zetaBgGradStart") // Example color name
//    static let zetaBackgroundGradientEnd = Color("zetaBgGradEnd")
//    static let zetaSoftOrange = Color.orange.opacity(0.5) // Example placeholder
//    static let welcomeViewButtonPurpleDark = Color.purple.darker() // Example placeholder
//    static let welcomeViewButtonOrangePrimary = Color.orange // Example placeholder
//    static let welcomeViewTextPrimary = Color.white // Example placeholder
// }

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            // Provide dummy StoryCreationCoordinatorView, CharacterQuestionView, etc., if needed for full preview context
            // and their dependent Models.swift, ColorExtensions.swift
    }
}
