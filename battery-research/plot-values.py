import argparse
import matplotlib
matplotlib.use("Agg")  # Flatpak / headless safe
import matplotlib.pyplot as plt

def read_numbers(path):
    values = []
    with open(path, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            values.append(float(line))
    return values

def main():
    parser = argparse.ArgumentParser(
        description="Plot newline-separated numbers over time as % of max"
    )
    parser.add_argument("file", help="Path to input text file")
    parser.add_argument(
        "--interval",
        type=float,
        default=2.0,
        help="Seconds between samples (default: 2.0)",
    )
    parser.add_argument(
        "--max",
        type=float,
        required=True,
        help="Maximum value used for percentage calculation",
    )
    parser.add_argument(
        "--output",
        default="plot.png",
        help="Output image file (default: plot.png)",
    )
    parser.add_argument(
        "--cap",
        action="store_true",
        help="Cap values at 100%% if they exceed the max",
    )
    parser.add_argument(
        "--full",
        action="store_true",
        help="Show the entire y-axis, from 0%% to 100%%",
    )
    args = parser.parse_args()

    if args.max <= 0:
        raise ValueError("--max must be greater than 0")

    values = read_numbers(args.file)
    if not values:
        print("No data found in file.")
        return

    # Convert to percentage
    percentages = [(v / args.max) * 100.0 for v in values]

    if args.cap:
        percentages = [min(p, 100.0) for p in percentages]

    times = [i * args.interval for i in range(len(percentages))]

    plt.figure()
    plt.plot(times, percentages)
    plt.xlabel("Time (seconds)")
    plt.ylabel("Percent of max (%)")
    plt.title("Values Over Time (% of max)")
    if args.full:
        plt.ylim(0, 100)
    plt.grid(True)

    plt.tight_layout()
    plt.savefig(args.output)
    print(f"Saved plot to {args.output}")

if __name__ == "__main__":
    main()
