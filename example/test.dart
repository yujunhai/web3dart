import 'dart:async';

import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

const String _URL = "http://127.0.0.1:8545";

Future<Null> main() async {
    var httpClient = new Client();
    Web3Client client = new Web3Client(_URL, httpClient);
    client.printErrors = true;
    var txs = await client.getTransactionsByBlockNumber(380, 0, 10);
    // var txs = await client.getTransactions(EthereumAddress("0x220429a6c8bdf58b9c65b4fd5b2b245d79f112de"), TransactionType.income, 0, 10);
    print(txs.total);
    for (var i = 0; i < txs.datas.length; i++) {
      print(txs.datas[i].toJson());
    }
}
