// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// , ERC165, IERC1155, IERC1155MetadataURI, Ownable
contract NITERC1155 is Context, ERC165, IERC1155MetadataURI,  Ownable {

    using Address for address;

    mapping(uint256 => mapping(address=> uint256)) private balances;
    mapping(address => mapping(address => bool)) private operatorApprovals;
    string private uri_;

    constructor(string memory _uri) {
        uri_ = _uri;
    }

    function uri(uint256) external view returns (string memory) {
        return uri_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns(bool) {
        return interfaceId == type(IERC1155).interfaceId || interfaceId == type(IERC1155MetadataURI).interfaceId || super.supportsInterface(interfaceId);
    }

    function balanceOf(address _account, uint256 _id) public view returns (uint256) {
        require(_account != address(0), "Address 0 is not valid accounr");
        return balances[_id][_account];
    }

    function balanceOfBatch(address[] calldata _accounts, uint256[] calldata _ids) external view returns (uint256[] memory) {
        require(_accounts.length == _ids.length, "Accouns and ids length mismatched");
        uint[] memory batchBalance = new uint[](_accounts.length);
        for(uint i = 0; i < _accounts.length; i++) {
            batchBalance[i] = balanceOf(_accounts[i], _ids[i]);
        }
        return batchBalance;
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        _setApprovalForAll(_msgSender(), _operator, _approved);
    }

    function isApprovedForAll(address _account, address _operator) public view returns (bool) {
        return operatorApprovals[_account][_operator];
    }

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes calldata _data) external {
        require(_from == _msgSender() || isApprovedForAll(_from, _msgSender()), "Caller is not token owner or approved");
        _safeTransferFrom(_from, _to, _id, _amount, _data);
    }

    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata ids, uint256[] calldata amounts,bytes calldata data) external {

    }

    function _setApprovalForAll(address _owner, address _operator, bool _approved) internal {
        require(_owner != _operator, "Cannot set approval status for self");
        operatorApprovals[_owner][_operator] = _approved;
        emit ApprovalForAll(_owner, _operator, _approved);
    }

    function _safeTransferFrom(address _from, address _to, uint _id, uint _amount, bytes calldata _data) internal {
        require(_to != address(0), "Transfer to the 0 address");
        address _operator = _msgSender();
        uint[] memory _ids = _asSingletonArray(_id);
        uint[] memory _amounts = _asSingletonArray(_amount);

        _beforeTokenTransfer(_operator, _from, _to, _ids, _amounts, _data);

    }

    function _asSingletonArray(uint _element) private pure returns(uint[] memory) {
        uint[] memory array = new uint[](1);
        array[0] = _element;
        return array;
    }

    function _beforeTokenTransfer(address _operator, address _from, address _to, uint[] memory _ids, uint[] memory _amounts, bytes memory _data) internal virtual {

    }

}