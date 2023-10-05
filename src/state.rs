//! Application state

use dioxus_signals::Signal;

#[derive(Clone, Copy)]
pub struct AppState {
    pub name: Signal<String>,
}

impl AppState {
    pub fn new() -> Self {
        let name = std::env::var("USER").unwrap_or("world".to_string());
        Self {
            name: Signal::new(name),
        }
    }

    pub fn reverse_name(&self) {
        let reverse = |s: &String| s.chars().rev().collect::<String>();
        self.name.with_mut(|s| *s = reverse(s));
    }
}
