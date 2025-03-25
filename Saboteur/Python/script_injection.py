import argparse
from f_SEU_injection import inject_SEU
from f_SABOTUER_Injection import inject_sabotuer

# Main function
def main():
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Run a function based on input arguments.")
    parser.add_argument('TYPE', type=str, help="Specify the function type as TYPE=SABOTUER or TYPE=SEU.")
    parser.add_argument('FILE', type=str, help="Specify the file as FILE=filename.")
    
    # Parse the arguments
    args = parser.parse_args()

    # Extract values from arguments
    if not args.TYPE.startswith("TYPE=") or not args.FILE.startswith("FILE="):
        print("Error: Arguments must be in the format TYPE=value and FILE=value.")
        return

    type_value = args.TYPE.split("=")[1]
    file_value = args.FILE.split("=")[1]

    # Run the selected function
    if type_value == "SEU":
        result = inject_SEU(file_value)
    elif type_value == "SABOTUER":
        result = inject_sabotuer(file_value)
    else:
        print(f"Error: Invalid TYPE value '{type_value}'. Valid options are 'SEU' or 'SABOTUER'.")
        return

    # Print the result
    print(result)

# Check if this file is being run directly
if __name__ == "__main__":
    main()
