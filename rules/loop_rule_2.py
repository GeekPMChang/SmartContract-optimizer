# Classification Rule

#################################################
#   Loop rule 2: Combining Tests                #
#   ------------------------------------------  #
#   Reduces the number of evaluated conditions  #
#   within a loop.                              #
#################################################

#################################################
#   循环规则 2: 条件融合                           #
#   ------------------------------------------  #
#   详细：对循环中的条件语句进行融合，尽量一个循环       #
#   只有一个条件语句                               #
#################################################

from re import fullmatch


additional_lines = 0
instance_counter = 0
loop2_dict = {}


def check_rule(added_lines, file_content, loop_statement, contract_name, function_key,rule_list, file_name):
    global additional_lines, instance_counter
    global loop2_dict
    additional_lines = added_lines
    if loop_statement.type == 'WhileStatement' or loop_statement.type == 'DoWhileStatement':
        if (loop_statement.condition and loop_statement.condition.type == 'BinaryOperation'
                and (loop_statement.condition.operator == '&&' or loop_statement.condition.operator == '||')):
            add_comment_above(file_content, loop_statement.loc)
            print('### Applied LOOP_RULE2 rule at '+contract_name+'--'+function_key+': line: '
                  + str(loop_statement.loc['start']['line'] + additional_lines))
            instance_counter += 1
            loop2_dict[contract_name] = 1
            rule_list.append(file_name)
    elif loop_statement.type == 'ForStatement':
        if (loop_statement.conditionExpression and loop_statement.conditionExpression.type == 'BinaryOperation'
                and (loop_statement.conditionExpression.operator == '&&'
                     or loop_statement.conditionExpression.operator == '||')):
            add_comment_above(file_content, loop_statement.loc)
            print('### Applied LOOP_RULE2 rule at '+contract_name+'--'+function_key+': line: '
                  + str(loop_statement.loc['start']['line'] + additional_lines))
            instance_counter += 1
            loop2_dict[contract_name] = 1
            rule_list.append(file_name)
    return additional_lines


def add_comment_above(file_content, loop_location):
    global additional_lines
    function_line = loop_location['start']['line'] - 1 + additional_lines
    tabs_to_insert = ' ' * loop_location['start']['column']
    new_line = '// ### PY_SOLOPT ### Found a POSSIBLE rule violation of Loop Rule 2.\n'
    new_line2 = '// ### PY_SOLOPT ### Try to combine the tests in the loop ' \
                'in order to contain (in the best case) only one condition.\n'
    file_content.insert(function_line, tabs_to_insert + new_line2)
    file_content.insert(function_line, tabs_to_insert + new_line)
    additional_lines += 2


def get_instance_counter():
    global instance_counter
    return instance_counter


def get_additional_lines():
    global additional_lines
    return additional_lines

def loop2_dict_counter():
    global loop2_dict
    loop2_count = 0
    for item in loop2_dict.keys():
        if loop2_dict[item]== 1 :
            loop2_count += 1
    return loop2_count