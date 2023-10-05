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

    pub async fn update_systemstat(&self) {
        let get_sys = || {
            // Sleep a second to simulate long-running task
            std::thread::sleep(std::time::Duration::from_secs(1));
            sysinfo::System::new_with_specifics(sysinfo::RefreshKind::new().with_memory())
        };
        println!("Updating systemstat...");
        let sys = tokio::task::spawn_blocking(get_sys).await.unwrap();
        self.system.with_mut(move |x| {
            *x = Some(sys);
            println!("Updated systemstat to: {:?}", *x);
        });
    }
}
