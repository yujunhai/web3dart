import 'package:web3dart/src/wallet/credential.dart';
import 'package:web3dart/src/utils/amounts.dart';
import "package:web3dart/src/utils/numbers.dart" as numbers;

class TransactionResult {
  final List<TransactionRows> datas;
  final int total;

  TransactionResult.New(int t, List<TransactionRows> list)
    : total = t,
      datas = list;
}

class TransactionRows {
  final int blockNumber;
  final EthereumAddress from;
  final EthereumAddress to;
  final int gas;
  final int gasUsed;
  final EtherAmount gasPrice;
  final int nonce;
  final String hash;
  final int receipt;
  final int timestamp;
  final EtherAmount amount;


  TransactionRows.fromJson(Map<String, dynamic> json)
      : blockNumber = json['blockheight'],
        from = EthereumAddress(json['from']),
        to = EthereumAddress(json['to']),
        gas = json['gas'],
        gasPrice = EtherAmount.fromUnitAndValue(EtherUnit.wei, numbers.hexToInt(json['gasprice'])),
        gasUsed = json['gasused'],
        hash = json['hash'],
        nonce = json['nonce'],
        receipt = json['receipt'],
        timestamp = json['timestamp'],
        amount = EtherAmount.fromUnitAndValue(EtherUnit.wei, numbers.hexToInt(json["amount"]));

  Map<String, dynamic> toJson() =>
      {
        'blockHeight': blockNumber,
        'from': from,
        'to': to,
        'gas': gas,
        'gasPrice': gasPrice,
        'gasUsed': gasUsed,
        'hash': hash,
        'nonce': nonce,
        'receipt': receipt,
        'timestamp': timestamp,
        'amount': amount
      };
}


class TransactionRaw {
  final String blockHash;
  final int blockNumber;
  final EthereumAddress from;
  final int gas;
  final EtherAmount gasPrice;
  final String hash;
  final String input;
  final int nonce;
  final String r;
  final String s;
  final EthereumAddress to;
  final int transactionIndex;
  final String v;
  final EtherAmount value;

  TransactionRaw.fromJson(Map<String, dynamic> json)
    : blockNumber = int.parse(json['blockNumber']),
      from = EthereumAddress(json['from']),
      to = EthereumAddress(json['to']),
      gas = int.parse(json['gas']),
      blockHash = json['blockHash'],
      gasPrice = EtherAmount.fromUnitAndValue(EtherUnit.wei, numbers.hexToInt(json['gasPrice'])),
      hash = json['hash'],
      input = json['input'],
      nonce = int.parse(json['nonce']),
      r = json['r'],
      s = json['s'],
      v = json['v'],
      transactionIndex = int.parse(json['transactionIndex']),
      value = EtherAmount.fromUnitAndValue(EtherUnit.wei, numbers.hexToInt(json["value"]));

  Map<String, dynamic> toJson() => 
  {
    'blockHash': blockHash,
    'blockNumber': blockNumber,
    'from': from,
    'gas': gas,
    'gasPrice': gasPrice,
    'hash': hash,
    'input': input,
    'nonce': nonce,
    'r': r,
    's': s,
    'to': to,
    'transactionIndex': transactionIndex,
    'v': v,
    'value': value,
  };
}


