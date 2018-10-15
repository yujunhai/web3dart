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
  final int gasLimit;
  final EtherAmount gasUsed;
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
        gasLimit = json['gaslimit'],
        gasPrice = EtherAmount.fromUnitAndValue(EtherUnit.wei, json['price']),
        gasUsed = EtherAmount.fromUnitAndValue(EtherUnit.wei, json['gasused']),
        hash = json['hash'],
        nonce = json['nonce'],
        receipt = json['receipt'],
        timestamp = json['timestamp'],
        amount = EtherAmount.fromUnitAndValue(EtherUnit.wei, json['amount']);

  Map<String, dynamic> toJson() =>
      {
        'blockHeight': blockNumber,
        'from': from,
        'to': to,
        'gas': gasLimit,
        'gasPrice': gasPrice,
        'gasUsed': gasUsed,
        'hash': hash,
        'nonce': nonce,
        'receipt': receipt,
        'timestamp': timestamp,
        'amount': amount
      };
}

