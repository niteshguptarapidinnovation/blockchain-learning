// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract NITERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI, Ownable {

    using Address for address;

    mapping(uint => mapping(address=> uint)) private balances;
    mapping(address => mapping(address => bool)) private operatorApprovals;
    string private uri_;

    constructor(string memory _uri) {
        uri_ = _uri;
    }

    function uri(uint _id) external view returns (string memory) {
        return "";
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns(bool) {
        return interfaceId == type(IERC1155).interfaceId || interfaceId == type(IERC1155MetadataURI).interfaceId || super.supportsInterface(interfaceId);
    }

    function balanceOf(address _account, uint _id) external view returns (uint) {

    }

    function balanceOfBatch(address[] calldata accounts, uint[] calldata ids) external view returns (uint[] memory) {

    }

    function setApprovalForAll(address _operator, address _approved) external {

    }

    function isApprovedForAll(address _account, address _operator) external view returns (bool) {

    }

    function safeTransferFrom(address _from, address _to, uint _id, uint _amount, bytes calldata data) external {

    }

    function safeBatchTransferFrom(address _from, address _to, uint[] calldata ids, uint[] calldata amounts,bytes calldata data) external {

    }

}