pragma solidity ^0.8.0;

import "./IERC20FromScratch.sol";

contract ERC20FromScratch {
    string internal _name;
    string internal _symbol;
    mapping(address => uint256) internal _balances;
    /// `_approval[address_][spender]` returns how much `address_` allow `spender` to transfer out of `address_`'s
    /// account.
    mapping(address => mapping(address => uint256)) internal _approvals;
    address internal _deployer;
    address internal _zero = address(0);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor(string memory name_, string memory symbol_) {
        _deployer = msg.sender;
        _name = name_;
        _symbol = symbol_;
    }

    modifier ownerOnly() {
        require(msg.sender == _deployer, "Only contract deployer is allowed to do this action");
        _;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public pure returns (uint256) {
        // 30 mil * 10^18
        return 30_000_000_000_000_000_000_000_000;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return _balances[_owner];
    }

    function mint(address _to, uint256 _value) public ownerOnly {
        _balances[_to] = _value;
        emit Transfer(_zero, _to, _value);
    }

    function burn(address _to) public ownerOnly {
        uint256 prevBalance = _balances[_to];
        _balances[_to] = 0;
        emit Transfer(_to, _zero, prevBalance);
    }

    function burn(address _to, uint256 _value) public ownerOnly {
        uint256 prevBalance = _balances[_to];
        require(_value > prevBalance, "Unable to burn more than the current balance");
        _balances[_to] -= _value;
        emit Transfer(_to, _zero, prevBalance);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_value > 0, "Cannot transfer empty amount");

        uint256 fromBalance = _balances[msg.sender];
        uint256 toBalance = _balances[_to];

        uint256 newFromBalance = fromBalance - _value;
        uint256 newToBalance = toBalance + _value;

        require(newFromBalance >= 0, "Insufficient sender balance");

        _balances[msg.sender] = newFromBalance;
        _balances[_to] = newToBalance;

        emit Transfer(msg.sender, _to, _value);
        success = true;
    }

    /// Transfers `_value` amount of tokens from address `_from` to address `_to`, and must fire the `Transfer` event.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value > 0, "Cannot transfer empty amount");

        uint256 approvedValue = _approvals[_from][msg.sender];
        uint256 newApprovedValue = approvedValue - _value;
        require(newApprovedValue >= 0, "Cannot transfer more than allowed");

        uint256 fromBalance = _balances[_from];
        uint256 toBalance = _balances[_to];

        uint256 newFromBalance = fromBalance - _value;
        uint256 newToBalance = toBalance + _value;

        _balances[_from] = newFromBalance;
        _balances[_to] = newToBalance;
        _approvals[_from][_to] = newApprovedValue;

        emit Transfer(_from, _to, _value);
        success = true;
    }

    /// Allows `_spender` to withdraw from your account multiple times, up to the `_value` amount. If this function is
    /// called again it overwrites the current allowance with `_value`.
    function approve(address _spender, uint256 _value) public returns (bool success) {
        _approvals[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        success = true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        remaining = _approvals[_owner][_spender];
    }
}
