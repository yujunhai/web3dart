import 'dart:typed_data';

import 'package:bignum/bignum.dart';
import 'package:web3dart/src/utils/keys.dart' as crypto;
import 'package:web3dart/src/utils/keys.dart';
import 'package:web3dart/src/utils/rlp.dart' as rlp;

class RawTransaction {

	final int nonce;
	final int gasPrice;
	final int gasLimit;

	final BigInteger to;
	final BigInteger value; //amount
	final BigInteger data;

  RawTransaction({this.nonce, this.gasPrice, this.gasLimit, this.to, this.value, this.data});

  Uint8List encode(MsgSignature signature) {
		List<Uint8List> createRaw() {
			var list = new List<Uint8List>();

			list.add(rlp.toBuffer(nonce));
			list.add(rlp.toBuffer(gasPrice));
			list.add(rlp.toBuffer(gasLimit));
			list.add(rlp.toBuffer(to ?? BigInteger.ZERO));
			list.add(rlp.toBuffer(value));
			list.add(rlp.toBuffer(data ?? BigInteger.ZERO));

			if (signature != null) {
				list.add(rlp.toBuffer(signature.v));
				list.add(rlp.toBuffer(signature.r));
				list.add(rlp.toBuffer(signature.s));
			}

			return list;
		}

		var byteData = createRaw();
		return rlp.encode(byteData);
	}

  Uint8List sign(Uint8List privateKey, int chainId) {
		var encodedTransaction = encode(
				new MsgSignature(BigInteger.ZERO, BigInteger.ZERO, chainId));
		var hashed = crypto.sha3digest.process(encodedTransaction);

		var signature = crypto.sign(hashed, privateKey);
		var vWithChain = signature.v + (chainId << 1) + 8;
		var updatedSignature = new MsgSignature(signature.r, signature.s, vWithChain);

		return encode(updatedSignature);
  }
}