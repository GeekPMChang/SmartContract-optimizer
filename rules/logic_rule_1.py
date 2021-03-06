# Fixed Rule

#####################################################
#   Logic rule 1: Exploit Algebraic Identities      #
#   -------------------------------------------     #
#   In details:Application of the law of De Morgan  #
#####################################################

#####################################################
#   逻辑规则  1: 利用代数等价(德摩根定律)                 #
#   -------------------------------------------     #
#   详细：通过用语义上等价的更便宜的表达式替换昂贵的         #
#   表达式来节省气体,本规则中使用了德摩根定律               #
#####################################################

instance_counter = 0
additional_lines = 0
logic1_dict = {}


def check_rule(added_lines, file_content, statement, contract_name, function_key, rule_list, file_name):
    global additional_lines
    additional_lines = added_lines
    if statement.condition.type == 'BinaryOperation' \
            and statement.condition.left.type == 'UnaryOperation' and statement.condition.left.operator == '!' \
            and statement.condition.right.type == 'UnaryOperation' and statement.condition.right.operator == '!':
        # found instance of deMorgan
        if statement.condition.operator == '&&' or statement.condition.operator == '||':
            apply_law_of_de_morgan(statement, file_content, contract_name, function_key)
            rule_list.append(file_name)
    return additional_lines


def apply_law_of_de_morgan(statement, file_content, contract_name, function_key):
    global instance_counter, additional_lines
    global logic1_dict
    
    instance_counter += 1
    logic1_dict[contract_name] = 1
    statement_line = statement.loc['start']['line'] - 1 + additional_lines
    print('### Applied LOGIC_RULE1 rule at '+contract_name+'--'+function_key+': line: ' + str(statement_line))

    new_operator = '&&'
    if statement.condition.operator == '&&':
        new_operator = '||'

    left_expression_location = statement.condition.left.subExpression.loc
    left_expression_start = left_expression_location['start']['column']
    left_expression_end = left_expression_location['end']['column'] + 1

    right_expression_location = statement.condition.right.subExpression.loc
    right_expression_start = right_expression_location['start']['column']
    right_expression_end = right_expression_location['end']['column'] + 1

    left_expression = file_content[statement_line][left_expression_start:left_expression_end]
    right_expression = file_content[statement_line][right_expression_start:right_expression_end]

    condition_start = statement.condition.loc['start']['column']
    condition_end = statement.condition.loc['end']['column'] + 1

    if statement.condition.left.subExpression.type == 'Identifier':
        left_expression = statement.condition.left.subExpression.name
    if statement.condition.right.subExpression.type == 'Identifier':
        right_expression = statement.condition.right.subExpression.name
        condition_end = condition_end + len(right_expression) - 1

    replacement = '!(' + left_expression + ' ' + new_operator + ' ' + right_expression + ')'
    statement_to_move = file_content[statement_line][condition_start:condition_end]

    new_line = file_content[statement_line].replace(statement_to_move, replacement)
    file_content.remove(file_content[statement_line])
    file_content.insert(statement_line, new_line)
    comment_line = '// ############ PY_SOLOPT: Found instance of the law of De Morgan. ############\n'
    file_content.insert(statement_line, comment_line)
    additional_lines += 1


def get_instance_counter():
    global instance_counter
    return instance_counter


def get_additional_lines():
    global additional_lines
    return additional_lines

def logic1_dict_counter():
    global logic1_dict
    logic1_count = 0
    for item in logic1_dict.keys():
        if logic1_dict[item]== 1 :
            logic1_count += 1
    return logic1_count
