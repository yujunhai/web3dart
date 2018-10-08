import 'package:web3dart/src/wallet/credential.dart';
import 'package:web3dart/src/utils/amounts.dart';
import "package:web3dart/src/utils/numbers.dart" as numbers;

class ProtoTransaction {
  final String blockHash;
  final String blockNumber;
  final EthereumAddress from;
  final EthereumAddress to;
  final String gas;
  final EtherAmount gasPrice;
  final String hash;
  final String input;
  final int nonce;
  final int transactionIndex;
  final EtherAmount value;

  ProtoTransaction.fromJson(Map<String, dynamic> json)
      : blockHash = json.containsKey('blockHash')&&json['blockHash']!= null?json['blockHash']:null,
        blockNumber = json.containsKey('blockNumber')&&json['blockNumber']!= null?json['blockNumber']:null,
        from = EthereumAddress(json['from']),
        to = EthereumAddress(json['to']),
        gas = json['gas'],
        gasPrice = EtherAmount.fromUnitAndValue(EtherUnit.wei, numbers.hexToInt(json['gasPrice'])),
        hash = json['hash'],
        input = json['input'],
        nonce = numbers.hexToInt(json['nonce']).toInt(),
        transactionIndex = numbers.hexToInt(json['transactionIndex']).toInt(),
        value = EtherAmount.fromUnitAndValue(EtherUnit.wei, numbers.hexToInt(json['value']));

  Map<String, dynamic> toJson() =>
      {
        'blockHash': blockHash,
        'blockNumber': blockNumber,
        'from': from,
        'to': to,
        'gas': gas,
        'gasPrice': gasPrice,
        'hash': hash,
        'input': input,
        'nonce': nonce,
        'transactionIndex': transactionIndex,
        'value': value,
      };
}

