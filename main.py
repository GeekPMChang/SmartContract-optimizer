import sys
import os
import ntpath
import csv
import requests
import json
import ssl

from solidity_parser import parser

import evaluation
from rules import loop_rule_1, logic_rule_1, logic_rule_2, recursion_rule, loop_rule_2, \
    loop_rule_3, loop_rule_4, loop_rule_5, loop_rule_6



def main():
    requests.packages.urllib3.disable_warnings()
    if len(sys.argv) > 1:
        if sys.argv[1] == '-initialize':
            initialize()
            return 0
        elif sys.argv[1] == '-preprocess':
            preprocess()
            return 0
        elif sys.argv[1] == '-demorgan':
            evaluation.count_de_morgan()
            return 0
        elif sys.argv[1] == '-boolean':
            evaluation.count_bool_variables()
            return 0
        elif sys.argv[1] == '-loops':
            evaluation.count_loops()
            return 0
        elif sys.argv[1] == '-loopstatements':
            evaluation.count_loop_conditions()
            return 0
    else:
        files = []
        for r, d, f in os.walk("./input/data_from_etherscan/origin-contract"):
            for file in f:
                files.append(os.path.join(r, file))

        for f in files:
            # check the format of file PATH
            if f[-3:-1]+f[-1]!="sol":
                print("Wrong Input!   FILE PATH:"+f)
            else:
                additional_lines = 0
                print("Success Input!   FILE PATH:"+f)
                # read input
                file = open(f, "r", encoding='utf8')
                text = file.read()
                # text -- the original smart contract
                
                # TODO: replace all \t characters with spaces
                try:
                    source_unit = parser.parse(text=text, loc=True)
                except (TypeError, AttributeError):
                    continue
                source_unit_object = parser.objectify(source_unit)
                contracts = source_unit_object.contracts.keys()

                # create output file
                input_file = open(f, "r", encoding='utf8')
                output_file = open('./output/optimized/origin-optimized/' + ntpath.basename(f), 'w', encoding='utf8')
                content = input_file.readlines()

                # get all functions from all contracts in the file
                all_functions = {}
                for contract in contracts:
                    function_dictionary = source_unit_object.contracts[contract].functions
                    all_functions = {**all_functions, **function_dictionary}

                loop_statements = ['ForStatement', 'WhileStatement', 'DoWhileStatement']

                # process rules
                for contract in contracts:
                    functions = source_unit_object.contracts[contract].functions
                    function_keys = source_unit_object.contracts[contract].functions.keys()
                    for function_key in function_keys:
                        function = functions[function_key]
                        function_body = function._node.body
                        if function_body:
                            statements = function_body.statements
                            ##### PROCEDURE RULE 1 ######
                            additional_lines = recursion_rule.check_rule(additional_lines, content,
                                                                           statements, function_key,
                                                                           function.arguments, function._node.loc)
                            first_for_statement = None
                            for statement in statements:
                                if isinstance(statement, str):
                                    # would result in an AttributeError when there is no statement type. example: 'throw;'
                                    first_for_statement = None
                                    continue
                                if statement:
                                    ###### LOGIC RULE 1 ######
                                    if statement.type == 'IfStatement':
                                        additional_lines = logic_rule_1.check_rule(additional_lines, content, statement)

                                    ###### LOGIC RULE 2 ######
                                    if statement.type == 'VariableDeclarationStatement' and statement.variables \
                                            and len(statement.variables) == 1:
                                        for variable in statement.variables:
                                            if variable.type == 'VariableDeclaration' \
                                                    and variable.typeName.type == 'ElementaryTypeName' \
                                                    and variable.typeName.name == 'bool':
                                                additional_lines = logic_rule_2.check_rule(additional_lines, content,
                                                                                           statements, statement)

                                    ###### LOOP RULE 1 ######
                                    if statement.type == 'ForStatement':
                                        additional_lines = loop_rule_1.check_rule(additional_lines, content, statement,
                                                                                  all_functions)

                                    ###### LOOP RULE 2 ######
                                    if statement.type in loop_statements:
                                        additional_lines = loop_rule_2.check_rule(additional_lines, content, statement)

                                    ###### LOOP RULE 3 ######
                                    if statement.type == 'ForStatement':
                                        additional_lines = loop_rule_3.check_rule(additional_lines, content, statement)

                                    ###### LOOP RULE 4 ######
                                    if statement.type == 'ForStatement':
                                        additional_lines = loop_rule_4.check_rule(additional_lines, content, statement)

                                    ###### LOOP RULE 5 ######
                                    if statement.type == 'ForStatement':
                                        additional_lines = loop_rule_5.check_rule(additional_lines, content, statement)

                                    ###### LOOP RULE 6 ######
                                    if statement.type == 'ForStatement':
                                        if first_for_statement is not None:
                                            additional_lines = loop_rule_6.check_rule(additional_lines, content,
                                                                                      first_for_statement, statement)
                                        first_for_statement = statement
                                    else:
                                        first_for_statement = None

                # content -- the optimized smart contract
                # write output
                output_file.writelines(content)
                output_file.close()
        # summary of the findings
        print('########################################################################')
        print('#########                SUMMARY OF RESULTS                    #########')
        print('########################################################################')
        print('#########                '+str(files.__len__())+'                    #########')
        print('########################################################################')
        print('######### number of instances                 loop rule 1: ' + str(loop_rule_1.get_instance_counter()))
        print('######### number of instances                 loop rule 2: ' + str(loop_rule_2.get_instance_counter()))
        print('######### number of instances                 loop rule 3: ' + str(loop_rule_3.get_instance_counter()))
        print('######### number of instances                 loop rule 4: ' + str(loop_rule_4.get_instance_counter()))
        print('######### number of instances                 loop rule 5: ' + str(loop_rule_5.get_instance_counter()))
        print('######### number of instances                 loop rule 6: ' + str(loop_rule_6.get_instance_counter()))
        print('######### number of instances                 logic rule 1: ' + str(logic_rule_1.get_instance_counter()))
        print('######### number of instances                 logic rule 2: ' + str(logic_rule_2.get_instance_counter()))
        print('######### number of instances                 recursion rule: ' + str(recursion_rule.get_instance_counter()))
        print('########################################################################')


