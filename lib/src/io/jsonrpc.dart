import 'dart:async';
import 'dart:convert';

import "package:http/http.dart";

class JsonRPC {

	String url;
	Client client;

	int _currentRequestId = 0;
	Map<String, String> _headers = new Map<String, String>();

	JsonRPC(this.url, this.client);

	void AddHeader(Map<String, String> h) {
		_headers.addAll(h);
	}

	/// Performs an RPC request, asking the server to execute the function with
	/// the given name and the associated parameters, which need to be encodable
	/// with the [json] class of dart:convert.
	///
	/// When the request is successful, an [RPCResponse] with the request id and
	/// the data from the server will be returned. If not, an RPCError will be
	/// thrown. Other errors might be thrown if an IO-Error occurs.
	Future<RPCResponse> call(String function, [List<dynamic> params]) async {
		params ??= [];

		var requestPayload = {
			"jsonrpc": "2.0",
			"method": function,
			"params": params,
			"id": _currentRequestId,
		};

		if (!_headers.containsKey("Content-Type")) {
			_headers.addAll({"Content-Type": "application/json"});
		}
		
		var response = await client.post(url,
				headers: _headers,
				body: json.encode(requestPayload)
		);
		if (response.statusCode == 302 || response.statusCode == 301) {
			String oldurl = url;
			url = response.headers["location"];
			var ret = this.call(function, params);
			url = oldurl;
			return ret;
		}

		Map<String, dynamic> data = json.decode(response.body);
		int id = data["id"];

		if (data.containsKey("error")) {
			var error = data["error"];

			int code = error["code"];
			String message = error["message"];
			var errorData = error["data"];

			throw new RPCError(code, message, errorData);
		}

		var result = data["result"];
		return new RPCResponse(id, result);
	}
}

/// Response from the server to an rpc request. Contains the id of the request
/// and the corresponding result as sent by the server.
class RPCResponse {

	final int id;
	final dynamic result;

	const RPCResponse(this.id, this.result);
}

/// Exception thrown when an the server returns an error code to an rpc request.
class RPCError implements Exception {

	final int errorCode;
	final String message;
	final dynamic data;

	const RPCError(this.errorCode, this.message, this.data);

	@override
  String toString() {
		return "RPCError: got code $errorCode with msg \"$message\".";
	}
}