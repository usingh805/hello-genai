import argparse
from decimal import Decimal, ROUND_HALF_UP


def main() -> None:
	parser = argparse.ArgumentParser(description="Calculate monthly compound interest.")
	parser.add_argument("--principal", type=Decimal, required=True, help="Starting amount in dollars")
	parser.add_argument("--annual-rate", type=Decimal, required=True, help="Annual interest rate as a percent")
	parser.add_argument("--years", type=int, required=True, help="Number of full years")
	parser.add_argument("--months", type=int, required=True, help="Additional months (0 through 11)")
	arguments = parser.parse_args()

	if arguments.principal < 0:
		parser.error("--principal must be zero or greater")
	if arguments.annual_rate < 0:
		parser.error("--annual-rate must be zero or greater")
	if arguments.years < 0:
		parser.error("--years must be zero or greater")
	if not 0 <= arguments.months <= 11:
		parser.error("--months must be between 0 and 11")

	total_months = arguments.years * 12 + arguments.months
	monthly_rate = arguments.annual_rate / 100 / 12
	amount = arguments.principal * (1 + monthly_rate) ** total_months
	interest = amount - arguments.principal
	cents = Decimal("0.01")

	print(f"Final amount: ${(amount.quantize(cents, rounding=ROUND_HALF_UP)):,.2f}")
	print(f"Total interest: ${(interest.quantize(cents, rounding=ROUND_HALF_UP)):,.2f}")


if __name__ == "__main__":
	main()