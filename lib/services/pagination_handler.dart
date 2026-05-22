import 'package:two_one_two_messenger/models/saved_messages.dart';

class PaginationController {
  int currentPage;
  int limit;
  bool hasMore;
  bool isFetching;

  PaginationController({
    this.currentPage = 1,
    this.limit = 50,
    this.hasMore = true,
    this.isFetching = false,
  });

  PaginationController reset() {
    return PaginationController(
      currentPage: 1,
      limit: 50,
      hasMore: true,
      isFetching: false,
    );
  }

  void setLimit(int value) {
    limit = value;
  }

  void nextPage(Pagination? pagination) {
    if (pagination == null) return;
    hasMore = currentPage < (pagination.totalPages ?? 0);
    currentPage++;
  }

  PaginationController copyWith({
    int? currentPage,
    int? limit,
    bool? hasMore,
    bool? isFetching,
  }) {
    return PaginationController(
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
      isFetching: isFetching ?? this.isFetching,
    );
  }
}