def preprocess():
    files = []
    for r, d, f in os.walk("./output/optimized"):
        for file in f:
            files.append(os.path.join(r, file))
    print(files.__len__())
    for f in files:
        if f[-3:-1] + f[-1] != "sol":
            print("Wrong Input!   FILE PATH:" + f)
        else:
            file = open(f, "r", encoding='utf8')
            text = file.read()
            if text.startswith('{{'):
                print("################ corrupt file: " + f)
            else:
                data = json.loads(text)
                print(f)
                output_file = open(file.name.replace("contracts", "evaluation_contracts"), 'w', encoding='utf8')
                files_appended = ''
                for key, value in data.items():
                    files_appended = files_appended + value['content'] + "\n\n"
                file_content = files_appended.replace("\r\n", "\n")
                output_file.write(file_content)
                output_file.close()

# load smart contracts from etherscan and store in "./input/data_from_etherscan"
def initialize():
    # read the csv, then get the smart contracts list (names-address)
    with open('./export-verified-contractaddress-opensource-license-latest.csv') as csv_file:
        read_csv = csv.reader(csv_file, delimiter=',')
        addresses = []
        names = []
        skip = 2
        for row in read_csv:
            if skip > 0:
                skip -= 1
            else:
                addresses.append(row[1])
                names.append(row[2])

    # get contracts from api
    url = "https://api.etherscan.io/api"
    api_key = "745FC26XQU583KDTVKY6PKNEE1VVTM8UVH"
    totalNumber=len(addresses)

    for iteration in range(48,int(totalNumber/100)+1):
        if iteration<int(totalNumber/100):
            downbound=iteration*100
            upbound=(iteration+1)*100
        else:
            downbound = iteration * 100
            upbound = totalNumber

        for i in range(downbound,upbound):
            print(str(i + 1) + "/" + str(len(addresses)) + ": " + names[i] + "; address: " + addresses[i])
            # fetch the data
            params = {'module': 'contract', 'action': 'getsourcecode', 'address': addresses[i], 'apikey': api_key}
            try:
                request = requests.get(url=url, params=params,verify=False)
                data = request.json()
                # write the data into "./input/data_from_etherscan"
                output_file = open('./input/data_from_etherscan/latest-contract/' + names[i] + '.sol', 'w', encoding='utf8')
                file_content = data['result'][0]['SourceCode'].replace("\r\n", "\n")
                output_file.write(file_content)
                output_file.close()
            except(ssl.SSLEOFError):
                print("SSLERROR")


        print(str(iteration)+"  complete!")




if __name__ == "__main__":
    main()
