use divan::black_box;
use std::fs;

#[divan::bench]
fn bench(bencher: divan::Bencher) {
    bencher.bench(|| {
        let input = fs::read_to_string("input").unwrap();
        day_1::run(black_box(&input));
    });
}

fn main() {
    divan::main();
}
