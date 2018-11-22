import "package:web3dart/src/utils/numbers.dart" as numbers;


class BlockRaw {
  final String hash;
  final int number;
  final int difficulty;
  final String extraData;
  final int gasLimit;
  final int gasUsed;
  final String logsBloom;
  final String miner;
  final String mixHash;
  final String nonce;
  final String parentHash;
  final String receiptsRoot;
  final String sha3Uncles;
  final int size;
  final String stateRoot;
  final int timestamp;
  final int totalDifficulty;
  final List<String> transactions;
  final String transactionsRoot;
  final List<String> uncles;

  BlockRaw.fromJson(Map<String, dynamic> json)
    : number = int.parse(json['number'] ?? '-1'),
      hash = json['hash'],
      difficulty = int.parse(json['difficulty']),
      extraData = json['extraData'],
      gasLimit = int.parse(json['gasLimit']),
      gasUsed = int.parse(json['gasUsed']),
      logsBloom = json['logsBloom'],
      miner = json['miner'],
      mixHash = json['mixHash'],
      nonce = json['nonce'],
      parentHash = json['parentHash'],
      receiptsRoot = json['receiptsRoot'],
      sha3Uncles = json['sha3Uncles'],
      size = int.parse(json['size']),
      stateRoot = json['stateRoot'],
      timestamp = int.parse(json['timestamp']),
      totalDifficulty = int.parse(json['totalDifficulty']),
      transactionsRoot = json['transactionsRoot'],
      transactions = json['transactions'].cast<String>(),
      uncles = json["uncles"].cast<String>();

  Map<String, dynamic> toJson() => 
  {
    'hash': hash,
    'number': number,
    'difficulty': difficulty,
    'extraData': extraData,
    'gasLimit': gasLimit,
    'gasUsed': gasUsed,
    'logsBloom': logsBloom,
    'miner': miner,
    'mixHash': mixHash,
    'nonce': nonce,
    'parentHash': parentHash,
    'receiptsRoot': receiptsRoot,
    'sha3Uncles': sha3Uncles,
    'size': size,
    'stateRoot': stateRoot,
    'timestamp': timestamp,
    'totalDifficulty': totalDifficulty,
    'transactionsRoot': transactionsRoot,
    'transactions': transactions,
    'uncles': uncles,
  };
}
