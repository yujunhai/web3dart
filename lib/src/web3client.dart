import 'dart:async';
// import 'dart:mirrors';
import 'dart:io' show Platform;
import 'package:http/http.dart';
import 'package:web3dart/src/contracts/abi.dart';
import 'package:web3dart/src/io/jsonrpc.dart';
import 'package:web3dart/src/io/rawtransaction.dart';
import 'package:web3dart/src/utils/amounts.dart';
import "package:web3dart/src/utils/numbers.dart" as numbers;
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/src/proto/proto_transaction.dart';
import 'package:web3dart/src/proto/transaction.dart';
import 'package:web3dart/src/proto/txinfo.dart';
import 'package:web3dart/src/proto/block.dart';

/// Class for sending requests over an HTTP JSON-RPC API endpoint to Ethereum
/// clients. This library won't use the accounts feature of clients to use them
/// to create transactions, you will instead have to obtain private keys of
/// accounts yourself.

class Web3Client {

	final BlockNum defaultBlock = BlockNum.current();
	final int _version = 0x10409;

	int Version() {
		return _version;
	}

	JsonRPC _jsonRpc;
	///Whether errors, handled or not, should be printed to the console.
	bool printErrors = false;

	Web3Client(String connectionUrl, Client _httpClient) {
		_jsonRpc = new JsonRPC(connectionUrl, _httpClient);
		String user_agent = "Dart/" + Platform.version + " (" + Platform.operatingSystemVersion + ") " + "web3dart/"+ (_version >> 16).toString() + "."+(_version >> 8 & 0xff).toString() +"."+ (_version & 0xff).toString();
		_jsonRpc.AddHeader({'user-agent': user_agent});
	}

	Future<dynamic> _makeRPCCall(String function, [List<dynamic> params]) async {
		try {
			var data = await _jsonRpc.call(function, params);
      if (data is Error || data is Exception)
				throw data;

			return data.result;
		} catch (e) {
			if (printErrors)
				print(e);

			rethrow;
		}
	}

	String _getBlockParam(BlockNum block) {
		return (block ?? defaultBlock).toBlockParam();
	}

	/// Returns the version of the client we're sending requests to.
	Future<String> getClientVersion() {
		return _makeRPCCall("web3_clientVersion");
	}

	/// Returns the id of the network the client is currently connected to.
	///
	/// In a non-private network, the network ids usually correspond to the
	/// following networks:
	/// 1: Ethereum Mainnet
	/// 2: Morden Testnet (deprecated)
	/// 3: Ropsten Testnet
	/// 4: Rinkeby Testnet
	/// 42: Kovan Testnet
	Future<int> getNetworkId() {
		return _makeRPCCall("net_version").then((s) => int.parse(s));
	}

	/// Returns true if the node is actively listening for network connections.
	Future<bool> isListeningForNetwork() {
		return _makeRPCCall("net_listening");
	}

	/// Returns the amount of Ethereum nodes currently connected to the client.
	Future<int> getPeerCount() {
		return _makeRPCCall("net_peerCount")
				.then((s) => numbers.hexToInt(s).toInt());
	}

	/// Returns the version of the Ethereum-protocol the client is using.
	Future<int> getEtherProtocolVersion() {
		return _makeRPCCall("eth_protocolVersion");
	}

	Future<BlockRaw> getBlockByHash(String hash) {

		return _makeRPCCall("eth_getBlockByHash", [hash, false])
				.then((s) {
			if (s == null) {
				return null;
			}

			return new BlockRaw.fromJson(s);
		});
	}

	Future<BlockRaw> getBlockByNumber(int blockNumber) {
		return _makeRPCCall("eth_getBlockByNumber", [numbers.toHex(blockNumber, include0x: true), false])
				.then((s) {
			if (s == null) {
				return null;
			}

			return new BlockRaw.fromJson(s);
		});
	}

	/// Returns an object indicating whether the node is currently synchronising
	/// with its network.
	///
	/// If so, progress information is returned via [SyncInformation].
	Future<SyncInformation> getSyncStatus() async {
		var data = await _makeRPCCall("eth_syncing");

		if (data is Map) {
			return new SyncInformation.
				_(data["startingBlock"], data["currentBlock"], data["highestBlock"]);
		} else
			return new SyncInformation._(null, null, null);
	}

