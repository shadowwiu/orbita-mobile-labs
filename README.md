# Орбита · лабораторные 1–4

**Понькин Егор Валерьевич · ПИбд-33**<br>
Дисциплина: мобильная разработка. Flutter + Dart, целевая платформа Android.

«Орбита» — небольшой космический атлас с шестью небесными телами. Каталог, поиск, категории, избранное и подробности работают без интернета. Изображения включены в assets: пять предоставлены автором проекта, снимок Нептуна — NASA/JPL-Caltech ([источник](https://science.nasa.gov/image-detail/pia01492-neptune-full-disk-16x9/)).

[Скачать APK](https://github.com/shadowwiu/orbita-mobile-labs/releases/latest) · [Описание для защиты](LAB_REPORT.md)

## Соответствие заданиям

| Работа | Реализация |
| --- | --- |
| ЛР 1 | Flutter-проект с Android; ФИО и группа в AppBar; сборка и запуск на Android; публичный Git-репозиторий |
| ЛР 2 | Консольный каталог на Dart: классы, enum, циклы, generics, анонимные функции, Future, extension |
| ЛР 3 | Прокручиваемый список Card, у каждой карточки есть название, подпись и локальное изображение |
| ЛР 4 | Сердце переключает лайк; Snackbar сообщает о результате и позволяет отменить действие; нажатие на карточку открывает отдельный экран |

Дополнительно: поиск без учёта регистра и различия «е/ё», фильтры планет и спутников, вкладка избранного, счётчик сохранённых объектов, состояния загрузки, ошибки и пустого результата.

**Лайки хранятся в памяти приложения:** переходы между экранами их сохраняют, полный перезапуск приложения очищает избранное. Постоянное хранение не требуется заданием.

## Запуск

Для проверенной конфигурации использованы Flutter 3.47.8, Dart 3.13.7, JDK 21, Android SDK 36 и эмулятор Android 15 / API 35. Установите Flutter SDK и VS Code с расширением Dart-Code.flutter либо Android Studio с плагином Flutter.

На Windows удобнее клонировать проект в обычную папку без кириллицы, например `C:\dev\orbita-labs`. OneDrive может блокировать временные файлы сборки и тестов.

```powershell
git clone https://github.com/shadowwiu/orbita-mobile-labs.git
cd orbita-mobile-labs
flutter pub get
flutter doctor
flutter devices
flutter run -d <идентификатор-Android-устройства>
```

На подготовленном компьютере уже есть эмулятор `Orbita_API_35`:

```powershell
flutter emulators --launch Orbita_API_35
flutter run -d emulator-5554
```

Дождитесь завершения загрузки Android перед `flutter run`. Вместо эмулятора можно использовать телефон с включённой отладкой по USB. Идентификатор смотрите в `flutter devices`.

Для дополнительной проверки интерфейса в браузере:

```powershell
flutter run -d chrome
```

В VS Code также есть две конфигурации F5: «Орбита — Flutter» и «Лабораторная 2 — Dart».

## Лабораторная 2 отдельно

```powershell
dart run bin/lab2.dart
dart run bin/lab2.dart Марс
dart run bin/lab2.dart гигант
```

Программа асинхронно читает JSON, фильтрует объекты, выводит их характеристики и количество планет-гигантов в выборке.

На эмуляторе тот же результат доступен по кнопке «ЛР 2» в шапке приложения. Для запуска сразу на этом экране используйте `flutter run -d emulator-5554 -t lib/lab2_main.dart`. Экран и консоль используют общую логику `lib/data/catalog_report.dart`.

| Конструкция | Где смотреть | Что делает |
| --- | --- | --- |
| Класс с полями и методами | `lib/models/space_object.dart`, `SpaceObject` | Хранит данные, выполняет поиск `matches()` и составляет строку `summary()` |
| Enum | `SpaceObjectType` в той же модели | Ограничивает тип объекта: rocky, giant, satellite |
| Цикл | `for (final object in found)` в `lib/data/catalog_report.dart` | Формирует строку для каждого найденного объекта |
| Generics | `List<SpaceObject>`, `List<String>` | Задаёт тип элементов коллекции |
| Anonymous functions | `where((object) => ...)` в `catalog_report.dart`, `map((item) => ...)` в репозитории | Фильтрует объекты и преобразует JSON в модели |
| Future | `Future<List<SpaceObject>> load()` в `lib/data/catalog_repository.dart` | Возвращает результат асинхронного чтения; вызывается через `await` |
| extension | `SpaceObjectTypeLabel`, `Kilometers` в модели | Добавляет подпись enum и форматирование диаметра |

Пример вывода при поиске Марса:

```text
ОРБИТА · Каталог небесных тел
Понькин Егор Валерьевич · ПИбд-33
Найдено объектов: 1
Марс — Каменистая планета, диаметр: 6 779 км
Планет-гигантов в выборке: 0
```

## Как показать ЛР 3 и ЛР 4

1. Открыть каталог и прокрутить карточки. В каждой есть изображение и текст.
2. Нажать на сердце у Земли. Сердце заполнится, появится Snackbar.
3. Нажать «Отменить» в Snackbar: лайк снимается.
4. Снова поставить лайк и открыть «Избранное»: там появится Земля.
5. Нажать на карточку. Откроются описание, диаметр, длительность суток, температура и факты.
6. Изменить лайк на экране подробностей и вернуться назад. Состояние карточки синхронизируется.
7. Ввести «Марс» в поиск; затем очистить поиск и выбрать «Спутники».

Если Snackbar временно перекрывает кнопку, его можно смахнуть вниз или дождаться скрытия.

## Структура

```text
lib/main.dart                  приложение, каталог, карточки, подробности
lib/catalog_controller.dart    загрузка данных и общее состояние лайков
lib/models/space_object.dart   модель, enum и extensions
lib/data/catalog_repository.dart  асинхронное чтение и разбор каталога
bin/lab2.dart                  самостоятельная консольная программа Dart
assets/data/space_objects.json данные шести объектов
assets/images/                 изображения, доступные без интернета
android/                       Android-проект
web/                           дополнительная веб-платформа
test/                          11 проверок логики и интерфейса
integration_test/app_test.dart сценарий проверки на Android
test_driver/integration_test.dart сохранение скриншотов на компьютере
screenshots/                   скриншоты предыдущей версии приложения
tools/                         генераторы иллюстраций и иконки
LAB_REPORT.md                  краткое описание для защиты
```

Лайки находятся в одном `CatalogController`, поэтому список, счётчик избранного и экран подробностей используют одно состояние. Изменение состояния вызывает `notifyListeners()`, а `ListenableBuilder` обновляет интерфейс. Переход выполнен через `Navigator.push()` и `MaterialPageRoute`.

Загрузчик каталога передаётся в `CatalogRepository` как функция. В Flutter он читает `rootBundle`, в консольной программе — файл через `dart:io`. Модель и обработка JSON общие.

## Проверки и сборка

```powershell
dart format --output=none --set-exit-if-changed lib bin test integration_test
flutter analyze
flutter test
flutter test integration_test/app_test.dart -d emulator-5554
flutter build apk --release
```

Готовый APK появляется в `build/app/outputs/flutter-apk/app-release.apk`. Для учебной установки release-конфигурация использует отладочный ключ из шаблона Flutter.

Проверено 29.10.2026: анализатор без замечаний; 11 тестов модели и интерфейса прошли; сценарий на Android-эмуляторе прошёл. Приложение установлено и запущено на эмуляторе API 35.

Чтобы повторно сохранить скриншоты Android в папку `screenshots/`:

```powershell
flutter drive --driver test_driver/integration_test.dart --target integration_test/app_test.dart -d emulator-5554
```

Ветки и теги: `lab1` — начальный Flutter-проект; `lab2` — консольная программа Dart; `lab3` и `lab4` — итоговый каталог с интерактивными карточками.

## Материалы

- [Установка Flutter](https://docs.flutter.dev/install/manual)
- [Настройка Android](https://docs.flutter.dev/platform-integration/android/setup)
- [Dart: классы](https://dart.dev/language/classes), [Future и async/await](https://dart.dev/libraries/async/async-await), [extensions](https://dart.dev/language/extension-methods)
- [NASA: Солнечная система](https://science.nasa.gov/solar-system/) — справочная информация; числовые значения в учебном каталоге округлены.

Генераторы картинок нужны только для изменения иллюстраций; обычный запуск приложения не требует Python.
