import csv
import os

# This function creates detailed report for sabotuer or SEU injection.

def create_detailed_report(sig_list, o_filename, fault_type):
    fields_csv = ['SR Pos', 'Signal Name', 'Signal Type', 'Source Line Number', 'Source File Name', 'File Path']
    path_csv = os.path.dirname(os.path.realpath(__file__))
    outcsv_file = "report_detailed_" + fault_type + ".csv"
    sr_no = 0 # shift register location 
    with open(outcsv_file, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(fields_csv)
        
        for i, x in enumerate(sig_list):        
            if x.get_numBit() == 1:             
                writer.writerow([sr_no, x.get_name(), x.get_type(), x.get_lineNum(), o_filename, path_csv])
                sr_no += 1
            else:
                for k in range(x.get_numBit()):
                    writer.writerow([sr_no, x.get_name(), x.get_type(), x.get_lineNum(), o_filename, path_csv])
                    sr_no += 1

        if(fault_type == "SABOTUER"):    # add control bits
            writer.writerow([sr_no, "CTRL[1]", "input", 4, o_filename, path_csv])
            writer.writerow([sr_no+1, "CTRL[0]", "input", 4, o_filename, path_csv])

    csvfile.close()