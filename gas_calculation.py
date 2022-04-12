import sys
import time
import pprint

from web3.providers.eth_tester import EthereumTesterProvider
from web3 import Web3
from eth_tester import PyEVMBackend
import solcx

# calculate gasUsed in smart contract deployment --completed
# calculate gasUsed in fuction call 
def compile_source_file(contract_source):

    # get the right description of version
    version_str=contract_source[contract_source.find('pragma solidity')+16:contract_source.find(';')].replace(' ', '')
    
    # get the right version of solcx
    # pattern recognition of versions
    '''
    pattern1: pragma solidity ^0.4.23 ;
    pattern2: pragma solidity 0.5.16 ;
    pattern3: pragma solidity >=0.4.21 ;
    pattern4: pragma solidity <=0.6.0 ;
    pattern5: pragma solidity >=0.4.21 <0.6.0 ;
    '''
    
    if version_str[0]=='^' :
        appropriate_version=version_str[1:]
    elif version_str[0]== '0' :
        appropriate_version=version_str
    elif version_str[0:2]=='<=' :
        appropriate_version=version_str[2:]
    elif version_str[0:2]=='>=' :
        if version_str.find('<') == -1 :
            appropriate_version=version_str[2:]
        else :
            appropriate_version=version_str[2:version_str.find('<')]
    
    print(appropriate_version)

    # define the version of solc 
    solcx.install_solc(version=appropriate_version)
    solcx.set_solc_version(appropriate_version)
    
    return solcx.compile_source(contract_source)


def deploy_contract(w3, contract_interface):
    tx_hash = w3.eth.contract(
        abi=contract_interface['abi'],
        bytecode=contract_interface['bin']).constructor().transact()

    inforDeploy = w3.eth.get_transaction_receipt(tx_hash)
    return inforDeploy

def calculate_gasUsed_transaction(file_path) :
    with open(file_path, 'r' ) as f:
        contract_source=f.read()
     
    w3 = Web3(EthereumTesterProvider(PyEVMBackend()))

    compiled_sol = compile_source_file(contract_source)

    contract_id, contract_interface = compiled_sol.popitem()

    # information of deployment
    InforDeploy = deploy_contract(w3, contract_interface)
    '''
    return value of <w3.eth.get_transaction_receipt>
    {
        'blockHash' ;
        'blockNumber' ;
        'contractAddress' ;
        'cumulativeGasUsed' ;
        'effectiveGasPrice' ;
        'from' ;
        'gasUsed' ;
        'logs' ;
        'state_root' ;
        'status' ;
        'to';
        'transactionHash' ;
        'transactionIndex'
    }
    '''
    gasUsed_deployment=InforDeploy['gasUsed']
    print(f'Gas estimate to Deployment: {gasUsed_deployment}')
    
    address=InforDeploy['contractAddress']
    store_var_contract = w3.eth.contract(address=address, abi=contract_interface["abi"])

    gasUsed_transaction = store_var_contract.functions.setVar(255).estimateGas()
    print(f'Gas estimate to transact with setVar: {gasUsed_transaction}')

    

    
def calculate_gasUsed_deployment(contract_source) :
    w3 = Web3(EthereumTesterProvider(PyEVMBackend()))

    compiled_sol = compile_source_file(contract_source)

    contract_id, contract_interface = compiled_sol.popitem()

    InforDeploy = deploy_contract(w3, contract_interface)

    gasUsed = InforDeploy['gasUsed']

    return gasUsed

    '''
    return value of <w3.eth.get_transaction_receipt>
    {
        'blockHash' ;
        'blockNumber' ;
        'contractAddress' ;
        'cumulativeGasUsed' ;
        'effectiveGasPrice' ;
        'from' ;
        'gasUsed' ;
        'logs' ;
        'state_root' ;
        'status' ;
        'to';
        'transactionHash' ;
        'transactionIndex'
    }
    '''
    
calculate_gasUsed_transaction()