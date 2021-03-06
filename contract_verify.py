import sys
import os
import re

# PATH your SymDiff compiled
symdiff = 'mono ~/symdiff/Sources/SymDiff/bin/x86/Debug/SymDiff.exe'

# After installed .NET, just use the 'dotnet'
dotnet = 'dotnet' 

# PATH your VeriSol compiled
verisol = '~/verisol/bin/Debug/VeriSol.dll'

# use .NET framework/Veriol compile the smart contract to BOOGIE file
def compile(filename, bpl):
    compile_cmd = '{dotnet_cmd} {verisol_loc} {file} C /noChk /noInlineAttrs /removeScopeInVarName /omitSourceLineInfo /omitDataValuesInTrace /omitUnsignedSemantics /omitAxioms /omitHarness'.format(dotnet_cmd = dotnet, verisol_loc = verisol, file=filename)
    print(compile_cmd)
    os.system(compile_cmd)
    os.system('cp __SolToBoogieTest_out.bpl {b_name}'.format(b_name=bpl))

def clean():
    os.system('rm *.bpl')
    os.system('rm _v1_v2.config')
    os.system('rm C1C2.log')

# check the difference of two BOOGIE FILE
def check_eq(file1, file2):
    res = False
    print('File1: ', file1)
    print('File2: ', file2)
    
    print('Step1: compiling contracts...')
    compile(file1, 'C1.bpl')
    compile(file2, 'C2.bpl')

# use SymDiff to check the equality of origin and optimized smart contracts
    print('Step2: verifying contracts...')
    
    extract_loop_cmd = '{symdiff_cmd} -extractLoops C1.bpl _v1.bpl'.format(symdiff_cmd = symdiff)
    os.system(extract_loop_cmd)
    
    extract_loop_cmd2 = '{symdiff_cmd} -extractLoops C2.bpl _v2.bpl'.format(symdiff_cmd = symdiff)
    os.system(extract_loop_cmd2)
    
    infer_cmd = '{symdiff_cmd} -inferConfig _v1.bpl _v2.bpl > _v1_v2.config'.format(symdiff_cmd = symdiff)
    os.system(infer_cmd)
    
    allInOne_cmd = '{symdiff_cmd} -allInOne  _v1.bpl _v2.bpl _v1_v2.config -usemutual -checkEquivWithDependencies -freeContracts -checkEquivForRoots -main:foo_C >> C1C2.log'.format(symdiff_cmd = symdiff)
    os.system(allInOne_cmd)

# get the result of verification from C1C2.log
    lastline = ''
    with open('C1C2.log') as f:
        data = f.readlines()
        lastline = data[-1]

# nums: the flag of equalalent( 0:equal ; 1:NOT equal)
    nums = re.findall(r'\d+', lastline)
    
    if nums[1] == '0':
        print('PASS: Two programs are equivalent!')
        res = True
    else:
        print('FAIL: Two programs are NOT equivalent!')
        res = False

    # Clean up 
    clean()
    return res