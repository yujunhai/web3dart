import 'package:web3dart/src/wallet/credential.dart';
import 'package:web3dart/src/utils/amounts.dart';
import "package:web3dart/src/utils/numbers.dart" as numbers;

///This class wraps info about page turning
class PageInfo {
  ///index of page that we are currently visiting
  final int currentPageIndex;

  ///how many records there are
  final int totalRecordCount;

  ///how many records represents on each page
  final int pageRecordCount;

  ///which direction we are heading for
  ///FIRST Page    1
  ///PREV Page    2
  ///NEXT page    3
  ///LAST page    4
  final int searchDirection;

  PageInfo.fromJson(Map<String, dynamic> json)
      : currentPageIndex = json.containsKey('currentPageIndex')&&json['currentPageIndex']!= null?json['currentPageIndex']:0,
        totalRecordCount = json.containsKey('totalRecordCount')&&json['totalRecordCount']!= null?json['totalRecordCount']:0,
        pageRecordCount = json.containsKey('pageRecordCount')&&json['pageRecordCount']!= null?json['pageRecordCount']:0,
        searchDirection = json.containsKey('searchDirection')&&json['searchDirection']!= null?json['searchDirection']:0;

  Map<String, dynamic> toJson() =>
      {
        'currentPageIndex' : currentPageIndex,
        'totalRecordCount' : totalRecordCount,
        'pageRecordCount' : pageRecordCount,
        'searchDirection' : searchDirection
      };
}

class TransactionInfo {
  final String hash;
  final EtherAmount price;
  final EtherAmount gasLimit;
  final EthereumAddress from;
  final EthereumAddress to;
  final EtherAmount amount;
  final int type;
  final int nonce;
  final String input;
  final String contract;
  final String blockHeight;
  final String gasUsed;
  final int timestamp;
  final int receipt;
  final String payload;

  TransactionInfo.fromJson(Map<String, dynamic> json)
      : hash = json['hash'],
        price = EtherAmount.fromUnitAndValue(EtherUnit.wei, numbers.hexToInt(json['price'])),
        gasLimit = EtherAmount.fromUnitAndValue(EtherUnit.wei, json['gaslimit']),
        from = EthereumAddress(json['from']),
        to = EthereumAddress(json['to']),
        amount = EtherAmount.fromUnitAndValue(EtherUnit.wei, numbers.hexToInt(json['amount'])),
        type = json['type'],
        nonce = json['nonce'],
        input = json['input'],
        contract = json['contract'],
        blockHeight = json.containsKey('blockheight')&&json['blockheight']!= null?json['blockheight']:null,
        gasUsed = json['gasUsed'],
        timestamp = json['timestamp'],
        receipt = json['receipt'],
        payload = json['payload'];

  Map<String, dynamic> toJson() =>
      {
        'hash' : hash,
        'price' : price,
        'gasLimit' : gasLimit,
        'from' : from,
        'to' : to,
        'amount' : amount,
        'type' : type,
        'nonce' : nonce,
        'input' : input,
        'contract' : contract,
        'blockHeight' : blockHeight,
        'gasUsed' : gasUsed,
        'timestamp' : timestamp,
        'receipt' : receipt,
        'payload' : payload
      };
}

class TransactionInfoRes {
  final PageInfo pageInfo;
  final List<TransactionInfo> txList;

  TransactionInfoRes.New(this.pageInfo, this.txList);
}

