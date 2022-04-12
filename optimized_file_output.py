def optimizedFileOutput(optimized_list):
    optimized_types=['LOGIC_RULE_1', 'LOGIC_RULE_2', 'LOOP_RULE_1', 'LOOP_RULE_2', 'LOOP_RULE_3', 'LOOP_RULE_4', 'LOOP_RULE_5', 'LOOP_RULE_6', 'RECURSION_RULE', 'PACKING_RULE']
    flag=0
    
    output_file = open('./output/optimized_list.txt', 'w', encoding='utf8')
    output_file.writelines('Optimized Filelist: \n')
    for each_list in optimized_list:
        output_file.writelines(optimized_types[flag] + '(' +str(len(each_list) ) + ' of instances): ')
        flag = flag+1
        if len(each_list):
           for each_file in each_list:
               output_file.writelines(each_file + '; ')
        output_file.writelines('\n')
    output_file.close()
        
    