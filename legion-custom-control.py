#!/usr/bin/env python3
import argparse

def write_sysfs(path, value):
    try:
        with open(path, "w") as f:
            f.write(str(value))
    except PermissionError:
        print(f"Permission denied writing {value} to {path} — need root?")
    except FileNotFoundError:
        print(f"{path} not found.")
    except Exception as e:
        print(f"Other error: {e}")

BOLD = "\033[1m"
UNDERLINE = "\033[4m"
RESET = "\033[0m"

def get_ranges():
    # SPL ranges:
    with open("/sys/class/firmware-attributes/lenovo-wmi-other-0/attributes/ppt_pl1_spl/min_value", "r") as f:
        spl_min = f.read().strip()
    with open("/sys/class/firmware-attributes/lenovo-wmi-other-0/attributes/ppt_pl1_spl/max_value", "r") as f:
        spl_max = f.read().strip()
    with open("/sys/class/firmware-attributes/lenovo-wmi-other-0/attributes/ppt_pl1_spl/current_value", "r") as f:
        spl_current = f.read().strip()
    # SPPT ranges:
    with open("/sys/class/firmware-attributes/lenovo-wmi-other-0/attributes/ppt_pl2_sppt/min_value", "r") as f:
        sppt_min = f.read().strip()
    with open("/sys/class/firmware-attributes/lenovo-wmi-other-0/attributes/ppt_pl2_sppt/max_value", "r") as f:
        sppt_max = f.read().strip()
    with open("/sys/class/firmware-attributes/lenovo-wmi-other-0/attributes/ppt_pl2_sppt/current_value", "r") as f:
        sppt_current = f.read().strip()
    # FPPT ranges:
    with open("/sys/class/firmware-attributes/lenovo-wmi-other-0/attributes/ppt_pl3_fppt/min_value", "r") as f:
        fppt_min = f.read().strip()
    with open("/sys/class/firmware-attributes/lenovo-wmi-other-0/attributes/ppt_pl3_fppt/max_value", "r") as f:
        fppt_max = f.read().strip()
    with open("/sys/class/firmware-attributes/lenovo-wmi-other-0/attributes/ppt_pl3_fppt/current_value", "r") as f:
        fppt_current = f.read().strip()
    # Current platform profile
    with open("/sys/class/platform-profile/platform-profile-0/profile", "r") as f:
        platform_profile = f.read().strip()
    
    print(f"Current profile: {platform_profile}")
    print("========================================")
    print(f"SPL (Min, Current, Max): {spl_min} <= {UNDERLINE}{BOLD}{spl_current}{RESET} <= {spl_max}")
    print(f"SPPT (Min, Current, Max): {sppt_min} <= {UNDERLINE}{BOLD}{sppt_current}{RESET} <= {sppt_max}")
    print(f"FPPT (Min, Current, Max): {fppt_min} <= {UNDERLINE}{BOLD}{fppt_current}{RESET} <= {fppt_max}")

def cmd_get_ranges(args):
    print("Getting ranges for sppt, fppt, and spl...")
    get_ranges()

def cmd_set_all(args):
    print(f"Setting values:")
    print(f"  sppt = {args.sppt}")
    print(f"  fppt = {args.fppt}")
    print(f"  spl  = {args.spl}")

    write_sysfs("/sys/class/platform-profile/platform-profile-0/profile", "custom")
    write_sysfs("/sys/class/firmware-attributes/lenovo-wmi-other-0/attributes/ppt_pl1_spl/current_value", args.spl)
    write_sysfs("/sys/class/firmware-attributes/lenovo-wmi-other-0/attributes/ppt_pl2_sppt/current_value", args.sppt)
    write_sysfs("/sys/class/firmware-attributes/lenovo-wmi-other-0/attributes/ppt_pl3_fppt/current_value", args.fppt)

    get_ranges()
    

def main():
    parser = argparse.ArgumentParser(description="Lenovo Legion SPPT/FPPT/SPL utility tool")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # get_ranges command
    get_parser = subparsers.add_parser(
        "get_ranges",
        help="Get the ranges for sppt, fppt, and spl"
    )
    get_parser.set_defaults(func=cmd_get_ranges)

    # set_all command
    set_parser = subparsers.add_parser(
        "set_all",
        help="Set sppt, fppt, and spl values"
    )
    set_parser.add_argument("--sppt", type=int, required=True, help="SPPT value")
    set_parser.add_argument("--fppt", type=int, required=True, help="FPPT value")
    set_parser.add_argument("--spl", type=int, required=True, help="SPL value")
    set_parser.set_defaults(func=cmd_set_all)

    # Parse args + dispatch
    args = parser.parse_args()
    args.func(args)

if __name__ == "__main__":
    main()
