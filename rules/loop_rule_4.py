# Fixed RUle

#################################################
#   Loop rule 4: Transfer-Driven Loop Unrolling #
#   ------------------------------------------  #
#   Removing trivial assignments (aliases)      #
#   within a loop and replacing them with the   #
#  values themselves reduces the required space.#
#################################################

#################################################
#   循环规则 4:  转移驱动的循环展开                  #
#   ------------------------------------------  #
#   删除循环中的分配的临时变量，并且使用该变量的值本身   #
#   替换它们可以减少所需的空间。                     #
#################################################

additional_lines = 0
instance_counter = 0
loop4_dict = {}


def check_rule(added_lines, file_content, loop_statement, contract_name, function_key, rule_list, file_name):
    global additional_lines
    additional_lines = added_lines

    if loop_statement.initExpression and loop_statement.initExpression.type == 'VariableDeclarationStatement' \
            and loop_statement.initExpression.variables:
        loop_var_name = loop_statement.initExpression.variables[0].name
        if loop_statement.body and loop_statement.body.type == 'Block':
            replace_trivial_assignment(loop_statement.body.statements, loop_var_name, file_content, contract_name, function_key,rule_list, file_name)
    return additional_lines


def replace_trivial_assignment(loop_statements, loop_var_name, file_content, contract_name, function_key, rule_list, file_name):
    global instance_counter
    global loop4_dict
    for statement in loop_statements:
        if isinstance(statement, str):
            # would result in an AttributeError when there is no statement type. example: 'throw;' or 'break;'
            continue
        if statement.type == 'VariableDeclarationStatement' \
                and statement.variables \
                and statement.initialValue is not None \
                and statement.initialValue.type == 'Identifier' \
                and statement.initialValue.name == loop_var_name:
            var_name = statement.variables[0].name
            if not var_is_reset(loop_statements, statement, var_name):
                print('### Applied LOOP_RULE4 rule at '+contract_name+'--'+function_key+': line: ' + str(statement.loc['start']['line']))
                loop4_dict[contract_name] = 1
                instance_counter += 1
                rule_list.append(file_name)

                tabs_to_insert = ' ' * statement.loc['start']['column']
                comment_line = '// ### PY_SOLOPT ### Found a rule violation of Loop Rule 4:\n'
                comment_line2 = '// TODO: Replace alias \'' + var_name + '\' by the variable \'' + loop_var_name + \
                                '\' and remove the declaration in order to save gas.\n'
                file_content.insert(statement.loc['start']['line'] - 1 + additional_lines,
                                    tabs_to_insert + comment_line2)
                file_content.insert(statement.loc['start']['line'] - 1 + additional_lines,
                                    tabs_to_insert + comment_line)


def var_is_reset(loop_statements, var_statement, var_name):
    hit = False
    for statement in loop_statements:
        if not hit:
            if statement == var_statement:
                hit = True
            else:
                continue
        else:
            if statement_contains_var(statement, var_name):
                return True
    return False


def statement_contains_var(statement, var_name):
    if isinstance(statement, str):
        # would result in an AttributeError when there is no statement type. example: 'throw;' or 'break;'
        return False
    if statement.type == 'IfStatement':
        if statement.TrueBody:
            if statement.FalseBody is not None:
                return statement_contains_var(statement.TrueBody, var_name) or statement_contains_var(
                    statement.FalseBody, var_name)
            else:
                return statement_contains_var(statement.TrueBody, var_name)
    elif statement.type == 'Block':
        for block_statement in statement.statements:
            if statement_contains_var(block_statement, var_name):
                return True
    elif statement.type == 'ForStatement' or statement.type == 'WhileStatement' or statement.type == 'DoWhileStatement':
        if statement.body is not None:
            return statement_contains_var(statement.body, var_name)
    elif statement.type == 'ExpressionStatement':
        return expression_contains_var(statement.expression, var_name)
    return False


def expression_contains_var(expression, var_name):
    if expression.type == 'BinaryOperation' \
            and (expression.operator == '=' or expression.operator == '+=' or expression.operator == '-='):
        left_expr = expression.left
        return expression_contains_var(left_expr, var_name)
    elif expression.type == 'UnaryOperation':
        return expression_contains_var(expression.subExpression, var_name)
    elif expression.type == 'Identifier' and expression.name == var_name:
        return True
    return False


def get_instance_counter():
    global instance_counter
    return instance_counter


def get_additional_lines():
    global additional_lines
    return additional_lines

def loop4_dict_counter():
    global loop4_dict
    loop4_count = 0
    for item in loop4_dict.keys():
        if loop4_dict[item]== 1 :
            loop4_count += 1
    return loop4_count