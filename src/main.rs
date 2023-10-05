#![allow(non_snake_case)]
use dioxus::prelude::*;
use dioxus_desktop::{LogicalSize, WindowBuilder};
use dioxus_router::prelude::*;

fn main() {
    // launch the dioxus app in a webview
    dioxus_desktop::launch_cfg(
        App,
        dioxus_desktop::Config::new()
            .with_custom_head(r#"<link rel="stylesheet" href="tailwind.css">"#.to_string())
            .with_window(
                WindowBuilder::new()
                    .with_title("Dioxus Desktop Template")
                    .with_inner_size(LogicalSize::new(600.0, 400.0)),
            ),
    );
}

#[derive(Routable, PartialEq, Debug, Clone)]
#[rustfmt::skip]
enum Route {
    #[layout(Wrapper)]
        #[route("/")]
        Home {},
        #[route("/about")]
        About {},
}

fn App(cx: Scope) -> Element {
    cx.render(rsx! { Router::<Route> {} })
}

fn Wrapper(cx: Scope) -> Element {
    render! {
        Nav {}
        div { class: "container mx-auto text-xl p-4 flex flex-col items-center",
            div { Outlet::<Route> {} }
            footer { class: "flex flex-row justify-center items-center w-full p-4 text-sm text-gray-400",
                "Powered by Dioxus "
                img { class: "w-4 h-4 self-center", src: "dioxus.png" }
            }
        }
    }
}

fn Home(cx: Scope) -> Element {
    render! {
        p {
            "Hello, "
            span { class: "font-bold", "world" }
            "!"
        }
    }
}

fn About(cx: Scope) -> Element {
    render! {
        div { class: "flex flex-col items-center",
            p { "You are looking at a Dioxus app" }
            a { href: "https://dioxuslabs.com/", img { class: "w-32 h-32", src: "dioxus.png" } }
        }
    }
}

fn Nav(cx: Scope) -> Element {
    let NavLink = |route: Route, text: &str| {
        render! {
            Link { to: route, class: "px-3 py-2 text-purple-600", active_class: "active", text }
        }
    };
    render! {
        nav { class: "flex flex-row justify-between w-full mb-8 px-4 py-2 bg-purple-200",
            div { class: "flex items-center", h1 { class: "text-lg font-bold", "Dioxus Desktop Template" } }
            div { class: "flex items-center",
                NavLink(Route::Home {}, "Home"),
                NavLink(Route::About {}, "About")
            }
        }
    }
}
