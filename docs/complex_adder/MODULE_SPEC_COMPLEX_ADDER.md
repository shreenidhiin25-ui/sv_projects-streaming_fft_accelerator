# Complex Adder

## Purpose

The Complex Adder performs addition of two complex numbers.

The module accepts two complex inputs and produces one complex output.

This module is reused inside the FFT Butterfly.

## Inputs
| Signal | Type   | Description               |
| ------ | ------ | ------------------------- |
| a_real | Signed | Real part of input A      |
| a_imag | Signed | Imaginary part of input A |
| b_real | Signed | Real part of input B      |
| b_imag | Signed | Imaginary part of input B |



## Outputs
| Signal | Description              |
| ------ | ------------------------ |
| p_real | Real part of output      |
| p_imag | Imaginary part of output |


## Mathematical Equation
p_real= a_real + b_real
p_imag= a_imag + b_imag


## Timing
Pure combinational logic.

Output depends only on the current input values.

No clock is required.

## Latency
Latency = 0 clock cycles.

Only propagation delay through the combinational logic exists.

## Verification Plan
1. Positive + Positive

2. Negative + Negative

3. Positive + Negative

4. Zero

5. Maximum Value

6. Minimum Value

7. Overflow

8. Random Tests

## Assumptions 
Inputs are valid signed fixed-point numbers.

Both inputs have identical bit width.

Overflow follows two's complement arithmetic.

## Limitations 
No overflow detection.

No pipelining.

No clock.

No reset.