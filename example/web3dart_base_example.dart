import 'dart:async';
import 'dart:math';

import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';


main() async {
  var apiUrl = "http://localhost:8001"; //Replace with your API

  var httpClient = new Client();
  var ethClient = new Web3Client(apiUrl, httpClient);
  // You can create Credentials from private keys
  Credentials fromHex = Credentials.fromPrivateKeyHex("1FAEEB8DEC9E97B45D555F19618FEFDB37098F727B529EFE7B1837793271FD66");

// In either way, the library can derive the public key and the address
// from a private key:
  var address = fromHex.address.hex;

  var transaction = new Transaction(
      keys: fromHex, maximumGas: 100000
  );
// Lets make the transaction actually do something: Send 0.3 Ether to the
// address specified.
  var result = await transaction.prepareForSimpleTransaction(
      new EthereumAddress("0x619bd1433431509f76e7223982477cb09e167693"), // your target address
      EtherAmount.fromUnitAndValue(EtherUnit.finney, 300)
  ).send(ethClient, chainId: 3);
  print(result.toString());
  print(address);
  print("hello");


  /*
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
  */
}


