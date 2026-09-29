import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:product_catalog/config/api_config.dart';
import 'package:product_catalog/models/product.dart';
import 'package:product_catalog/services/api_client.dart';
import 'package:product_catalog/services/product_service.dart';
import 'package:product_catalog/stores/product_detail_store.dart';
import 'package:product_catalog/stores/product_list_store.dart';
import 'package:product_catalog/stores/theme_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

/// Registers the app's dependencies. Call once before `runApp`.
Future<void> setupLocator() async {
  final prefs = await SharedPreferences.getInstance();
  final packageInfo = await PackageInfo.fromPlatform();

  getIt
    ..registerLazySingleton<http.Client>(
      http.Client.new,
      dispose: (client) => client.close(),
    )
    ..registerLazySingleton<ApiClient>(() => ApiClient(client: getIt()))
    ..registerLazySingleton<ProductService>(() => ProductServiceImpl(getIt()))
    ..registerSingleton<ThemeStore>(ThemeStore(prefs))
    ..registerSingleton<PackageInfo>(packageInfo)
    // Screens own these stores and dispose them, so each gets a new one.
    ..registerFactory<ProductListStore>(
      () => ProductListStore(
        getIt(),
        pageSize: ApiConfig.pageSize,
        searchDebounce: ApiConfig.searchDebounce,
      ),
    )
    ..registerFactoryParam<ProductDetailStore, Product, void>(
      (preview, _) => ProductDetailStore(getIt(), preview),
    );
}
