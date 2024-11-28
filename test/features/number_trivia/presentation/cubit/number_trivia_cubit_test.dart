import 'package:clean_architecture_tdd/core/error/failures.dart';
import 'package:clean_architecture_tdd/core/usecases/usecase.dart';
import 'package:clean_architecture_tdd/core/util/input_converter.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_tdd/features/number_trivia/presentation/cubit/number_trivia_cubit.dart';
import 'package:clean_architecture_tdd/features/number_trivia/presentation/cubit/number_trivia_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_cubit_test.mocks.dart';

@GenerateMocks([
  GetConcreteNumberTrivia,
  GetRandomNumberTrivia,
  InputConverter,
])
void main() {
  late NumberTriviaCubit cubit;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    cubit = NumberTriviaCubit(
      concrete: mockGetConcreteNumberTrivia,
      random: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  final tNumberString = '1';
  final tNumberParsed = 1;
  final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

  test('initialState should be Empty', () {
    // assert
    expect(cubit.state, equals(Empty()));
  });

  group('getTriviaForConcreteNumber', () {
    void setUpMockInputConverterSuccess() => when(
          mockInputConverter.stringToUnsignedInteger(any),
        ).thenReturn(
          Right(tNumberParsed),
        );

    test(
      'should call the InputConverter to validate and convert the string to an unsigned integer',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(
          mockGetConcreteNumberTrivia(any),
        ).thenAnswer(
          (_) async => Right(tNumberTrivia),
        );
        // act
        await cubit.getTriviaForConcreteNumber(tNumberString);
        // assert
        verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
      },
    );

    test(
      'should emit [Error] when the input is invalid',
      () async {
        // arrange
        when(
          mockInputConverter.stringToUnsignedInteger(any),
        ).thenReturn(
          Left(InvalidInputFailure()),
        );
        // assert later
        final expected = [
          Error(message: invalidInputFailureMessage),
        ];
        expectLater(cubit.stream, emitsInOrder(expected));
        // act
        cubit.getTriviaForConcreteNumber(tNumberString);
      },
    );

    test(
      'should get data from the concrete use case',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(
          mockGetConcreteNumberTrivia(any),
        ).thenAnswer(
          (_) async => Right(tNumberTrivia),
        );
        // act
        await cubit.getTriviaForConcreteNumber(tNumberString);
        // assert
        verify(mockGetConcreteNumberTrivia(
          Params(number: tNumberParsed),
        ));
      },
    );

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));
        // assert later
        final expected = [
          Loading(),
          Loaded(trivia: tNumberTrivia),
        ];
        expectLater(cubit.stream, emitsInOrder(expected));
        // act
        cubit.getTriviaForConcreteNumber(tNumberString);
      },
    );

    test(
      'should emit [Loading, Error] when getting data fails',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        // assert later
        final expected = [
          Loading(),
          Error(message: serverFailureMessage),
        ];
        expectLater(cubit.stream, emitsInOrder(expected));
        // act
        cubit.getTriviaForConcreteNumber(tNumberString);
      },
    );

    test(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
        // assert later
        final expected = [
          Loading(),
          Error(message: cacheFailureMessage),
        ];
        expectLater(cubit.stream, emitsInOrder(expected));
        // act
        cubit.getTriviaForConcreteNumber(tNumberString);
      },
    );
  });

  group('getTriviaForRandomNumber', () {
    test(
      'should get data from the random use case',
      () async {
        // arrange
        when(
          mockGetRandomNumberTrivia(NoParams()),
        ).thenAnswer(
          (_) async => Right(tNumberTrivia),
        );
        // act
        await cubit.getTriviaForRandomNumber();
        // assert
        verify(mockGetRandomNumberTrivia(NoParams()));
      },
    );

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
        // arrange
        when(
          mockGetRandomNumberTrivia(NoParams()),
        ).thenAnswer(
          (_) async => Right(tNumberTrivia),
        );
        // assert later
        final expected = [
          Loading(),
          Loaded(trivia: tNumberTrivia),
        ];
        expectLater(cubit.stream, emitsInOrder(expected));
        // act
        cubit.getTriviaForRandomNumber();
      },
    );

    test(
      'should emit [Loading, Error] when getting data fails',
      () async {
        // arrange
        when(
          mockGetRandomNumberTrivia(NoParams()),
        ).thenAnswer(
          (_) async => Left(ServerFailure()),
        );
        // assert later
        final expected = [
          Loading(),
          Error(message: serverFailureMessage),
        ];
        expectLater(cubit.stream, emitsInOrder(expected));
        // act
        cubit.getTriviaForRandomNumber();
      },
    );

    test(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
      () async {
        // arrange
        when(
          mockGetRandomNumberTrivia(NoParams()),
        ).thenAnswer(
          (_) async => Left(CacheFailure()),
        );
        // assert later
        final expected = [
          Loading(),
          Error(message: cacheFailureMessage),
        ];
        expectLater(cubit.stream, emitsInOrder(expected));
        // act
        cubit.getTriviaForRandomNumber();
      },
    );
  });
}
