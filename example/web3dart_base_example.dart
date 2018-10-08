import 'dart:async';

import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';


main() async {
  var apiUrl = "http://localhost:8545"; //Replace with your API

  var httpClient = new Client();
  var ethClient = new Web3Client(apiUrl, httpClient);


// You can now call rpc methods. This one will query the amount of Ether you own
  EtherAmount balance = await ethClient.getBalance(EthereumAddress("0xf4c658c37de0fbde225380d075c761553e36d1f7"));
  print(balance.getValueInUnit(EtherUnit.ether));

  int maxNonce = await ethClient.getMaxNonce(EthereumAddress("0xf4c658c37de0fbde225380d075c761553e36d1f7"));
  print(maxNonce);

  var tx = await ethClient.getTransactionFromAddr(EthereumAddress("0xf4c658c37de0fbde225380d075c761553e36d1f7"), 2);
  print(tx.blockHash);
  print(tx.blockNumber);
  print(tx.gasPrice.getValueInUnit(EtherUnit.ether));

  var txs = await ethClient.getTransactionsFromAddr(EthereumAddress("0xf4c658c37de0fbde225380d075c761553e36d1f7"), 0, 3);
  print(txs[0].blockHash);
  print(txs[1].blockHash);
  print(txs[2].blockHash);
}

