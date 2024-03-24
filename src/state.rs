//! Application state

use dioxus_signals::{Signal, Writable};
use memory_stats::{memory_stats, MemoryStats};

#[derive(Clone, Copy)]
pub struct AppState {
    pub name: Signal<String>,
    pub system: Signal<Option<MemoryStats>>,
}

impl AppState {
    pub fn new() -> Self {
        let name = std::env::var("USER").unwrap_or("world".to_string());
        Self {
            name: Signal::new(name),
            system: Signal::new(None),
        }
    }

    pub fn reverse_name(&mut self) {
        let reverse = |s: &String| s.chars().rev().collect::<String>();
        self.name.with_mut(|s| *s = reverse(s));
    }

    pub async fn update_systemstat(&mut self) {
        println!("Updating systemstat...");
        let compute_with_delay = || {
            std::thread::sleep(std::time::Duration::from_secs(1));
            memory_stats()
        };
        let sys = tokio::task::spawn_blocking(compute_with_delay)
            .await
            .unwrap();
        self.system.with_mut(move |x| {
            *x = sys;
            println!("Updated systemstat to: {:?}", *x);
        });
    }
}

pub fn memory_stats_repr(stats: MemoryStats) -> String {
    format!(
        "Physical: {} GiB, Virtual: {} GiB, Raw: {:?}",
        stats.physical_mem / 1024 / 1024,
        stats.virtual_mem / 1024 / 1024,
        stats
    )
}
