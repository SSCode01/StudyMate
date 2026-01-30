import '../../services/quote_model.dart';

abstract class QuotesState {}

class QuotesLoading extends QuotesState {}
class QuotesLoaded extends QuotesState {
  final List<Quote> quotes;
  QuotesLoaded(this.quotes);
}
class QuotesError extends QuotesState {
  final String msg;
  QuotesError(this.msg);
}
