pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;



contract ValidatorRegistry{
    address[] ValidatedValidator;
    
    struct Validator {
        string name;
        bool authorized;
        bool isElected;
        uint Authoritylevel;
        uint arrayIndex;
    }
    
    mapping(address => Validator) ValidatorInfo;
    mapping(address => bool) isAddressValidatorMapping;
    mapping(address => uint) ValidatedValidatorIndex;
    uint ValidatorCount;
    
    
    mapping(address => bool) isValidatorProposed;
    mapping(address => uint) ValidatorProposalIndex;
    address[] pendingProposed;
    uint pendingProposedCount;
    
        mapping(address => bool) isValidatorRemovalProposed;
        mapping(address => uint) ValidatorRemovalProposalIndex;
        address[] pendingRemovalProposed;
        uint pendingRemovalProposedCount;
    
    
    
    function ProposeValidator(address _validatorAddress, string memory _validatorName, bool _isElected)public {
        if(!isAddressValidatorMapping[_validatorAddress] == true || !isValidatorProposed[_validatorAddress] == true){
            ValidatorProposal _proposal = new ValidatorProposal(_validatorAddress,_validatorName,_isElected);
            isValidatorProposed[_validatorAddress] = true;
            address _proposal_address = _proposal.getContractAddr();
            pendingProposed.push(_proposal_address);
            ValidatorProposalIndex[_validatorAddress] = pendingProposedCount;
            pendingProposedCount++;
        }else{
            revert("yeah no, the address is already a Validated address or is already proposed for Validation");
        }
        
    }
    function VoteValidator(bool _vote, address _validatorAddress) public {
        address _proposal_address  = pendingProposed[ValidatorProposalIndex[_validatorAddress]];
        ValidatorProposal _proposal = ValidatorProposal(_proposal_address);
        _proposal.vote(_vote, msg.sender);
    }
    function ProposeRemoval(address _validatorAddress, string memory _validatorName) public{
                if(isAddressValidatorMapping[_validatorAddress] == false || !isValidatorRemovalProposed[_validatorAddress] == true){
            RemovalProposal _proposal = new RemovalProposal(_validatorAddress,_validatorName);
            isValidatorRemovalProposed[_validatorAddress] = true;
            address _proposal_address = _proposal.getContractAddr();
            pendingRemovalProposed.push(_proposal_address);
            ValidatorRemovalProposalIndex[_validatorAddress] = pendingRemovalProposedCount;
            pendingRemovalProposedCount++;
        }else{
            revert("yeah no, the address is NOT a Validated address oris already proposed for removal");
        }
        
    }
    function VoteRemoval(bool _vote, address _validatorAddress) public{
                address _proposal_address  = pendingRemovalProposed[ValidatorRemovalProposalIndex[_validatorAddress]];
                ValidatorProposal _proposal = ValidatorProposal(_proposal_address);
                _proposal.vote(_vote, msg.sender);
    }
    function ExecuteRemoval(address _validatorAddress) public onlyAfterMinTimeAndOnlyOnce(_validatorAddress){
            address _proposal_address  = pendingProposed[ValidatorProposalIndex[_validatorAddress]];
            RemovalProposal remove = RemovalProposal(_proposal_address);
            remove.finalize();
            ValidatedValidator[ValidatedValidatorIndex[_validatorAddress]] = 0x0000000000000000000000000000000000000000;
            delete ValidatorInfo[_validatorAddress];
            isAddressValidatorMapping[_validatorAddress] = false;
            isValidatorRemovalProposed[_validatorAddress] = false;
            pendingRemovalProposedCount--;
            delete pendingRemovalProposed[ValidatorProposalIndex[_validatorAddress]];
    }
    function ExecuteAddition(address _validatorAddress) public onlyAfterMinTimeAndOnlyOnce(_validatorAddress){ //add onlyOnce and only after Xtime
            address _proposal_address  = pendingProposed[ValidatorProposalIndex[_validatorAddress]];
            ValidatorProposal add = ValidatorProposal(_proposal_address);
            address _validatorAddr = add.getContractAddr();
            string memory _validatorName;
            bool _elected;
            uint _up;
            uint _down;
            (_validatorAddr,_validatorName,_elected,_up,_down) = add.getValidatorDetails();
            Validator memory valstruct;
            valstruct.name = _validatorName;
            valstruct.authorized = true;
            valstruct.Authoritylevel = 1;
            valstruct.arrayIndex = ValidatorCount;
           ValidatedValidator.push(_validatorAddr);
            ValidatorInfo[_validatorAddr] = valstruct;
            isAddressValidatorMapping[_validatorAddr] = true;
            ValidatedValidatorIndex[_validatorAddr] = ValidatorCount;
            ValidatorCount++;
           
    }
    function UpdateValidator(address _validatorAddr, string memory _validatorName, bool _isElected) public{
        uint _location = ValidatedValidatorIndex[_validatorAddr];
            Validator memory valstruct;
            valstruct.name = _validatorName;
            valstruct.authorized = true;
            valstruct.Authoritylevel = 1;
            valstruct.arrayIndex = _location;
           valstruct.isElected = _isElected;
            ValidatorInfo[_validatorAddr] = valstruct;
        
    }
    
    function isAddressValidator(address _validatorAddr) public view returns(bool){
        return isAddressValidatorMapping[_validatorAddr];
        
        
    }
    function getApprovedValidators()public view returns(address[] memory){
        return ValidatedValidator;
        
    }
    function getProposedValidators()public view returns(address[] memory){
        return pendingProposed;
        
    }
        function getProposedValidatorRemoval()public view returns(address[] memory){
        return pendingRemovalProposed;
        
    }
    function getApprovedValidatorInfo(address _validatorAddress)public view returns(address,string memory,bool,bool,uint,uint){
        Validator memory valstruct;
        valstruct = ValidatorInfo[_validatorAddress];
        return(_validatorAddress,valstruct.name,valstruct.authorized,valstruct.isElected,valstruct.Authoritylevel,valstruct.arrayIndex);
    }
    
        modifier onlyAfterMinTimeAndOnlyOnce(address _validatorAddress)
        {
            address ValidatorProposalContractAddress = pendingProposed[ValidatorProposalIndex[_validatorAddress]];
            ValidatorProposal proposal = ValidatorProposal(ValidatorProposalContractAddress);
            uint proposaltime = proposal.getPropositionTime();
        require(
            proposaltime + 86400 < now && !isAddressValidatorMapping[_validatorAddress] , // 1 Day
            "minimum time has not elapsed yet or the Validated Address isnt Approved."
            );
            _;
        }
    
}

