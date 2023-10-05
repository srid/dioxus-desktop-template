//! Application state

use dioxus_signals::Signal;
use sysinfo::{System, SystemExt};

#[derive(Clone, Copy)]
pub struct AppState {
    pub name: Signal<String>,
    pub system: Signal<Option<System>>,
}

impl AppState {
    pub fn new() -> Self {
        let name = std::env::var("USER").unwrap_or("world".to_string());
        Self {
            name: Signal::new(name),
            system: Signal::new(None),
        }
    }

    pub fn reverse_name(&self) {
        let reverse = |s: &String| s.chars().rev().collect::<String>();
        self.name.with_mut(|s| *s = reverse(s));
    }

    pub fn update_systemstat(&self) {
        let get_sys = || {
            // Sleep a second to simulate slowness
            std::thread::sleep(std::time::Duration::from_secs(1));
            let mut sys =
                sysinfo::System::new_with_specifics(sysinfo::RefreshKind::new().with_memory());
            sys.refresh_memory();
            sys
        };
        self.system.with_mut(|x| {
            *x = Some(get_sys());
            println!("Updated sys: {:?}", *x);
        });
    }
}
