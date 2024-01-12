//
//  ContentView.swift
//  RectangularBackgroundDemo
//
//  Created by Brian Masse on 1/12/24.
//

import SwiftUI

//MARK: ContentView
struct ContentView: View {
    @ViewBuilder
    private func makeRectangularBackgroundContent(label: String) -> some View {
        HStack {
            Spacer()
            Image(systemName: "globe.americas")
            
            Text(label)
            
            Image(systemName: "globe.europe.africa")
            Spacer()
        }
    }
    
    @ViewBuilder
    private func makeRectangularBackgroundDemonstration<C: View>( title: String, contentBuilder: () -> C ) -> some View {
        VStack {
            
            contentBuilder()
                .padding(.bottom, 5)
            
            Text(title)
                .padding(.leading)
        }
        .padding(.bottom, 7)
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text("Rectangular Background")
                .padding(.bottom)
                .font(.largeTitle)
                .bold(true)
            
            makeRectangularBackgroundDemonstration(title: "default") {
                makeRectangularBackgroundContent(label: "Hello world!")
                    .rectangularBackground()
            }
            
            makeRectangularBackgroundDemonstration(title: "custom shape") {
                makeRectangularBackgroundContent(label: "Howdy world!")
                    .rectangularBackground(7, style: .secondary,
                                           cornerRadius: 40,
                                           corners: [.topRight, .bottomLeft])
            }
            
            makeRectangularBackgroundDemonstration(title: "custom style") {
                makeRectangularBackgroundContent(label: "hola world!")
                    .rectangularBackground(20,
                                           style: .accent,
                                           shadow: true)
            }
            
            makeRectangularBackgroundDemonstration(title: "custom stroke") {
                makeRectangularBackgroundContent(label: "bonjour world!")
                    .rectangularBackground(style: .transparent,
                                           stroke: true,
                                           strokeWidth: 5,
                                           cornerRadius: 20,
                                           corners: [.topRight, .topLeft],
                                           shadow: true)
            }
            
            Spacer()
        }
        .padding()
    }
}

//MARK: UniversalStyle
public enum UniversalStyle: String, Identifiable {
    case accent
    case primary
    case secondary
    case transparent
    
    public var id: String {
        self.rawValue
    }
}

private struct UniversalStyledBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    let style: UniversalStyle
    let color: Color?
    let foregrond: Bool
    
    func body(content: Content) -> some View {
        if !foregrond {
            content
                .if( style == .transparent ) { view in view.background( .ultraThinMaterial ) }
                .if( style != .transparent ) { view in view.background( color ?? Colors.getColor(from: style, in: colorScheme) ) }
        } else {
            content
                .if( style == .transparent ) { view in view.foregroundStyle( .ultraThinMaterial ) }
                .if( style != .transparent ) { view in view.foregroundStyle( color ?? Colors.getColor(from: style, in: colorScheme) ) }
        }
    }
}

extension View {
    func universalStyledBackgrond( _ style: UniversalStyle, color: Color? = nil, onForeground: Bool = false ) -> some View {
        modifier( UniversalStyledBackground(style: style, color: color, foregrond: onForeground) )
    }
}


//MARK: RectangularBackground
//private struct RectangularBackground: ViewModifier {
//    
//    @Environment(\.colorScheme) var colorScheme
//    
//    let style: UniversalStyle
//    
//    let padding: CGFloat?
//    var corners: UIRectCorner
//    
////    private func getCornerRadius() ->
//    
//    func body(content: Content) -> some View {
//        content
//            .if(padding == nil) { view in view.padding() }
//            .if(padding != nil) { view in view.padding(padding!) }
//            .universalStyledBackgrond(style)
//            .cornerRadius(cornerRadius, corners: corners)
//    }
//}

private struct RectangularBackground: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    let style: UniversalStyle
    let color: Color?
    
    let padding: CGFloat?
    let cornerRadius: CGFloat
    var corners: UIRectCorner
    let stroke: Bool
    let strokeWidth: CGFloat
    let shadow: Bool
    
//    private func getCornerRadius() ->
    
    func body(content: Content) -> some View {
        content
            .if(padding == nil) { view in view.padding() }
            .if(padding != nil) { view in view.padding(padding!) }
            .universalStyledBackgrond(style, color: color)
            .if(stroke) { view in
                view
                    .overlay(
                        RoundedCorner(radius: cornerRadius, corners: corners)
                            .stroke(colorScheme == .dark ? .white : .black, lineWidth: strokeWidth)
                    )
            }
            .cornerRadius(cornerRadius, corners: corners)
            .if(shadow) { view in
                view
                    .shadow(color: .black.opacity(0.2),
                            radius: 10,
                            y: 5)
            }
    }
}

@available(iOS 16.0, *)
public extension View {
    func rectangularBackground(_ padding: CGFloat? = nil,
                               style: UniversalStyle = .primary,
                               color: Color? = nil,
                               stroke: Bool = false,
                               strokeWidth: CGFloat = 1,
                               cornerRadius: CGFloat = 40,
                               corners: UIRectCorner = .allCorners,
                               shadow: Bool = false) -> some View {
        
        modifier(RectangularBackground(style: style,
                                       color: color,
                                       padding: padding,
                                       cornerRadius: cornerRadius,
                                       corners: corners,
                                       stroke: stroke,
                                       strokeWidth: strokeWidth,
                                       shadow: shadow))
    }
}


//MARK: RoundedCorners
@available(iOS 15.0, *)
private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

@available(iOS 15.0, *)
public extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

//MARK: ConditionalModifier
extension View {
    @ViewBuilder
    func `if`<Content: View>( _ condition: Bool, contentBuilder: (Self) -> Content ) -> some View {
        if condition {
            contentBuilder(self)
        } else { self }
    }
}


//MARK: Colors
public class Colors {
    public static func getAccent(from colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .light: return Colors.lightAccent
        case .dark: return Colors.darkAccent
        @unknown default:
            return Colors.lightAccent
        }
    }

    public static func getBase(from colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .light: return Colors.baseLight
        case .dark: return Colors.baseDark
        @unknown default:
            return Colors.baseDark
        }
    }
    
    public static func getSecondaryBase(from colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .light: return Colors.secondaryLight
        case .dark: return Colors.secondaryDark
        @unknown default:
            return Colors.secondaryDark
        }
    }
    
    public static func getColor(from style: UniversalStyle, in colorScheme: ColorScheme) -> Color {
        switch style {
        case .primary: return getBase(from: colorScheme)
        case .secondary: return getSecondaryBase(from: colorScheme)
        case .accent: return getAccent(from: colorScheme)
        default: return Colors.lightAccent
        }
    }
    
    public static var baseLight = makeColor( 245, 234, 208 )
    public static var baseDark = makeColor( 0,0,0 )
    
    public static var secondaryLight = makeColor(220, 207, 188)
    public static var secondaryDark = Color(red: 0.1, green: 0.1, blue: 0.1).opacity(0.9)
    
    public static var lightAccent = makeColor( 0, 87, 66)
    public static var darkAccent = makeColor( 0, 87, 66)
    
    ///the makeColor function takes a red, green, and blue argument and returns a SwiftUI Color. All values are from 0 to 255. This function is entirely for convenience and to avoid using the built in rgb initializer on Color.
    public static func makeColor( _ r: CGFloat, _ g: CGFloat, _ b: CGFloat ) -> Color {
        Color(red: r / 255, green: g / 255, blue: b / 255)
    }
}

#Preview {
    ContentView()
}
