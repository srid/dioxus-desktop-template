#![allow(non_snake_case)]
mod state;

use dioxus::prelude::*;
use dioxus_desktop::{LogicalSize, WindowBuilder};
use dioxus_router::prelude::*;
use dioxus_signals::*;
use state::AppState;

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
    use_context_provider(cx, || Signal::new(AppState::new()));

    cx.render(rsx! { Router::<Route> {} })
}

fn Wrapper(cx: Scope) -> Element {
    render! {
        div { class: "container text-xl flex flex-col items-center justify-between h-screen",
            Nav {}
            div { class: "m-auto p-4", Outlet::<Route> {} }
            footer { class: "mx-auto flex flex-row justify-center items-center w-full p-4 text-sm text-gray-400",
                "Powered by Dioxus "
                img { class: "w-4 h-4 self-center", src: "dioxus.png" }
            }
        }
    }
}

fn Home(cx: Scope) -> Element {
    let state: Signal<AppState> = *use_context(cx).unwrap();
    let name = &state.read().name;
    render! {
        p {
            "Hello, "
            span { class: "font-bold", "{name}" }
            "!"
        }
        div {
            class: "hover:bg-purple-200 text-sm mt-4 italic rounded cursor-pointer",
            onmouseenter: move |_event| {
                state.with_mut(AppState::reverse_name);
            },
            onmouseleave: move |_event| {
                state.with_mut(AppState::reverse_name);
            },
            "Reverse my name!"
        }
    }
}

fn About(cx: Scope) -> Element {
    render! {
        div { class: "flex flex-col items-center",
            p {
                "You are looking at a "
                span { class: "font-bold", "Dioxus" }
                " app"
            }

            a { href: "https://dioxuslabs.com/", img { class: "w-32 h-32", src: "dioxus.png" } }
        }
    }
}

fn Nav(cx: Scope) -> Element {
    let NavLink = |route: Route, text: &str| {
        render! {
            Link { to: route, class: "px-3 py-2 text-purple-600 rounded", active_class: "active", text }
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
