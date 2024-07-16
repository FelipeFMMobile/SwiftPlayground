
import SwiftUI
import PlaygroundSupport

// A view with 320x400
struct ViewGeometryReader: View {
    var body: some View {
        // how to transform image and title at center, let subtitle bottom?
        VStack(alignment: .leading) {
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 50, height: 50)
            Text("I'm a Star!")
                .font(.largeTitle)
            Spacer()
            Text("a great shine in the sky")
                .font(.subheadline)
                .padding(.bottom, 20)
        }
    }
}

struct ViewGeometryReader2: View {
    var body: some View {
        // GeometryReader create a box for us
        // the child elements can "float" inside, using relative positions
        // but is not quite at center of the full screen, right?
        VStack(alignment: .leading) {
            GeometryReader { proxy in
                VStack(alignment: .center) {
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                    Text("I'm a Star!")
                        .font(.largeTitle)
                        
                }.position(x: proxy.size.width / 2,
                           y: proxy.size.height / 2)
                .onAppear {
                    print("Geometry size is: \(proxy.size)")
                }
            }.background(Color.green)
            
            Spacer()
            Text("a great shine in the sky")
                .font(.subheadline)
                .padding(.bottom, 20)
        }
    }
}

struct ViewGeometryReader3: View {
    var body: some View {
        // ZStack solve this, keep the center and give us the subtitle at bottom.
        GeometryReader { proxy in
            ZStack {
                VStack(alignment: .center) {
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                    Text("I'm a Star!")
                        .font(.largeTitle)
                    
                }.position(x: proxy.size.width / 2,
                           y: proxy.size.height / 2)
                .onAppear {
                    print("Geometry size is: \(proxy.size)")
                }
                VStack(alignment: .leading) {
                    Spacer()
                    Text("a great shine in the sky")
                        .font(.subheadline)
                        .padding(.bottom, 20)
                }
            }
        }.background(Color.gray.opacity(0.50))
    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.setLiveView(ViewGeometryReader3()
    .frame(width: 320, height: 400))
