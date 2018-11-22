import 'dart:async';

import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

//const String _URL = "http://127.0.0.1:8545";
const String _URL = "https://api.del.io:7101";

Future<Null> main() async {
    var httpClient = new Client();
    Web3Client client = new Web3Client(_URL, httpClient);
    client.printErrors = true;
    /*
    var txs = await client.getTransactionsByBlockNumber(428, 0, 10);
    // var txs = await client.getTransactions(EthereumAddress("0x220429a6c8bdf58b9c65b4fd5b2b245d79f112de"), TransactionType.income, 0, 10);
    print(txs.total);
    for (var i = 0; i < txs.datas.length; i++) {
      //print(txs.datas[i].gasUsed.getValueInUnit(EtherUnit.ether).toString());
      print(txs.datas[i].amount.getValueInUnit(EtherUnit.ether).toString());
      print(txs.datas[i].gasPrice.getValueInUnit(EtherUnit.wei).toString());
    }
    */

    var txinfores = await client.getTransactionInfo(3,"0x61b9cf73d2d5b932ebac67c3ed26db3bb2520c58","0x0000000000000000000000000000000000000000000000000000000000000000",0,1,70,1);

    print("===============");

    txinfores = await client.getTransactionInfo(1,"","0x0000000000000000000000000000000000000000000000000000000000000000",0,1,70,1);
    print(txinfores.pageInfo.toJson());
}
