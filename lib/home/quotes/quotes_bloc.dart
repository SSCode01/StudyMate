import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/quote_service.dart';
import 'quotes_event.dart';
import 'quotes_state.dart';

class QuotesBloc extends Bloc<QuotesEvent, QuotesState> {
  final QuoteService service;

  QuotesBloc(this.service) : super(QuotesLoading()) {
    on<FetchQuotes>((event, emit) async {
      try {
        final quotes = await service.fetchQuotes();
        emit(QuotesLoaded(quotes));
      } catch (e) {
        emit(QuotesError(e.toString()));
      }
    });
  }
}
