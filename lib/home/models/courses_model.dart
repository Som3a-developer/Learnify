class CoursesModel {
  int? courseId;
  String? createdAt;
  String? title;
  String? category;
  String? publisher;
  String? url;
  String? description;
  String? thumbnailUrl;
  int? points;
  CoursesModel(
      {this.courseId,
      this.createdAt,
      this.title,
      this.category,
      this.publisher,
      this.url,
      this.description,
      this.thumbnailUrl,
      this.points,
      });

  CoursesModel.fromJson(dynamic json) {
    courseId = json['course_id'];
    createdAt = json['created_at'];
    title = json['title'];
    category = json['category'];
    publisher = json['publisher'];
    url = json['url'];
    description = json['description'];
    thumbnailUrl = json['thumbnail_url'];
    points = json['points'];
  }

  Map<String, dynamic> toJson(data) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['course_id'] = this.courseId;
    data['created_at'] = this.createdAt;
    data['title'] = this.title;
    data['category'] = this.category;
    data['publisher'] = this.publisher;
    data['url'] = this.url;
    data['description'] = this.description;
    data['thumbnail_url'] = this.thumbnailUrl;
    data['points'] = this.points;
    return data;
  }
}
