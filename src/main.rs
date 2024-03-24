#![allow(non_snake_case)]
mod state;

use dioxus::prelude::*;
use dioxus_desktop::{LogicalSize, WindowBuilder};
use dioxus_router::prelude::*;
use memory_stats::MemoryStats;
use state::AppState;

fn main() {
    // launch the dioxus app in a webview
    let config = dioxus_desktop::Config::new()
        .with_custom_head(r#"<link rel="stylesheet" href="tailwind.css">"#.to_string())
        .with_window(
            WindowBuilder::new()
                .with_title("Dioxus Desktop Template")
                .with_inner_size(LogicalSize::new(600.0, 500.0)),
        );
    LaunchBuilder::desktop().with_cfg(config).launch(App);
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

fn App() -> Element {
    use_context_provider(AppState::new);

    rsx! { Router::<Route> {} }
}

fn Wrapper() -> Element {
    rsx! {
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

fn Home() -> Element {
    let mut state = use_context::<AppState>();
    let name = state.name;
    rsx! {
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

fn SystemInfo() -> Element {
    let mut state = use_context::<AppState>();
    let mut fut = use_resource(move || async move {
        state.update_systemstat().await;
    });
    let system = state.system.read();
    rsx! {
        div { class: "flex flex-col items-center p-4",
            h1 { class: "text-2xl font-bold mb-4", "System Info" }
            button {
                class: "px-2 py-1 my-2 bg-purple-600 hover:bg-purple-800 text-white rounded-md",
                onclick: move |_event| { fut.restart() },
                "Update"
            }
            match system.as_ref() {
                None => rsx! { Loader {} },
                Some(stats) => rsx! { ViewMemoryStats { stats: *stats } }
            }
        }
    }
}

#[component]
fn ViewMemoryStats(stats: MemoryStats) -> Element {
    let s = state::memory_stats_repr(stats);
    rsx! {div { class: "text-sm font-mono bg-gray-200 rounded-lg p-4 animate-highlight", "{s}" }}
}

#[component]
fn Loader() -> Element {
    rsx! {
        div { class: "flex justify-center items-center",
            div { class: "animate-spin rounded-full h-32 w-32 border-t-2 border-b-2 border-purple-500" }
        }
    }
}

fn About() -> Element {
    rsx! {
        div { class: "flex flex-col items-center",
            p {
                "You are looking at a "
                span { class: "font-bold", "Dioxus" }
                " app (see source code "
                ExternalLink {
                    href: "https://github.com/srid/dioxus-desktop-template",
                    title: "Github repository",
                    "here"
                }
                ")"
            }
            a { href: "https://dioxuslabs.com/", img { class: "w-32 h-32", src: "dioxus.png" } }
        }
    }
}

#[component]
fn NavLink(route: Route, children: Element) -> Element {
    rsx! {
        Link {
            to: route,
            class: "px-3 py-2 hover:text-white rounded-md",
            active_class: "bg-purple-600 text-white",
            {children}
        }
    }
}

fn Nav() -> Element {
    rsx! {
        nav { class: "flex flex-row justify-between w-full mb-8 px-4 py-2 bg-gray-800",
            div { class: "flex items-center",
                h1 { class: "text-lg font-bold text-white", "Dioxus Desktop Template" }
            }
            div { class: "flex items-center",
                NavLink { route: Route::Home {}, "Home" }
                NavLink { route: Route::SystemInfo {}, "System" }
                NavLink { route: Route::About {}, "About" }
            }
        }
    }
}

#[component]
fn ExternalLink(href: &'static str, title: &'static str, children: Element) -> Element {
    rsx! {
        a {
            class: "text-purple-600 hover:text-purple-800",
            href: "{href}",
            title: "{title}",
            {children}
        }
    }
}
