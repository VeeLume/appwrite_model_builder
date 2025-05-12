import 'package:code_builder/code_builder.dart';

Library genericListProvider() {
  return Library((lib) {
    lib.body.addAll([
      Mixin((m) {
        m.name = 'GenericListProvider';
        m.types.addAll([refer('T')]);
        m.on = refer('ChangeNotifier', 'package:flutter/foundation.dart');
        m.methods.addAll([
          Method((m) {
            m.name = 'items';
            m.returns = refer('List<T>');
            m.type = MethodType.getter;
          }),
          Method((m) {
            m.name = 'hasMore';
            m.returns = refer('bool');
            m.type = MethodType.getter;
          }),
        ]);
      }),
    ]);
  });
}

Library authProvider() {
  return Library((lib) {
    lib.body.addAll([
      Class((c) {
        c.name = 'AuthProvider';
        c.abstract = true;
        c.extend = refer('ChangeNotifier', 'package:flutter/foundation.dart');
        c.methods.addAll([
          Method((m) {
            m.name = 'isAuthenticated';
            m.returns = refer('bool');
            m.type = MethodType.getter;
          }),
        ]);
      }),
    ]);
  });
}

Library realtimeSubscriptions(String packageName) {
  return Library((lib) {
    lib.body.addAll([
      Class((c) {
        c.name = 'RealtimeSubscriptions';
        c.fields.addAll([
          Field((b) {
            b.name = '_realtime';
            b.type = refer('Realtime', 'package:appwrite/appwrite.dart');
            b.modifier = FieldModifier.final$;
          }),
          Field((b) {
            b.name = '_subscription';
            b.type = TypeReference((b) {
              b
                ..symbol = 'RealtimeSubscription'
                ..url = 'package:appwrite/appwrite.dart'
                ..isNullable = true;
            });
          }),
          Field((b) {
            b.name = '_listeners';
            b.type = TypeReference((b) {
              b
                ..symbol = 'Map'
                ..types.addAll([
                  refer('String'),
                  TypeReference((b) {
                    b
                      ..symbol = 'List'
                      ..types.add(
                        FunctionType((b) {
                          b
                            ..returnType = refer('void')
                            ..requiredParameters.add(
                              TypeReference((b) {
                                b
                                  ..symbol = 'RealtimeMessage'
                                  ..url = 'package:appwrite/appwrite.dart';
                              }),
                            );
                        }),
                      );
                  }),
                ]);
            });
            b.modifier = FieldModifier.final$;
            b.assignment = literalMap({}).code;
          }),
        ]);
        c.methods.addAll([
          Method((m) {
            m.name = 'channels';
            m.returns = refer('Set<String>');
            m.type = MethodType.getter;
            m.lambda = true;
            m.body =
                refer(
                  '_listeners',
                ).property('keys').property('toSet').call([]).code;
          }),
          Method((m) {
            m.name = 'subscription';
            m.type = MethodType.setter;
            m.requiredParameters.add(
              Parameter((b) {
                b.name = 'value';
                b.type = TypeReference((b) {
                  b
                    ..symbol = 'RealtimeSubscription'
                    ..url = 'package:appwrite/appwrite.dart'
                    ..isNullable = true;
                });
              }),
            );
            m.body = Code('''
              _subscription?.close();

    if (_listeners.isEmpty) {
      return;
    }

    _subscription = value;

    _subscription?.stream.listen((message) {
      final messageChannels = Set.from(message.channels);
      final intersection = messageChannels.intersection(channels);

      for (final channel in intersection) {
        _listeners[channel]?.forEach((callback) {
          callback(message);
        });
      }
    });
            ''');
          }),
          Method((m) {
            m.name = 'subscribe';
            m.returns = refer('void');
            m.requiredParameters.add(
              Parameter((b) {
                b.name = 'channelName';
                b.type = refer('String');
              }),
            );
            m.requiredParameters.add(
              Parameter((b) {
                b.name = 'callback';
                b.type = FunctionType((b) {
                  b
                    ..returnType = refer('void')
                    ..requiredParameters.add(
                      TypeReference((b) {
                        b
                          ..symbol = 'RealtimeMessage'
                          ..url = 'package:appwrite/appwrite.dart';
                      }),
                    );
                });
              }),
            );
            m.body = Block((b) {
              b.addExpression(
                refer('_listeners')
                    .property('putIfAbsent')
                    .call([
                      refer('channelName'),
                      Method((b) {
                        b.lambda = true;
                        b.body = literalList([]).code;
                      }).closure,
                    ])
                    .property('add')
                    .call([refer('callback')]),
              );
              b.addExpression(
                refer('subscription').assign(
                  refer('_realtime').property('subscribe').call([
                    refer(
                      '_listeners',
                    ).property('keys').property('toList').call([]),
                  ]),
                ),
              );
            });
          }),
          Method((m) {
            m.name = 'unsubscribe';
            m.returns = refer('void');
            m.requiredParameters.addAll([
              Parameter((b) {
                b.name = 'channelName';
                b.type = refer('String');
              }),
              Parameter((b) {
                b.name = 'callback';
                b.type = FunctionType((b) {
                  b
                    ..returnType = refer('void')
                    ..requiredParameters.add(
                      TypeReference((b) {
                        b
                          ..symbol = 'RealtimeMessage'
                          ..url = 'package:appwrite/appwrite.dart';
                      }),
                    );
                });
              }),
            ]);
            m.body = Block((b) {
              b.addExpression(
                refer('_listeners')
                    .index(refer('channelName'))
                    .nullSafeProperty('remove')
                    .call([refer('callback')]),
              );
              b.addExpression(
                refer('_listeners')
                    .index(refer('channelName'))
                    .nullSafeProperty('isEmpty')
                    .ifNullThen(literalFalse)
                    .conditional(
                      refer(
                        '_listeners',
                      ).property('remove').call([refer('channelName')]),
                      literalNull,
                    ),
              );
              b.addExpression(
                refer('subscription').assign(
                  refer('_realtime').property('subscribe').call([
                    refer(
                      '_listeners',
                    ).property('keys').property('toList').call([]),
                  ]),
                ),
              );
            });
          }),
          Method((m) {
            m.name = 'build';
            m.returns = refer('Future<void>');
            m.modifier = MethodModifier.async;
            m.body = Block((b) {
              b.addExpression(
                declareFinal('auth').assign(
                  refer(
                    'di',
                    'package:watch_it/watch_it.dart',
                  ).property('getAsync').call([], {}, [
                    refer(
                      'AuthProvider',
                      'package:$packageName/providers/auth_provider.dart',
                    ),
                  ]).awaited,
                ),
              );
              b.addExpression(
                refer('auth').property('addListener').call([
                  Method((b) {
                    b
                      ..lambda = true
                      ..body =
                          refer('auth')
                              .property('isAuthenticated')
                              .conditional(
                                refer('subscription').assign(
                                  refer(
                                    '_realtime',
                                  ).property('subscribe').call([
                                    refer('_listeners')
                                        .property('keys')
                                        .property('toList')
                                        .call([]),
                                  ]),
                                ),
                                refer('subscription').assign(literalNull),
                              )
                              .code;
                  }).closure,
                ]),
              );
            });
          }),
        ]);
        c.constructors.add(
          Constructor((b) {
            b.requiredParameters.add(
              Parameter((b) {
                b.name = '_realtime';
                b.toThis = true;
              }),
            );
          }),
        );
      }),
    ]);
  });
}

