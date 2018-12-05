import 'dart:async';

import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import "package:web3dart/src/utils/numbers.dart" as numbers;
//const String _URL = "http://127.0.0.1:8545";
const String _URL = "http://192.168.1.45:8545";

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
    

    //var txinfores = await client.getTransactionInfo(3,"0xd7b47ae464765fa5afd65cc0aa275caffdb72869","0x0000000000000000000000000000000000000000000000000000000000000000",0,1,10,1);
    var txinfores = await client.getUserTransactionInfo(3,"0x23fdb7cd972d4b61017f9d44e79f74cd295cb51d","0x0000000000000000000000000000000000000000000000000000000000000000",0,1,10,1);
    print("===============");
    print(txinfores.pageInfo.toJson());
    for(var tx in txinfores.txList) {
        print(tx.amount.getValueInUnit(EtherUnit.ether));
        print(tx.price.getValueInUnit(EtherUnit.gwei));
    }
    */
    var df = numbers.hexToInt("0x10a38a2b3ff8665ed");
    var blockRow = await client.getBlockByHash("0xd14fa8a314771378067b83cb28288bcf9715732d1a140f1cadcc88102479f78d");
    //var blockRow = await client.getBlockByNumber(10000);
    print(blockRow.toJson());
}
