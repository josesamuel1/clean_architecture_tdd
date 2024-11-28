import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/util/input_converter.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/usecases/get_concrete_number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';
import 'number_trivia_state.dart';

const String serverFailureMessage = 'Server Failure';
const String cacheFailureMessage = 'Cache Failure';
const String invalidInputFailureMessage =
    'Invalid input - The number must be a positive integer or zero';

class NumberTriviaCubit extends Cubit<NumberTriviaState> {
  final GetConcreteNumberTrivia concrete;
  final GetRandomNumberTrivia random;
  final InputConverter inputConverter;

  NumberTriviaCubit({
    required this.concrete,
    required this.random,
    required this.inputConverter,
  }) : super(Empty());

  Future<void> getTriviaForConcreteNumber(String numberString) async {
    final inputEither = inputConverter.stringToUnsignedInteger(numberString);

    await inputEither.fold(
      (failure) async {
        emit(Error(message: invalidInputFailureMessage));
      },
      (integer) async {
        emit(Loading());
        final failureOrTrivia = await concrete(Params(number: integer));
        _eitherLoadedOrErrorState(failureOrTrivia);
      },
    );
  }

  Future<void> getTriviaForRandomNumber() async {
    emit(Loading());
    final failureOrTrivia = await random(NoParams());
    _eitherLoadedOrErrorState(failureOrTrivia);
  }

  void _eitherLoadedOrErrorState(
    Either<Failure, NumberTrivia> failureOrTrivia,
  ) async {
    failureOrTrivia.fold(
      (failure) => emit(
        Error(message: _mapFailureToMessage(failure)),
      ),
      (trivia) => emit(
        Loaded(trivia: trivia),
      ),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (ServerFailure):
        return serverFailureMessage;
      case const (CacheFailure):
        return cacheFailureMessage;
      default:
        return 'Unexpected error';
    }
  }
}
