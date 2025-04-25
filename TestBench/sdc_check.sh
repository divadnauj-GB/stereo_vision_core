
touch logs/diff.log 

# Application specific output: The following check will be performed only if at least one of diff.log, stdout_diff.log, and stderr_diff.log is different

diff output_vector_data.txt Golden_output_vector_data.txt  > logs/special_check.log
diff output_vector_valid.txt Golden_output_vector_valid.txt >> logs/special_check.log

cp stdout.log stderr.log output_vector_valid.txt output_vector_data.txt fault_descriptor.txt logs/

#cp tb_Adder32.vcd logs/