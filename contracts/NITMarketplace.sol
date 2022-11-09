// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract NITMarketplace is Context, ERC165, IERC721, IERC721Metadata, Ownable {

    string public name;
    string public symbol;
    mapping(address => uint) private balances;
    mapping(uint => address) private owners;
    mapping(uint => address) private tokenApprovals;
    mapping(address => mapping(address => bool)) private operatorApprovals;
    using Address for address;
    using Strings for uint;
    string private baseURI_;

    constructor(string memory _name, string memory _symbol, string memory _baseURIString) {
        name = _name;
        symbol = _symbol;
        baseURI_ = _baseURIString;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override (ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC721Metadata).interfaceId || super.supportsInterface(interfaceId);
    }

    function tokenURI(uint _tokenId) external view virtual override returns (string memory) {
        _requireMinted(_tokenId);
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, _tokenId.toString())) : "";
    }

    function balanceOf(address _owner) external view returns (uint) {
        return balances[_owner];
    }

    function ownerOf(uint _tokenId) external view returns (address) {
        return owners[_tokenId];
    }

    function safeTransferFrom(address _from, address _to, uint _tokenId) external virtual override {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(address _from, address _to, uint _tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "Caller is not token owner or approved");
        _safeTransfer(_from, _to, _tokenId, _data);
    }

    function transferFrom(address _from, address _to, uint _tokenId) external {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "Caller is not token owner or approved");
        _transfer(_from, _to, _tokenId);
    }

    function approve(address _to, uint _tokenId) external {
        address _owner = _ownerOf(_tokenId);
        require(_to != _msgSender(), "approval to current owner");

        require(
            _msgSender() == _owner || isApprovedForAll(_owner, _msgSender()), "approve caller is not token owner or approved for all"
        );
        _approve(_to, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        _setApprovalForAll(_msgSender(), _operator, _approved);
    }

    function getApproved(uint _tokenId) public view returns (address) {
        return tokenApprovals[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return operatorApprovals[_owner][_operator];
    }

    function safeMint(address _to, uint _tokenId) external onlyOwner() {
        _safeMint(_to, _tokenId, "");
    } 

    function safeBurn(uint _tokenId) external {
        _burn(_tokenId);
    }

    function _burn(uint _tokenId) internal {
        address _owner = _ownerOf(_tokenId);
        require(_owner == _msgSender(), "Not the owner of token");
        _beforeTokenTransfer(_owner, address(0), _tokenId, 1);
        delete tokenApprovals[_tokenId];
        unchecked {
            balances[_owner] -= 1;
        }
        delete owners[_tokenId];
        emit Transfer(_owner, address(0), _tokenId);
        _afterTokenTransfer(_owner, address(0), _tokenId, 1);
    }

    function _safeMint(address _to, uint _tokenId, bytes memory _data) internal {
        _mint(_to, _tokenId);
        require(_checkOnERC721Received(address(0), _to, _tokenId, _data), "Transfer to non ERC721Receiver implementer");
    }

    function _mint(address _to, uint _tokenId) internal {
        require(_to != address(0), "Cannot mint to address 0");
        require(!_exists(_tokenId), "Token already minted");

        _beforeTokenTransfer(address(0), _to, _tokenId, 1);
        require(!_exists(_tokenId), "Token already minted");
        
        unchecked {
            balances[_to] += 1;
        }
        owners[_tokenId] = _to;
        emit Transfer(address(0), _to, _tokenId);

        _afterTokenTransfer(address(0), _to, _tokenId, 1);
    }

    function _requireMinted(uint _tokenId) internal view {
        require(_exists(_tokenId), "Invalid token ID");
    }

    function _exists(uint _tokenId) internal view returns (bool) {
        return _ownerOf(_tokenId) != address(0);
    }

    function _ownerOf(uint _tokenId) internal view returns (address) {
        return owners[_tokenId];
    }

    function _baseURI() internal view returns (string memory)  {
        return baseURI_;
    }

    function _isApprovedOrOwner(address _spender, uint _tokenId) internal view returns (bool) {
        address owner = _ownerOf(_tokenId);
        return (_spender == _ownerOf(_tokenId) || isApprovedForAll(owner, _spender) || getApproved(_tokenId) == _spender);
    }

    function _safeTransfer(address _from, address _to, uint _tokenId, bytes memory _data) internal {
        _transfer(_from, _to, _tokenId);
        require(_checkOnERC721Received(_from, _to, _tokenId, _data), "transfer to non ERC721Receiver implementer");
    }

    function _transfer(address _from, address _to, uint _tokenId) internal {
        require(_ownerOf(_tokenId) == _from, "transferFrom incorrect owner");
        require(_to != address(0), "Cannot transfer to 0 address");

        _beforeTokenTransfer(_from, _to, _tokenId, 1);

        require(_ownerOf(_tokenId) == _from, "not the owner");
        delete tokenApprovals[_tokenId];

        unchecked {
            balances[_from] -= 1;
            balances[_to] += 1;
        }
        owners[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);

        _afterTokenTransfer(_from, _to, _tokenId, 1);
    }

    function _beforeTokenTransfer(address _from, address _to, uint, uint256 _batchSize) internal {
        if(_batchSize > 1) {
            if(_from != address(0)) {
                balances[_from] -= _batchSize;
            }

            if(_to != address(0)) {
                balances[_to] += _batchSize;
            }
        }
    }

    function _afterTokenTransfer(address _from, address _to, uint _tokenId, uint _batchSize) internal {

    }

    function _checkOnERC721Received(address _from, address _to, uint _tokenId, bytes memory _data) internal returns (bool) {
        if(_to.isContract()) {
            try IERC721Receiver(_to).onERC721Received(_msgSender(), _from, _tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if(reason.length == 0) {
                    revert("Transfer to non ERERC721Receiver implementer");
                }
                else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _approve(address _to, uint _tokenId) internal {
        tokenApprovals[_tokenId] = _to;
        emit Approval(_ownerOf(_tokenId), _to, _tokenId);
    }

    function _setApprovalForAll(address _owner, address _operator, bool _approved) internal {
        require(_owner != _operator, "Owner cannot approve to him self");
        operatorApprovals[_owner][_operator] = _approved;
        emit ApprovalForAll(_owner, _operator, _approved);
    }
}