Library providerLibrary(
  String packageName,
  Reference modelReference,
  String databaseId,
  String collectionId,
) => Library((lib) {
  lib.body.addAll([
    Class((c) {
      c.name = '${modelReference.symbol}Provider';
      c.extend = refer('ChangeNotifier', 'package:flutter/foundation.dart');
      c.implements.add(
        TypeReference((b) {
          b
            ..symbol = 'GenericListProvider'
            ..url = 'package:$packageName/providers/generic_list_provider.dart'
            ..types.add(modelReference);
        }),
      );
      c.fields.addAll([
        Field((b) {
          b.name = '_items';
          b.type = TypeReference((b) {
            b
              ..symbol = 'List'
              ..types.add(modelReference);
          });
          b.modifier = FieldModifier.final$;
          b.assignment = literalList([]).code;
        }),
        Field((b) {
          b.name = '_totalItems';
          b.type = refer('int');
          b.assignment = literalNum(0).code;
        }),
      ]);
      c.methods.addAll([
        Method((m) {
          m.name = 'items';
          m.annotations.add(refer('override'));
          m.returns = TypeReference((b) {
            b
              ..symbol = 'List'
              ..types.add(modelReference);
          });
          m.type = MethodType.getter;
          m.lambda = true;
          m.body = literalList([refer('_items').spread]).code;
        }),
        Method((m) {
          m.name = 'hasMore';
          m.annotations.add(refer('override'));
          m.returns = refer('bool');
          m.type = MethodType.getter;
          m.body = refer('_items.length').lessThan(refer('_totalItems')).code;
        }),
        Method((m) {
          m.name = '_fetch';
          m.returns = refer('Future<void>');
          m.modifier = MethodModifier.async;
          m.body = Block((b) {
            b.addExpression(
              declareFinal('result').assign(
                modelReference.property('page').call([], {
                  'offset': refer(
                    '_items',
                  ).property('isEmpty').conditional(literalNum(0), literalNull),
                  'last': refer('_items')
                      .property('isEmpty')
                      .conditional(
                        literalNull,
                        refer('_items').property('last'),
                      ),
                }).awaited,
              ),
            );
            Code('if (result.isSuccess) {');
            b.addExpression(
              refer(
                '_totalItems',
              ).assign(refer('result').property('success').property('\$1')),
            );
            b.addExpression(
              refer('_items').property('addAll').call([
                refer('result').property('success').property('\$2'),
              ]),
            );
            b.addExpression(refer('notifyListeners').call([]));
            Code('}');
          });
        }),
        Method((m) {
          m.name = 'fetchMore';
          m.returns = refer('Future<void>');
          m.modifier = MethodModifier.async;
          m.body = Block((b) {
            b.addExpression(refer('_fetch').call([]).awaited);
          });
        }),
        Method((m) {
          m.name = 'build';
          m.returns = refer('Future<void>');
          m.modifier = MethodModifier.async;
          m.body = Block((b) {
            b.addExpression(refer('_fetch').call([]).awaited);
            b.addExpression(
              declareFinal('realtimeSubscriptions').assign(
                refer(
                  'di',
                  'package:watch_it/watch_it.dart',
                ).property('getAsync').call([], {}, [
                  refer(
                    'RealtimeSubscriptions',
                    'package:$packageName/providers/realtime_subscription.dart',
                  ),
                ]).awaited,
              ),
            );
            b.addExpression(
              refer('realtimeSubscriptions').property('subscribe').call([
                literalString(
                  'databases.$databaseId.collections.$collectionId.documents',
                ),
                Method((b) {
                  b
                    ..requiredParameters.add(
                      Parameter((b) {
                        b.name = 'message';
                      }),
                    )
                    ..body = Block.of([
                      declareFinal('event')
                          .assign(
                            refer('message')
                                .property('events')
                                .property('first')
                                .property('split')
                                .call([literalString('.')])
                                .property('last'),
                          )
                          .statement,
                      Code('switch (event) {'),
                      Code("case 'create':"),
                      refer('_items').property('add').call([
                        modelReference.newInstanceNamed('fromAppwrite', [
                          refer(
                            'Document',
                            'package:appwrite/models.dart',
                          ).newInstanceNamed('fromMap', [
                            refer('message').property('payload'),
                          ]),
                        ]),
                      ]).statement,
                      refer(
                        '_totalItems',
                      ).operatorUnaryPostfixIncrement().statement,
                      Code("case 'update':"),
                      declareFinal('newItem')
                          .assign(
                            modelReference.newInstanceNamed('fromAppwrite', [
                              refer(
                                'Document',
                                'package:appwrite/models.dart',
                              ).newInstanceNamed('fromMap', [
                                refer('message').property('payload'),
                              ]),
                            ]),
                          )
                          .statement,
                      declareFinal('index')
                          .assign(
                            refer('_items').property('indexWhere').call([
                              Method((b) {
                                b
                                  ..lambda = true
                                  ..requiredParameters.add(
                                    Parameter((b) {
                                      b.name = 'item';
                                      b.type = modelReference;
                                    }),
                                  )
                                  ..body =
                                      refer('item')
                                          .property('\$id')
                                          .equalTo(
                                            refer('newItem').property('\$id'),
                                          )
                                          .code;
                              }).closure,
                            ]),
                          )
                          .statement,
                      refer('index')
                          .notEqualTo(literalNum(-1))
                          .conditional(
                            refer(
                              '_items',
                            ).index(refer('index')).assign(refer('newItem')),
                            literalNull,
                          )
                          .statement,
                      Code("case 'delete':"),
                      declareFinal('deletedItem')
                          .assign(
                            modelReference.newInstanceNamed('fromAppwrite', [
                              refer(
                                'Document',
                                'package:appwrite/models.dart',
                              ).newInstanceNamed('fromMap', [
                                refer('message').property('payload'),
                              ]),
                            ]),
                          )
                          .statement,
                      refer('_items').property('removeWhere').call([
                        Method((b) {
                          b
                            ..lambda = true
                            ..requiredParameters.add(
                              Parameter((b) {
                                b.name = 'item';
                                b.type = modelReference;
                              }),
                            )
                            ..body =
                                refer('item')
                                    .property('\$id')
                                    .equalTo(
                                      refer('deletedItem').property('\$id'),
                                    )
                                    .code;
                        }).closure,
                      ]).statement,
                      refer(
                        '_totalItems',
                      ).operatorUnaryPostfixDecrement().statement,
                      Code('}'),
                      refer('notifyListeners').call([]).statement,
                    ]);
                }).closure,
              ]),
            );
          });
        }),
        Method((m) {
          m.name = 'dispose';
          m.returns = refer('void');
          m.annotations.add(refer('override'));
          m.body = Block((b) {
            b.addExpression(
              refer('di', 'package:watch_it/watch_it.dart')
                  .call([], {}, [
                    refer(
                      'RealtimeSubscriptions',
                      'package:$packageName/providers/realtime_subscription.dart',
                    ),
                  ])
                  .property('unsubscribe')
                  .call([
                    literalString(
                      'databases.$databaseId.collections.$collectionId.documents',
                    ),
                    Method((b) {
                      b
                        ..requiredParameters.add(
                          Parameter((b) {
                            b.name = 'message';
                          }),
                        )
                        ..body = Block.of([]);
                    }).closure,
                  ]),
            );
            b.addExpression(refer('super').property('dispose').call([]));
          });
        }),
      ]);
    }),
  ]);
});
