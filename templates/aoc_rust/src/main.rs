use day_1::run;
use std::fs;

fn main() {
    let input = fs::read_to_string("day_1/input").unwrap();
    let (p1, p2) = run(&input);
    println!("part 1: {}", p1);
    println!("part 2: {}", p2);
}

#[test]
fn example() {
    let example = fs::read_to_string("example").unwrap();
    let (p1, _) = run(&example);
    assert_eq!(p1, 11);
}
