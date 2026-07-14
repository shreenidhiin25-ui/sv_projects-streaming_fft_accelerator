# Complex Subtractor

## Purpose

The module accepts two complex inputs and produces one complex output.

This module is reused inside the FFT Butterfly.

---

## Inputs

a_real : signed number

a_imag : signed number

b_real : signed number

b_imag : signed number

---

## Outputs

q_real

q_imag

---

## Mathematical Equation

q_real = a_real - b_real

q_imag = a_imag - b_imag

---

## Timing

Combinational Logic

---

## Latency

1 Combinational Delay

---

## Verification Plan

1. Positive - Positive

2. Negative - Negative

3. Positive - Negative

4. Negative - Positive

5. Zero

6. Maximum Value

7. Minimum Value

8. Overflow

9. Random Tests