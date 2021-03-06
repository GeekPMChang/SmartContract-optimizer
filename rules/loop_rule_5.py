# Fixed Rule

#################################################
#   Loop rule 5: Unconditional Branch Removing  #
#   ------------------------------------------  #
#   Using a do-while loop instead of a while-   #
#   or for-loop removes a conditional jump      #
#   operation at the beginning of the loop.     #
#################################################

#################################################
#   循环规则 5: 无条件分支移除                      #
#   ------------------------------------------  #
#   使用do-while 循环而不是while 或for 循环，       #
#   应用此规则会删除循环开始处的条件跳转操作。          #
#   注意：有必要确定循环是否至少执行一次               #
#################################################

additional_lines = 0
instance_counter = 0
loop5_dict = {}


def check_rule(added_lines, file_content, loop_statement, contract_name, function_key, rule_list, file_name):
    global additional_lines, instance_counter
    global loop5_dict
    additional_lines = added_lines

    if (loop_statement.conditionExpression and loop_statement.conditionExpression.type == 'BinaryOperation'
            and (loop_statement.conditionExpression.operator != '&&'
                 or loop_statement.conditionExpression.operator != '||')):
        # check initexpression
        if loop_statement.initExpression and loop_statement.initExpression.type == 'VariableDeclarationStatement' \
                and loop_statement.initExpression.variables:
            initial_value = 0
            exit_value = 0
            loop_var_name = loop_statement.initExpression.variables[0].name
            if loop_statement.initExpression.initialValue is not None \
                    and loop_statement.initExpression.initialValue.type == 'NumberLiteral':
                try:
                    initial_value = int(loop_statement.initExpression.initialValue.number)
                except ValueError:
                    return additional_lines
                # check loopExpression
                if loop_statement.loopExpression \
                        and loop_statement.loopExpression.type == 'ExpressionStatement' \
                        and loop_statement.loopExpression.expression is not None \
                        and loop_statement.loopExpression.expression.type == 'UnaryOperation' \
                        and (loop_statement.loopExpression.expression.operator == '++'
                             or loop_statement.loopExpression.expression.operator == '--'):
                    # check conditionExpression
                    if loop_statement.conditionExpression \
                            and loop_statement.conditionExpression.type == 'BinaryOperation' \
                            and loop_statement.conditionExpression.right.type == 'NumberLiteral' \
                            and loop_statement.conditionExpression.left.type == 'Identifier' \
                            and loop_statement.conditionExpression.left.name == loop_var_name:
                        exit_value = int(loop_statement.conditionExpression.right.number)
                        lt_loop_runs = exit_value - initial_value
                        gt_loop_runs = initial_value - exit_value
                        if (loop_statement.conditionExpression.operator == '<' and lt_loop_runs > 0) \
                                or (loop_statement.conditionExpression.operator == '<=' and lt_loop_runs >= 0) \
                                or (loop_statement.conditionExpression.operator == '>' and gt_loop_runs > 0) \
                                or (loop_statement.conditionExpression.operator == '>=' and gt_loop_runs >= 0):
                            print('### Applied LOOP_RULE5 rule at '+contract_name+'--'+function_key+': line: '
                                  + str(loop_statement.loc['start']['line']))
                            replace_loop(loop_statement, file_content)
                            rule_list.append(file_name)
                            loop5_dict[contract_name] = 1 
                            instance_counter += 1
    return additional_lines


def replace_loop(loop_statement, file_content):
    global additional_lines
    loop_location = loop_statement.loc
    loop_line = loop_location['start']['line'] - 1 + additional_lines
    loop_end = loop_location['end']['line'] - 1 + additional_lines
    tabs_to_insert = ' ' * loop_location['start']['column']
    tabs_to_insert_inside = ' ' * (loop_location['start']['column'] + 4)

    loop_init = loop_statement.initExpression
    loop_condition = loop_statement.conditionExpression
    loop_expr = loop_statement.loopExpression

    loop_content = file_content[loop_line]
    init_expression = loop_content[loop_init.loc['start']['column']:loop_init.loc['end']['column']]
    condition_expression = loop_content[loop_condition.loc['start']['column']:loop_condition.loc['end']['column']] + loop_condition.right.number
    loop_expression = loop_content[loop_expr.expression.loc['start']['column']:loop_expr.expression.loc['end']['column'] + 2]

    # replace for (....) with: do {
    line_1 = init_expression + ';\n'
    line_2 = 'do {\n'
    line_3 = loop_expression + ';\n'
    line_4 = '} while (' + condition_expression + ');\n'

    # remove old loop line
    del file_content[loop_line]
    del file_content[loop_end - 1]

    comment_line = '// ### PY_SOLOPT ### Found a rule violation of Loop Rule 5. Loop was replaced by do-while loop.\n'

    file_content.insert(loop_line, tabs_to_insert + line_2)
    file_content.insert(loop_line, tabs_to_insert + line_1)
    file_content.insert(loop_line, tabs_to_insert + comment_line)
    file_content.insert(loop_end + 2, tabs_to_insert + line_4)
    file_content.insert(loop_end + 2, tabs_to_insert_inside + line_3)
    additional_lines += 3
    pass


def get_instance_counter():
    global instance_counter
    return instance_counter


def get_additional_lines():
    global additional_lines
    return additional_lines

def loop5_dict_counter():
    global loop5_dict
    loop5_count = 0
    for item in loop5_dict.keys():
        if loop5_dict[item]== 1 :
            loop5_count += 1
    return loop5_count