	/// Returns true if the connected client is currently mining, false if not.
	Future<bool> isMining() {
		return _makeRPCCall("eth_mining");
	}

	/// Returns the amount of hashes per second the connected node is mining with.
	Future<int> getMiningHashrate() {
		return _makeRPCCall("eth_hashrate")
				.then((s) => numbers.hexToInt(s).toInt());
	}

	/// Returns the amount of Ether typically needed to pay for one unit of gas.
	///
	/// Although not strictly defined, this value will typically be a sensible
	/// amount to use in the public blockchain and
	Future<EtherAmount> getGasPrice() async {
		var data = await _makeRPCCall("eth_gasPrice");

		return EtherAmount.fromUnitAndValue(EtherUnit.wei, numbers.hexToInt(data));
	}

	/// Returns the number of the most recent block on the chain.
	Future<int> getBlockNumber() {
		return _makeRPCCall("eth_blockNumber")
				.then((s) => numbers.hexToInt(s).toInt());
	}

	/// Gets the balance of the account with the specified address.
	///
	/// This function allows specifying a custom block mined in the past to get
	/// historical data. By default, [BlockNum.current] will be used.
	Future<EtherAmount> getBalance(EthereumAddress address, {BlockNum atBlock}) {
		var blockParam = _getBlockParam(atBlock);

		return _makeRPCCall("eth_getBalance", [address.hex, blockParam]).then((data) {
			return EtherAmount.fromUnitAndValue(EtherUnit.wei, numbers.hexToInt(data));
		});
	}

	Future<TransactionResult> getTransactionsByBlockNumber(int blockNumber, int offset, int limit) {
		return _makeRPCCall("eth_getTransactionsByBlockNumber", [numbers.toHex(blockNumber, include0x: true), offset, limit]).then((data) {
			if (data == null) {
				return null;
			}

			var txs = List<TransactionRows>();
			if (data["datas"] != null) {
				for (var tx in data["datas"]) {
					txs.add(new TransactionRows.fromJson(tx));
				}
			}

			txs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

			return TransactionResult.New(data["total"], txs);
		});
	}

	Future<TransactionResult> getTransactionsByAddr(EthereumAddress address, TransactionType type, int offset, int limit) {
		int typeValue = 0xf;
		if (type == TransactionType.outlay) {
			typeValue = 0x1;
		} else if (type == TransactionType.income) {
			typeValue = 0x2;
		} else if (type == TransactionType.failed) {
			typeValue = 0x8;
		}
		return _makeRPCCall("personal_getTransactionsByAccount", [address.hex, typeValue, offset, limit]).then((data) {
			if (data == null) {
				return null;
			}

			var txs = List<TransactionRows>();
			for (var tx in data["datas"]) {
				// print(reflect(tx).type.reflectedType.toString());
				txs.add(new TransactionRows.fromJson(tx));
			}

			txs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

			return TransactionResult.New(data["total"], txs);
		});
	}

	Future<TransactionRaw> getTransaction(String hash) {
		return _makeRPCCall("eth_getTransactionByHash", [hash])
				.then((s) {
			if (s == null) {
				return null;
			}

			return new TransactionRaw.fromJson(s);
		});
	}

