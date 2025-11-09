class Friend {

  Friend({this.id, required this.name, this.creditBalance, this.debitBalance});
  final int? id;
  final String name;
  final double? creditBalance;
  final double? debitBalance;
  bool starred = false;

  
  Friend.fromJson(Map json) 
  : id = json["id"],
  name = json["name"],
  creditBalance = json["credit_balance"],
  debitBalance = json["debit_balance"];

  @override
  String toString() {
    return "$id | $name | $creditBalance | $debitBalance | $starred";
  }

}

class ServerException implements Exception {
  String errorMessage;
  ServerException(this.errorMessage);
}