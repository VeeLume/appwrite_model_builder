import 'package:appwrite_model_builder/src/collection_parser/collection_info.dart';
import 'package:appwrite_model_builder/src/model.dart';
import 'package:code_builder/code_builder.dart';

Library registerHelper(String packageName, List<CollectionInfo> collections) {
  final lib = Library((b) {
    b.body.addAll([
      Method(
        (b) =>
            b
              ..name = '_registerAppwriteClient'
              ..returns = refer('void')
              ..requiredParameters.add(
                Parameter(
                  (b) =>
                      b
                        ..name = 'client'
                        ..type = refer(
                          'Client',
                          'package:appwrite/appwrite.dart',
                        ),
                ),
              )
              ..body = Block((b) {
                b.addExpression(
                  refer('di', 'package:watch_it/watch_it.dart')
                      .property('registerSingleton')
                      .call(
                        [
                          refer(
                            'AppwriteClient',
                            'package:$packageName/models/appwrite_client.dart',
                          ).newInstance([refer('client')]),
                        ],
                        {},
                        [
                          refer(
                            'AppwriteClient',
                            'package:$packageName/models/appwrite_client.dart',
                          ),
                        ],
                      ),
                );
              }),
      ),
      Method(
        (b) =>
            b
              ..name = '_registerAuthProvider'
              ..returns = refer('void')
              ..types.add(
                TypeReference(
                  (b) =>
                      b
                        ..symbol = 'T'
                        ..bound = refer(
                          'AuthProvider',
                          'package:$packageName/providers/auth_provider.dart',
                        ),
                ),
              )
              ..requiredParameters.add(
                Parameter(
                  (b) =>
                      b
                        ..name = 'factory'
                        ..type = FunctionType((b) {
                          b.returnType = refer('T');
                        }),
                ),
              )
              ..body =
                  refer('di', 'package:watch_it/watch_it.dart')
                      .property('registerLazySingletonAsync')
                      .call(
                        [
                          Method(
                            (b) =>
                                b
                                  ..modifier = MethodModifier.async
                                  ..body = Block((b) {
                                    b.addExpression(
                                      declareFinal(
                                        'auth',
                                      ).assign(refer('factory').call([])),
                                    );
                                    b.addExpression(
                                      refer(
                                        'auth',
                                      ).property('build').call([]).awaited,
                                    );
                                    b.addExpression(refer('auth').returned);
                                  }),
                          ).closure,
                        ],
                        {},
                        [
                          refer('T'),
                        ],
                      )
                      .code,
      ),
      Method(
        (b) =>
            b
              ..name = '_registerRealtimeProvider'
              ..types.add(
                TypeReference(
                  (b) =>
                      b
                        ..symbol = 'T'
                        ..bound = refer(
                          'AuthProvider',
                          'package:$packageName/providers/auth_provider.dart',
                        ),
                ),
              )
              ..returns = refer('void')
              ..body =
                  refer('di', 'package:watch_it/watch_it.dart')
                      .property('registerLazySingletonAsync')
                      .call(
                        [
                          Method(
                            (b) =>
                                b
                                  ..modifier = MethodModifier.async
                                  ..body = Block((b) {
                                    b.addExpression(
                                      declareFinal('realtime').assign(
                                        refer(
                                              'di',
                                              'package:watch_it/watch_it.dart',
                                            )
                                            .call([], {}, [
                                              refer(
                                                'AppwriteClient',
                                                'package:$packageName/models/appwrite_client.dart',
                                              ),
                                            ])
                                            .property('realtime'),
                                      ),
                                    );
                                    b.addExpression(
                                      declareFinal('subscriptions').assign(
                                        TypeReference(
                                          (b) =>
                                              b
                                                ..symbol =
                                                    'RealtimeSubscriptions'
                                                ..url =
                                                    'package:$packageName/providers/realtime_subscription.dart'
                                                ..types.add(refer('T')),
                                        ).newInstance([refer('realtime')]),
                                      ),
                                    );
                                    b.addExpression(
                                      refer(
                                        'subscriptions',
                                      ).property('build').call([]).awaited,
                                    );
                                    b.addExpression(
                                      refer('subscriptions').returned,
                                    );
                                  }),
                          ).closure,
                        ],
                        {},
                        [
                          refer(
                            'RealtimeSubscriptions',
                            'package:$packageName/providers/realtime_subscription.dart',
                          ),
                        ],
                      )
                      .code,
      ),
      ...collections.map((collection) {
        return Method(
          (b) =>
              b
                ..name = '_register${collection.name}Provider'
                ..returns = refer('void')
                ..body =
                    refer('di', 'package:watch_it/watch_it.dart')
                        .property('registerLazySingletonAsync')
                        .call(
                          [
                            Method(
                              (b) =>
                                  b
                                    ..modifier = MethodModifier.async
                                    ..body = Block((b) {
                                      b.addExpression(
                                        declareFinal('model').assign(
                                          refer(
                                            '${collection.reference.symbol}Provider',
                                            'package:$packageName/providers/${moduleName(collection.name)}.dart',
                                          ).newInstance([]),
                                        ),
                                      );
                                      b.addExpression(
                                        refer(
                                          'model',
                                        ).property('build').call([]).awaited,
                                      );
                                      b.addExpression(refer('model').returned);
                                    }),
                            ).closure,
                          ],
                          {},
                          [
                            refer(
                              '${collection.reference.symbol}Provider',
                              'package:$packageName/providers/${moduleName(collection.name)}.dart',
                            ),
                          ],
                        )
                        .code,
        );
      }),
      Method(
        (b) =>
            b
              ..name = 'registerServices'
              ..returns = refer('void')
              ..types.add(
                TypeReference(
                  (b) =>
                      b
                        ..symbol = 'T'
                        ..bound = refer(
                          'AuthProvider',
                          'package:$packageName/providers/auth_provider.dart',
                        ),
                ),
              )
              ..requiredParameters.add(
                Parameter(
                  (b) =>
                      b
                        ..name = 'factory'
                        ..type = FunctionType((b) {
                          b.returnType = refer('T');
                        }),
                ),
              )
              ..requiredParameters.add(
                Parameter(
                  (b) =>
                      b
                        ..name = 'client'
                        ..type = refer(
                          'Client',
                          'package:appwrite/appwrite.dart',
                        ),
                ),
              )
              ..body = Block((b) {
                b.addExpression(
                  refer('_registerAppwriteClient').call([refer('client')]),
                );
                b.addExpression(
                  TypeReference(
                    (b) =>
                        b
                          ..symbol = '_registerAuthProvider'
                          ..types.add(refer('T')),
                  ).call([refer('factory')]),
                );
                b.addExpression(
                  TypeReference(
                    (b) =>
                        b
                          ..symbol = '_registerRealtimeProvider'
                          ..types.add(refer('T')),
                  ).call([]),
                );
              }),
      ),
      Method(
        (b) =>
            b
              ..name = 'registerProviders'
              ..returns = refer('void')
              ..body = Block((b) {
                for (final collection in collections) {
                  b.addExpression(
                    refer('_register${collection.name}Provider').call([]),
                  );
                }
              }),
      ),
    ]);
  });

  return lib;
}
