from unicodedata import name


optimized_types=['LOGIC_RULE_1', 'LOGIC_RULE_2', 'LOOP_RULE_1', 'LOOP_RULE_2', 'LOOP_RULE_3', 'LOOP_RULE_4', 'LOOP_RULE_5', 'LOOP_RULE_6', 'RECURSION_RULE', 'PACKING_RULE']

f = open("./output/optimized_list.txt",encoding='utf8')

f.readline()

class Optimized_file :
    
    def __init__(self,name):
         self.name = name
         self.rulelist = []
    def find_rule_exist(self,optimized_rule):
        flag = False
        for each_rule in self.rulelist:
            if each_rule == optimized_rule:
                flag = True
        return flag
    def add_optimized_rule(self,optimized_rule):
        if self.find_rule_exist(optimized_rule) == False:
            self.rulelist.append(optimized_rule)
    def get_name(self):
        return self.name
    def output(self,output_f):
        output_f.writelines(self.name+'\n')
        for each_rule in self.rulelist:
            output_f.writelines('\t'+each_rule+'\n')
        output_f.writelines('\n')
    
optimized_file_list = []

def find_file_name(file_name):
    flag = False
    for i in range(0,len(optimized_file_list)):
        if optimized_file_list[i].get_name() == file_name:
            flag = True
            return i
    if flag == False:
        return -1   

for i in range(0,10):
    lineword = f.readline()
    file_list = lineword[lineword.find(':')+1:].replace(' ', '').split(';')
    for each_file in file_list:
        if each_file == '\n':
            pass
        else:
            if find_file_name(each_file) == -1:
                newfile = Optimized_file(each_file)
                newfile.add_optimized_rule(optimized_types[i])
                optimized_file_list.append(newfile)
            else:
                optimized_file_list[find_file_name(each_file)].add_optimized_rule(optimized_types[i])

output_file = open('./output/optimized_file_list.txt', 'w', encoding='utf8')
output_file.writelines('Optimized Filelist: \n')
for eachfile in optimized_file_list:
    eachfile.output(output_file)
    
output_file.close()