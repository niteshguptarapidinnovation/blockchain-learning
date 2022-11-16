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

    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts,bytes calldata _data) external {
        require(_from == _msgSender() || isApprovedForAll(_from, _msgSender()), "caller is not token owner or approved");
        _safeBatchTransferFrom(_from, _to, _ids,_amounts, _data);
    }

    function _mint(address _to, uint _id, uint _amount, bytes memory _data) internal {
        require(_to != address(0), "mint to the zero address");
        address _operator = _msgSender();
        uint[] memory _ids = _asSingletonArray(_id);
        uint[] memory _amounts = _asSingletonArray(_amount);

        _beforeTokenTransfer(_operator, address(0), _to, _ids, _amounts, _data);
        balances[_id][_to] += _amount;
        emit TransferSingle(_operator, address(0), _to, _id, _amount);
        _afterTokenTransfer(_operator, address(0), _to, _ids, _amounts, _data);
        _doSafeTransferAcceptanceCheck(_operator, address(0), _to, _id, _amount, _data); 
    }

    function _mintBatch(address _to, uint[] memory _ids, uint[] memory _amounts, bytes memory _data) internal {
        require(_to != address(0), "Mint to 0 address");
        require(_ids.length == _amounts.length, "ids and amounts length mismatch");

        address _operator = _msgSender();
        _beforeTokenTransfer(_operator, address(0), _to, _ids, _amounts, _data);

        for(uint i = 0; i < _ids.length; i++) {
            balances[_ids[i]][_to] += _amounts[i];
        }
        emit TransferBatch(_operator, address(0), _to, _ids, _amounts);
        _afterTokenTransfer(_operator, address(0), _to, _ids, _amounts, _data);
        _doSafeBatchTransferAcceptanceCheck(_operator, address(0), _to, _ids, _amounts, _data);
    }

    function _burn(address _from, uint _id, uint _amount) internal {
        require(_from != address(0), "burn from the zero address");
        address _operator = _msgSender();
        uint[] memory _ids = _asSingletonArray(_id);
        uint[] memory _amounts = _asSingletonArray(_amount);

        _beforeTokenTransfer(_operator, _from, address(0), _ids, _amounts, "");
        uint _fromBalance = balances[_id][_from];
        require(_fromBalance >= _amount, "burn amount exceeds balance");
        unchecked {
            balances[_id][_from] = _fromBalance - _amount;
        }
        emit TransferSingle(_operator, _from, address(0), _id, _amount);
        _afterTokenTransfer(_operator, _from, address(0), _ids, _amounts, "");
    }


    function _burnBatch(address _from, uint[] memory _ids, uint[] memory _amounts) internal {
        require(_ids.length == _amounts.length, "ids and amounts length mismatch");
        require(_from != address(0), "Cannot burn from 0 address");

        address _operator = _msgSender();
        _beforeTokenTransfer(_operator, _from, address(0), _ids, _amounts, "");
        for(uint i = 0; i < _ids.length; i++) {

            uint _id = _ids[i];
            uint _amount = _amounts[i];

            uint _fromBalance = balances[_id][_from];
            require(_fromBalance >= _amount, "burn amount exceeds balance");
            unchecked {
                balances[_id][_from] = _fromBalance - _amount;
            }
        }
        emit TransferBatch(_operator, _from, address(0), _ids, _amounts);
    }

    function _setURI(string memory _uri) internal virtual {
        uri_ = _uri;
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
        uint _fromBalance = balances[_id][_from];
        require(_fromBalance >= _amount, "insufficient balance for transfer");
        unchecked {
            balances[_id][_from] = _fromBalance - _amount;
        }
        balances[_id][_to] += _amount;
        emit TransferSingle(_operator, _from, _to, _id, _amount);

        _afterTokenTransfer(_operator, _from, _to, _ids, _amounts, _data);
        _doSafeTransferAcceptanceCheck(_operator, _from, _to, _id, _amount, _data);
    }



    function _asSingletonArray(uint _element) private pure returns(uint[] memory) {
        uint[] memory array = new uint[](1);
        array[0] = _element;
        return array;
    }

    function _beforeTokenTransfer(address _operator, address _from, address _to, uint[] memory _ids, uint[] memory _amounts, bytes memory _data) internal virtual {
    }

    function _afterTokenTransfer(address _operator, address _from, address _to, uint[] memory _ids, uint[] memory _amounts, bytes memory _data) internal {

    }

    function _doSafeTransferAcceptanceCheck(address _operator, address _from, address _to, uint _id, uint _amount, bytes memory _data) internal {
        if(_to.isContract()) {
            try IERC1155Receiver(_to).onERC1155Received(_operator, _from, _id, _amount, _data) returns (bytes4 response) {
                if(response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("IERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("transfer to non-ERC1155Receiver implementer");
            }
        }

    }

    function _safeBatchTransferFrom(address _from, address _to, uint[] memory _ids, uint[] memory _amounts, bytes memory _data) internal {
        require(_ids.length == _amounts.length, "ids and amounts length mismatch");
        require(_to != address(0), "transfer to the zero address");

        address _operator = _msgSender();
        _beforeTokenTransfer(_operator, _from, _to, _ids, _amounts, _data);
        
        for(uint i = 0; i < _ids.length; i++) {
            uint _id = _ids[i];
            uint _amount = _amounts[i];

            uint _fromBalance = balances[_id][_from];
            require(_fromBalance >= _amount, "insufficient balance for transfer");
            unchecked {
                balances[_id][_from] = _fromBalance - _amount;
            }
            balances[_id][_to] += _amount;
        }

        emit TransferBatch(_operator, _from, _to, _ids, _amounts);
        _afterTokenTransfer(_operator, _from, _to, _ids, _amounts, _data);
        _doSafeBatchTransferAcceptanceCheck(_operator, _from, _to, _ids, _amounts, _data);
    }

    function _doSafeBatchTransferAcceptanceCheck(address _operator, address _from, address _to, uint[] memory _ids, uint[] memory _amounts, bytes memory _data) internal {
        if(_to.isContract()) {
            try IERC1155Receiver(_to).onERC1155BatchReceived(_operator, _from, _ids, _amounts, _data) returns (bytes4 _response) {
                if(_response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory _reason) {
                revert(_reason);
            } catch {
                revert("transfer to non-ERC1155Receiver implementer");
            }
        }
    }

}