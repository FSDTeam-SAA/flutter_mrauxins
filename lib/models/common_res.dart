
class CommonResponseModel {
    final int? status;
    final String? message;

    CommonResponseModel({
        this.status,
        this.message,
    });

    CommonResponseModel copyWith({
        int? status,
        String? message,
    }) => 
        CommonResponseModel(
            status: status ?? this.status,
            message: message ?? this.message,
        );

    factory CommonResponseModel.fromJson(Map<String, dynamic> json) => CommonResponseModel(
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
    };
}
  


  