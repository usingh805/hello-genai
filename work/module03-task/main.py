"""Run a simple calculator example."""

from calculator import Calculator


first_number = 10
second_number = 4
calculator = Calculator()

print(f"{first_number} + {second_number} = {calculator.add(first_number, second_number)}")
print(f"{first_number} - {second_number} = {calculator.subtract(first_number, second_number)}")
print(f"{first_number} * {second_number} = {calculator.multiply(first_number, second_number)}")
