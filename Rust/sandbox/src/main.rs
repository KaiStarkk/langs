use std::time::Instant;

fn main() {
    let mut i: u64 = 0;
    let start = Instant::now();
    while i < 3000000000 {
        i += 1;
    }
    let end = Instant::now();
    println!("Time taken: {:?}", end.duration_since(start));
    println!(
        "Rate in GHz: {:?}",
        3000000000. * 4. / end.duration_since(start).as_nanos() as f64
    );
}
