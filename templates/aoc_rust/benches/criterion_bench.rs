#![allow(unused)]

use criterion::{Criterion, black_box, criterion_group, criterion_main};
use std::fs;

pub fn criterion_benchmark(c: &mut Criterion) {
    let input = fs::read_to_string("input").unwrap();
    c.bench_function("part 1", |b| b.iter(|| day_1::run(black_box(&input))));
}

criterion_group!(benches, criterion_benchmark);
criterion_main!(benches);
