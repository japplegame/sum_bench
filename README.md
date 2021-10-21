## Binary string sum benchmark

To test algos use:

```sh
$ dub run --compiler=ldc2 --build=release -- --checks
```

## Results (21.10.2021)

```sh
$ dub run --compiler=ldc2 --build=release
```

```sh
══════════════════════════════════════════════
max string length: 100
iterations:        100000
Dark Hole 2            100.00% (    9.48ms) ▐████▌
basic2                 102.00% (    9.69ms) ▐████▌
unrolled chunks 2      102.00% (    9.71ms) ▐████▌
unrolled chunks 64     104.00% (    9.86ms) ▐████▋
unrolled chunks 16     106.00% (   10.08ms) ▐████▊
SIMD convert           115.00% (   10.97ms) ▐█████▎
stackoverflow          163.00% (   15.46ms) ▐███████▋
Dark Hole              212.00% (   20.17ms) ▐██████████ 
basic                 4192.00% (  397.35ms) │ (too big)
══════════════════════════════════════════════
max string length: 1000
iterations:        10000
unrolled chunks 16     100.00% (    3.78ms) ▐████▌
unrolled chunks 64     102.00% (    3.88ms) ▐████▌
SIMD convert           113.00% (    4.28ms) ▐█████▏
unrolled chunks 2      113.00% (    4.30ms) ▐█████▏
basic2                 115.00% (    4.36ms) ▐█████▎
Dark Hole 2            117.00% (    4.45ms) ▐█████▎
stackoverflow          314.00% (   11.89ms) ▐███████████████▏
Dark Hole              368.00% (   13.92ms) ▐█████████████████▉
basic                13617.00% (  514.88ms) │ (too big)
══════════════════════════════════════════════
max string length: 10000
iterations:        1000
unrolled chunks 16     100.00% (    3.47ms) ▐████▌
unrolled chunks 64     106.00% (    3.68ms) ▐████▊
SIMD convert           109.00% (    3.78ms) ▐████▉
unrolled chunks 2      111.00% (    3.85ms) ▐█████ 
Dark Hole 2            116.00% (    4.03ms) ▐█████▎
basic2                 119.00% (    4.13ms) ▐█████▍
stackoverflow          336.00% (   11.66ms) ▐████████████████▎
Dark Hole              404.00% (   14.02ms) ▐███████████████████▋
basic                46016.00% ( 1595.39ms) │ (too big)
```