contract ValidatorProposal{
        address _owner;
        address validatorAddress;
        string validatorName;
        bool isElected;

        
        uint approvals; 
        uint unapprovals;
        uint propositionTime;
        mapping(address => address) voted_addresses;
        
        
        constructor (address _validatorAddr,string memory _validatorName, bool _isElected) public{
            _owner = msg.sender;
            validatorAddress = _validatorAddr;
            validatorName =  _validatorName;
            isElected = _isElected;
            approvals = 0;
            unapprovals = 0;
            propositionTime = now; 
        }
        
        function getValidatorDetails() public view returns(address,string memory,bool,uint, uint){
            return (validatorAddress, validatorName, isElected, approvals ,unapprovals);
        }
            function getContractAddr() public view returns (address){
            address thisaddr = address(this);
            return thisaddr;
        }
        function getPropositionTime() public view returns(uint){
            return propositionTime;
        }
        
        function finalize() public onlyContract(msg.sender) onlyAfterMinTime{
            address payable destroyer = 0xB02FbF1986D308A7C4E6626D5a7673DC09646dfe;
            selfdestruct(destroyer);
        }
     
        
        
        function vote(bool _vote, address _voter) onlyContract(msg.sender) public{
         if(voted_addresses[_voter] == address(0x0000000000000000000000000000000000000000))
         {
         if(_vote){
             voted_addresses[_voter] = _voter;
             approvals++;
         }
         else{
             voted_addresses[_voter] = _voter;
             unapprovals++;
         }
         }
         else{
             revert("user already voted");
         }
         
        }
        
        modifier onlyContract(address _account)
        {
        require(
            msg.sender == _owner,
            "Sender not authorized."
            );
            _;
        }
        
        modifier onlyAfterMinTime()
        {
        require(
            propositionTime + 86400 < now , // 1 Day
            "minimum time has not elapsed yet."
            );
            _;
        }
        
        
}

contract RemovalProposal{
        address _owner;
        address validatorAddress;
        string validatorName;


        
        uint approvals; 
        uint unapprovals;
        uint propositionTime;
        mapping(address => address) voted_addresses;
        
        
        constructor (address _validatorAddr,string memory _validatorName) public{
            _owner = msg.sender;
            validatorAddress = _validatorAddr;
            validatorName =  _validatorName;
 
            approvals = 0;
            unapprovals = 0;
            propositionTime = now; 
        }
        
        function getPropositionDetails() public view returns(address,string memory,uint, uint){
            return (validatorAddress, validatorName, approvals,unapprovals);
        }
            function getContractAddr() public view returns (address){
            address thisaddr = address(this);
            return thisaddr;
        }
        
        function finalize() public onlyContract(msg.sender) onlyAfterMinTime{
            address payable destroyer = 0xB02FbF1986D308A7C4E6626D5a7673DC09646dfe;
            selfdestruct(destroyer);
        }
     
        
        
        function vote(bool _vote, address _voter) onlyContract(msg.sender) public{
         if(voted_addresses[_voter] == address(0x0000000000000000000000000000000000000000))
         {
         if(_vote){
             voted_addresses[_voter] = _voter;
             approvals++;
         }
         else{
             voted_addresses[_voter] = _voter;
             unapprovals++;
         }
         }
         else{
             revert("user already voted");
         }
         
        }
        
        modifier onlyContract(address _account)
        {
        require(
            msg.sender == _owner,
            "Sender not authorized."
            );
            _;
        }
        
        modifier onlyAfterMinTime()
        {
        require(
            propositionTime + 86400 < now , // 1 Day
            "minimum time has not elapsed yet."
            );
            _;
        }
        
        
}