	///Fetch transaction info from web3 server
	///We offer 3 value of param queryType
	///QUERY_BY_ALL   1, this value means the method will query from transaction history
	///QUERY_BY_BLOCK  2, this value means the method will query from transaction history of specific block
	///QUERY_BY_USER	3, this value means the method will query from  transactions history of specific user
	///Here, we'll just use QUERY_BY_USER, params' meaning defers when query is different
	///
	///When queryType is QUERY_BY_USER
	///@indexKey holds user's address
	///@lastTxHash holds last transaction's hash of current page if we are heading for next page
	///or the first transaction's hash of current page if we are heading for previous page
	///@timestamp holds last transaction's timestamp of current page if we are heading for next page
	///or the first transaction's timestamp of current page if we are heading for previous page
	/// @curPageIndex is the index of page that we're visiting
	/// @pageCount acts as limit
	/// @searchFlag is the direction we are turning, first,next and so on
	/*
Future<TransactionInfoRes> getTransactionInfo(int queryType,String indexKey, String lastTxHash, int timestamp, int curPageIndex, int pageCount, int searchFlag) {
		return _makeRPCCall("eth_getTransactionInfoList", [queryType, indexKey, lastTxHash, timestamp, curPageIndex, pageCount, searchFlag])
				.then((s){
				if (s == null) {
					return null;
				}

				//print(s);
				var pageInfo = new PageInfo.fromJson(s['pInfo']);
				if (s['transactions'] == null) {
						return new TransactionInfoRes.New(pageInfo, List<TransactionInfo>());
				} else {
						var txInfo = (s['transactions'] as List).map((i) =>
								TransactionInfo.fromJson(i)).toList();

						return new TransactionInfoRes.New(pageInfo, txInfo);
				}
		});
}*/

	///TXTYPE 1 from
	///TXTYPE 2 to
	///TXTYPE 3 all
Future<TransactionInfoRes> getUserTransactionInfo(int txType, String address, String lastTransHash, int timestamp, int curPageIndex, int pageCount, int searchFlag) {
		return _makeRPCCall("eth_getUserTransactionInfoList", [address, lastTransHash, timestamp, txType, curPageIndex, pageCount, searchFlag])
				.then((s){
				var pageInfo = new PageInfo.fromJson(s['pInfo']);
				if (s['transactions'] == null) {
						return new TransactionInfoRes.New(pageInfo, List<TransactionInfo>());
				} else {
						var txInfo = (s['transactions'] as List).map((i) =>
						TransactionInfo.fromJson(i)).toList();

						return new TransactionInfoRes.New(pageInfo, txInfo);
				}
		});
}

	Future<int> getMaxNonce(EthereumAddress address) {
		return _makeRPCCall("eth_getMaxNonce", [address.hex])
				.then((s) => numbers.hexToInt(s)).then((d) => d.toInt());
	}

	Future<ProtoTransaction> getTransactionFromAddr(EthereumAddress address, int nonce) {
		return _makeRPCCall("eth_getTransactionByAddrAndNonce", [address.hex, nonce])
				.then((s) {
			if (s == null) {
				return null;
			}

			return new ProtoTransaction.fromJson(s);
		});
	}

	Future<List<ProtoTransaction>> getTransactionsFromAddr(EthereumAddress address, int nonce, int upper) {
		return _makeRPCCall("eth_getTransactionsByAddrAndNonce", [address.hex, nonce, upper])
				.then((s) {
			if (s == null) {
				return null;
			}

			var ret = List<ProtoTransaction>();

			for (var jtx in s) {
				ret.add(new ProtoTransaction.fromJson(jtx));
			}
			return ret;
		});
	}

	/// Gets an element from the storage of the contract with the specified
	/// [address] at the specified [position].
	/// See https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_getstorageat for
	/// more details.
	/// This function allows specifying a custom block mined in the past to get
	/// historical data. By default, [BlockNum.current] will be used.
	Future<List<int>> getStorage(EthereumAddress address, BigInt position, 
  {BlockNum atBlock}) {
		var blockParam = _getBlockParam(atBlock);

		return _makeRPCCall("eth_getStorageAt",
				[address.hex, numbers.toHex(position, pad: true, include0x: true),
					blockParam]).then((s) => numbers.hexToBytes(s));
	}

	/// Gets the amount of transactions issued by the specified [address].
	///
	/// This function allows specifying a custom block mined in the past to get
	/// historical data. By default, [BlockNum.current] will be used.
	Future<int> getTransactionCount(EthereumAddress address, {BlockNum atBlock}) {
		var blockParam = _getBlockParam(atBlock);
			
		return _makeRPCCall("eth_getTransactionCount", [address.hex, blockParam])
				.then((s) => numbers.hexToInt(s)).then((d) => d.toInt());
	}

	/// Gets the code of a contract at the specified [address]
	///
	/// This function allows specifying a custom block mined in the past to get
	/// historical data. By default, [BlockNum.current] will be used.
	Future<List<int>> getCode(EthereumAddress address, {BlockNum atBlock}) {
		return _makeRPCCall("eth_getCode", [address.hex, _getBlockParam(atBlock)])
				.then((s) => numbers.hexToBytes(s));
	}

