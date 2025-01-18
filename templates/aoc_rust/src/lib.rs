use std::collections::HashMap;

pub fn run(input: &str) -> (usize, usize) {
    let mut c1: Vec<usize> = Vec::with_capacity(1000);
    let mut c2: Vec<usize> = Vec::with_capacity(1000);

    for line in input.lines() {
        let mut tokens = line.split_whitespace();
        c1.push(tokens.next().unwrap().parse().unwrap());
        c2.push(tokens.next().unwrap().parse().unwrap());
    }

    c1.sort();
    c2.sort();

    let p1 = c1
        .iter()
        .zip(c2.clone())
        .map(|(c1, c2)| c1.abs_diff(c2))
        .sum();

    let mut p2 = 0usize;
    let mut map: HashMap<usize, usize> = HashMap::new();
    for needle in c1.iter() {
        if !map.contains_key(needle) {
            map.insert(*needle, c2.iter().filter(|el| *el == needle).sum());
        }
        p2 += map[needle];
    }

    (p1, p2)
}
