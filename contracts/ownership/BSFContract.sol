// SPDX-License-Identifier: MIT
pragma solidity >=0.4.24;

import "../../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

import "./BSFComptroller/IBSFComptroller.sol";
import "./BSF20/IBSF20.sol";

abstract contract BSFContract is Ownable {

    string internal _key;
    string internal _bsf_comptroller = "bsf.comptroller";
    string internal _bsf_contract = "bsf.contract";
    string internal _bsf_token = "bsf.token";

    /**
    * @dev Operational status of the contract.
    */
    bool internal _operational;

    IBSFComptroller internal _comptroller;
    IBSF20 internal _token;

    event ComptrollerChanged(address newAddress, address deployer);

    constructor(address comptroller_, string key_) {
        _operational = true;
        _comptroller = IBSFComptroller(comptroller_);
        _key = key_;
    }

    modifier authorized() {
        require(_comptroller.access(_key, msg.sender), "BSF Contract access required.");
        _;
    }

    /**
    * @dev Modifier that requires the "_operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    */
    modifier requireOperational() 
    {
        require(_operational, "Contract is not currently operational.");  
        _;
    }

    modifier requireValidString(string memory value){
        bytes memory temp = bytes(value);
        require(temp.length > 0, "'value' must be a valid string.");
        _;
    }

    modifier requireValidAddress(address account){
        require(account != address(0), "'account' cannot be equal to burn address.");
        _;
    }

    function changeComptroller(address new_) external onlyOwner requireValidAddress(new_) returns(bool success) {
        _comptroller = IBSFComptroller(new_);
        emit ComptrollerChanged(new_, msg.sender);
        success = true;
    }

    function operational() 
                            external 
                            view 
                            returns(bool) 
    {
        return _operational;  // Modify to call data contract's status
    }

    function changeOperational(bool status) external onlyOwner returns(bool success){
        _operational = status;
        return true;
    }

    function _getContractAddress(string key) internal returns(bool enabled, address deployed) {
        (, bool e, address d) = _comptroller.getContract(key);
        enabled = e;
        deployed = d;
    }

    function _setToken(address __token) internal returns(bool updated){
        _token = IBSF20(__token);
        updated = true;
    }

    function setToken(address __token) external onlyOwner requireValidAddress(__token) returns(bool updated){
        return _setToken(__token);
    }
}