	/// Signs the given transaction using the keys supplied in the Credentials
	/// object to upload it to the client so that it can be executed.
	///
	/// Returns a hash of the transaction which, after the transaction has been
	/// included in a mined block, can be used to obtain detailed information
	/// about the transaction.
	Future<List<int>> sendRawTransaction(Credentials cred, RawTransaction transaction, {int chainId}) {
		var data = transaction.sign(numbers.numberToBytes(cred.privateKey), chainId);

		return _makeRPCCall("eth_sendRawTransaction", [numbers.bytesToHex(data, include0x: true)])
				.then((s) => numbers.hexToBytes(s));
	}

	/// Executes the transaction, which should be calling a method in a smart
	/// contract deployed on the blockchain, without modifying the blockchain.
	///
	/// For method calls that don't write to the blockchain or otherwise change
	/// its state, the connected client can compute the call locally and return
	/// the given data without consuming any gas that would be required to
	/// calculate this call if it was included in a mined block.
	/// This function allows specifying a custom block mined in the past to get
	/// historical data. By default, [BlockNum.current] will be used.
	Future<List<dynamic>> call(Credentials cred, RawTransaction transaction, ContractFunction decoder, {BlockNum atBlock, int chainId}) {
		String intToHex(dynamic d) => numbers.toHex(d, pad: true, include0x: true);

		var data = {
			"from": cred.address.hex, "to": intToHex(transaction.to),
			"data": numbers.bytesToHex(transaction.data, include0x: true),
		};

		return _makeRPCCall(
				"eth_call", [data, _getBlockParam(atBlock)]).then((data) {
					return decoder.decodeReturnValues(data);
		});
	}
}

/// When the client is currently syncing its blockchain with the network, this
/// representation can be used to find information about at which block the node
/// was before the sync, at which node it currently is and at which block the
/// node will complete its sync.
class SyncInformation {

	/// The field represents the index of the block used in the synchronisation
	/// currently in progress.
	/// [startingBlock] is the block at which the sync started, [currentBlock] is
	/// the block that is currently processed and [finalBlock] is an estimate of
	/// the highest block number this synchronisation will contain.
	/// When the client is not syncing at the moment, these fields will be null
	/// and [isSyncing] will be false.
	final int startingBlock, currentBlock, finalBlock;

	/// Indicates whether this client is currently syncing its blockchain with
	/// other nodes.
	bool get isSyncing => startingBlock != null;

	SyncInformation._(this.startingBlock, this.currentBlock, this.finalBlock);

	@override
	String toString() {
		if (isSyncing)
			return "SyncInformation: from $startingBlock to $finalBlock, current: $currentBlock";
		else
			return "SyncInformation: Currently not performing a synchronisation";
	}
}

/// For operations that are reading data from the blockchain without making a
/// transaction that would modify it, the Ethereum client can read that data
/// from previous states of the blockchain as well. This class specifies which
/// state to use.
class BlockNum {

	final bool useAbsolute;
	final int blockNum;

	const BlockNum._(this.useAbsolute, this.blockNum);

	/// Use the state of the blockchain at the block specified.
	static BlockNum exact(int i) {
		return new BlockNum._(true, i);
	}

	/// Use the state of the blockchain with the first block
	static BlockNum genesis() {
		return const BlockNum._(false, 0);
	}

	/// Use the state of the blockchain as of the latest mined block.
	static BlockNum current() {
		return const BlockNum._(false, 1);
	}

	/// Use the current state of the blockchain, including pending transactions
	/// that have not yet been mined.
	static BlockNum pending() {
		return const BlockNum._(false, 2);
	}

	/// Generates the block parameter as it is accepted by the Ethereum client.
	String toBlockParam() {
		if (useAbsolute)
			return numbers.toHex(blockNum, pad:true, include0x: true);

		switch (blockNum) {
			case 0: return "earliest";
			case 1: return "latest";
			case 2: return "pending";
			default: return "latest"; //Can't happen, though
		}
	}

}
