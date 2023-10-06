#![allow(non_snake_case)]
mod state;

use dioxus::prelude::*;
use dioxus_desktop::{LogicalSize, WindowBuilder};
use dioxus_router::prelude::*;
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
                    .with_inner_size(LogicalSize::new(600.0, 500.0)),
            ),
    );
}

#[derive(Routable, PartialEq, Debug, Clone)]
#[rustfmt::skip]
enum Route {
    #[layout(Wrapper)]
        #[route("/")]
        Home {},
        #[route("/info")]
        SystemInfo {},
        #[route("/about")]
        About {},
}

/// Get the [AppState] from context
fn use_app_state(cx: Scope) -> AppState {
    *use_context(cx).unwrap()
}

fn App(cx: Scope) -> Element {
    use_context_provider(cx, AppState::new);

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
    let state = use_app_state(cx);
    let name = state.name;
    render! {
        div { class: "flex flex-col items-center justify-center",
            p {
                "Hello, "
                span { class: "font-bold", "{name}" }
                "!"
            }
            div {
                class: "flex items-center hover:bg-purple-200 text-sm mt-4 italic rounded cursor-pointer",
                onmouseenter: move |_event| {
                    state.reverse_name();
                },
                onmouseleave: move |_event| {
                    state.reverse_name();
                },
                "m-a-n-g-l-e"
            }
        }
    }
}

fn SystemInfo(cx: Scope) -> Element {
    let state = use_app_state(cx);
    use_future(cx, (), |_| async move {
        state.update_systemstat().await;
    });
    let system = state.system.read();
    render! {
        div { class: "flex flex-col items-center p-4",
            h1 { class: "text-2xl font-bold mb-4", "System Info" }
            match &*system {
                None => render! { Loader {} },
                Some(system) => {
                    let s = format!("{:?}", system);
                    render! {
                        div {
                            class: "text-sm font-mono bg-gray-200 rounded-lg p-4",
                            s
                        }
                    }
                }
            }
        }
    }
}

fn Loader(cx: Scope) -> Element {
    render! {
        div { class: "flex justify-center items-center",
            div { class: "animate-spin rounded-full h-32 w-32 border-t-2 border-b-2 border-purple-500" }
        }
    }
}

fn About(cx: Scope) -> Element {
    render! {
        div { class: "flex flex-col items-center",
            p {
                "You are looking at a "
                span { class: "font-bold", "Dioxus" }
                " app (see source code "
                a {
                    class: "text-purple-600 hover:text-purple-800",
                    href: "https://github.com/srid/dioxus-desktop-template",
                    "here"
                }
                ")"
            }
            a { href: "https://dioxuslabs.com/", img { class: "w-32 h-32", src: "dioxus.png" } }
        }
    }
}

fn Nav(cx: Scope) -> Element {
    let NavLink = |route: Route, text: &str| {
        render! {
            Link {
                to: route,
                class: "px-3 py-2 hover:text-white rounded-md",
                active_class: "bg-purple-600 text-white",
                text
            }
        }
    };
    render! {
        nav { class: "flex flex-row justify-between w-full mb-8 px-4 py-2 bg-gray-800",
            div { class: "flex items-center",
                h1 { class: "text-lg font-bold text-white", "Dioxus Desktop Template" }
            }
            div { class: "flex items-center",
                NavLink(Route::Home {}, "Home"),
                NavLink(Route::SystemInfo {}, "System"),
                NavLink(Route::About {}, "About")
            }
        }
    }
}
