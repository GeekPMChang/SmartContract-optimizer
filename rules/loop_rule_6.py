# Classification Rule

#################################################
#   Loop rule 6: Loop Fusion                    #
#   ------------------------------------------  #
#   Combining loops across the same collections #
#   to one can save computation and space.      #
#################################################

#################################################
#   循环规则 6: 循环融合                           #
#   ------------------------------------------  #
#   条件相同的连续循环合并为一个可以节省计算量和空间     #
#################################################

import re

additional_lines = 0
instance_counter = 0
loop6_dict = {}


def check_rule(added_lines, file_content, first_loop, second_loop, contract_name, function_key, rule_list, file_name):
    global additional_lines, instance_counter
    global loop6_dict
    additional_lines = added_lines
    if first_loop.initExpression and first_loop.initExpression.type == 'VariableDeclarationStatement' \
            and second_loop.initExpression and second_loop.initExpression.type == 'VariableDeclarationStatement':
        # naive way: check if both lines as strings are the same:
        first_loop_location = first_loop.loc['start']['line'] - 1 + additional_lines
        second_loop_location = second_loop.loc['start']['line'] - 1 + additional_lines

        if file_content[first_loop_location] == file_content[second_loop_location]:
            # todo: check whether loop var is reset
            # first_loop_end_location = first_loop.loc['end']['line'] - 1 + additional_lines
            # first_loop_end = file_content[first_loop_end_location]
            # del file_content[second_loop_location]
            # if bool(re.match('^[\t\n {]+$', file_content[second_loop_location])):
            #     del file_content[second_loop_location]
            #     additional_lines -= 1
            # if bool(re.match('^[\t\n }]+$', first_loop_end)):
            #     del file_content[first_loop_end_location]
            #     additional_lines -= 1
            comment_line = '// ### PY_SOLOPT ### Found a rule violation of Loop Rule 6 - Loop fusion.\n'
            tabs_to_insert = ' ' * first_loop.loc['start']['column']
            print('### Applied LOOP_RULE1 rule at '+contract_name+'--'+function_key+': line: ' + str(first_loop_location))
            rule_list.append(file_name)
            file_content.insert(first_loop_location, tabs_to_insert + comment_line)
            loop6_dict[contract_name] = 1
            instance_counter += 1
    return additional_lines


def get_instance_counter():
    global instance_counter
    return instance_counter


def get_additional_lines():
    global additional_lines
    return additional_lines

def loop6_dict_counter():
    global loop6_dict
    loop6_count = 0
    for item in loop6_dict.keys():
        if loop6_dict[item]== 1 :
            loop6_count += 1
    return loop6_count