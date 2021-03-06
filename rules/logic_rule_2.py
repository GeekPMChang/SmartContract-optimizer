# Fixed Rule

############################################################
#   Logic rule 5: Boolean Variable Elimination             #
#   -------------------------------------------            #
#   In details: Direct evaluation of the condition instead #
#   of storing the result in a boolean variable.           #
############################################################

############################################################
#   逻辑规则 5: 布尔变量消除                                   #
#   -------------------------------------------            #
#   详细: 直接评估条件，替代将结果存储在布尔变量中（等价替代布尔变量） #
############################################################

import pprint
from tkinter import Pack

instance_counter = 0
additional_lines = 0
logic2_dict = {}


def check_rule(added_lines, file_content, function_statements, statement, contract_name, function_key, rule_list, file_name):
    global additional_lines
    additional_lines = added_lines
    # Statement = bool variable declaration
    for function_statement in function_statements:
        if function_statement == statement:
            continue
        if function_statement.type == 'IfStatement' and function_statement.condition.type == 'Identifier':
            for variable in statement.variables:
                if function_statement.condition.name == variable.name and statement.initialValue:
                    # if the value is not modified afterwards
                    if not variable_is_modified_afterwards(function_statements, function_statement, statement, variable.name):
                        eliminate_bool_variable(file_content, statement, function_statement, contract_name, function_key)
                        rule_list.append(file_name)
    return additional_lines


def variable_is_modified_afterwards(function_statements, if_statement, variable_declaration, variable_name):
    before_declaration = True
    for statement in function_statements:
        if before_declaration and statement == variable_declaration:
            before_declaration = False
            continue
        if statement == if_statement:
            # was not used until now, return False
            return False
        # check whether variable_name is used inside the statement
        if statement_changes_variable(statement, variable_name):
            return True
    return False


def statement_changes_variable(statement, variable_name):
    if statement.type == 'VariableDeclarationStatement':
        for variable in statement.variables:
            if variable.name == variable_name:
                return True
    return True


def eliminate_bool_variable(file_content, statement, if_statement, contract_name, function_key):
    global instance_counter, additional_lines
    global logic2_dict
    
    logic2_dict[contract_name] = 1
    instance_counter += 1

    statement_line = statement.loc['start']['line'] - 1 + additional_lines
    if_statement_line = if_statement.loc['start']['line'] - 1 + additional_lines
    print('### Applied LOGIC_RULE2 rule at '+contract_name+'--'+function_key+': line: '+ str(statement_line) + ' and ' + str(if_statement_line))

    tabs_to_insert = ' ' * statement.loc['start']['column']

    condition_start = if_statement.condition.loc['start']['column']
    condition_end = if_statement.condition.loc['end']['column'] + len(if_statement.condition.name)

    statement_location_start = statement.initialValue.loc['start']['column']
    statement_location_end = statement.initialValue.loc['end']['column'] + 1

    statement_to_move = file_content[if_statement_line][condition_start:condition_end]
    replacement = file_content[statement_line][statement_location_start:statement_location_end]

    new_line = file_content[if_statement_line].replace(statement_to_move, replacement)
    file_content.remove(file_content[if_statement_line])
    comment_line = '// ############ PY_SOLOPT: Found instance of an unnecessary boolean variable. ############\n'
    file_content.insert(if_statement_line, new_line)
    file_content.insert(if_statement_line, tabs_to_insert + comment_line)
    file_content.remove(file_content[statement_line])


def get_instance_counter():
    global instance_counter
    return instance_counter

def logic2_dict_counter():
    global logic2_dict
    logic2_count = 0
    for item in logic2_dict.keys():
        if logic2_dict[item]== 1 :
            logic2_count += 1
    return logic2_count
