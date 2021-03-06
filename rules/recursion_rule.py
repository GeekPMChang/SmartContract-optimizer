# Classification Rule

#################################################
#   Procedure rule 4: Transformations on        #
#   Recursive Procedures                        #
#   -----------------------------------------   #
#   Iterative algorithms should always be       #
#   preferred to recursive ones.                #
#################################################

#################################################
#   过程规则 4: 递归调用转为迭代                    #
#   Recursive Procedures                        #
#   -----------------------------------------   #
#   迭代算法通常提供比递归算法更便宜的调用             #
#   因为需要修改的变量数量更少，需要检查的条件也更少     #
#   因此，迭代算法应始终优于递归算法。                #
#################################################

from glob import glob


additional_lines = 0
instance_counter = 0
recursion_dict = {}


def check_rule(added_lines, file_content, function_statements, contract_name,function_key, function_args, function_location, rule_list, file_name):
    global additional_lines, instance_counter
    global recursion_dict
    additional_lines = added_lines

    if function_key is None:
        # constructor
        return additional_lines

    for statement in function_statements:
        if statement_contains_function_call(statement, function_key, function_args):
            add_comment_above(file_content, function_location)
            print('### Applied recursion rule at '+contract_name+'--'+function_key+': line: ' + str(function_location['start']['line']))
            rule_list.append(file_name)
            recursion_dict[contract_name] = 1
            instance_counter += 1
            return additional_lines
    return additional_lines


def statement_contains_function_call(statement, function_key, function_args):
    if statement is None or isinstance(statement, str): # happens when there is only a ';'
        return False
    if statement.type == 'IfStatement':
        # check condition
        if statement.TrueBody is not None:
            # check true body
            if statement_contains_function_call(statement.TrueBody, function_key, function_args):
                return True
        if statement.FalseBody is not None:
            # check false body
            if statement_contains_function_call(statement.FalseBody, function_key, function_args):
                return True
    elif statement.type == 'VariableDeclarationStatement':
        if statement.initialValue:
            if statement_contains_function_call(statement.initialValue, function_key, function_args):
                return True
    elif statement.type == 'BinaryOperation':
        # check left
        if statement_contains_function_call(statement.left, function_key, function_args):
            return True
        # check right
        if statement_contains_function_call(statement.right, function_key, function_args):
            return True
    elif statement.type == 'ForStatement':
        if statement_contains_function_call(statement.body, function_key, function_args):
            return True
    elif statement.type == 'Block':
        for block_statement in statement.statements:
            if statement_contains_function_call(block_statement, function_key, function_args):
                return True
    elif statement.type == 'FunctionCall':
        try:
            if statement.expression.name == function_key and len(statement.arguments) == len(function_args):
                # TODO: check type match
                return True
        except KeyError:
            return False
    return False


def add_comment_above(file_content, function_location):
    global additional_lines
    function_line = function_location['start']['line'] - 1 + additional_lines
    tabs_to_insert = ' ' * function_location['start']['column']
    new_line = '// ############ PY_SOLOPT: Found a POSSIBLE instance of a recursive procedure. ' \
               'Please verify.   ############\n'
    new_line2 = '// ############ PY_SOLOPT: If this is the case, remove recursion in order to ' \
                'decrease gas cost. ############\n'
    file_content.insert(function_line, tabs_to_insert + new_line2)
    file_content.insert(function_line, tabs_to_insert + new_line)
    additional_lines += 2


def statement_contains_function_key(file_content, statement, function_key):
    start_line = statement.loc['start']['line'] - 1 + additional_lines
    end_line = statement.loc['end']['line'] + additional_lines

    for line in range(start_line, end_line):
        content_line = file_content[line]
        if function_key in content_line:
            return True


def get_instance_counter():
    global instance_counter
    return instance_counter


def get_additional_lines():
    global additional_lines
    return additional_lines

def recursion_dict_counter():
    global recursion_dict
    recursion_count = 0
    for item in recursion_dict.keys():
        if recursion_dict[item]== 1 :
            recursion_count += 1
    return recursion_count