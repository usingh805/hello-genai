---
description: Calculate and present monthly compound interest
---

# Compound Interest Calculation Instructions

- Use `work/tools/compound_interest.py` when the user asks to calculate compound interest and provides a principal, annual rate, and duration.
- Run the script from the repository root with `python3` and pass all four required arguments: `--principal`, `--annual-rate`, `--years`, and `--months`.
- Pass the annual rate as a percentage number, such as `7.34` for 7.34%, not as a decimal fraction. Pass `--months` as the additional months after full years, from 0 through 11.
- The script always compounds monthly and reports currency rounded to two decimal places.
- Example:

  ```sh
  python3 work/tools/compound_interest.py --principal 15847 --annual-rate 7.34 --years 8 --months 7
  ```

- Present the result with separate, clearly labeled `Final amount` and `Total interest` values, including the currency symbol and two decimal places.
- State that the result uses monthly compounding and briefly identify the principal, annual rate, and duration used.