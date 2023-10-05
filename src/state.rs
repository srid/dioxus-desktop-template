//! Application state

pub struct AppState {
    pub name: String,
}

impl AppState {
    pub fn new() -> Self {
        let name = std::env::var("USER").unwrap_or("world".to_string());
        Self { name }
    }

    pub fn reverse_name(&mut self) {
        self.name = self.name.chars().rev().collect::<String>();
    }
}
