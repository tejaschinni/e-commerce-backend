# Riverpod Guide

A reference for how Riverpod works, every provider/widget type it ships, and
how this repo's `profile_form` feature uses them. Package in use here:
`flutter_riverpod: ^2.6.1` (manual API, **no** `riverpod_generator` /
`build_runner` - see [Why no code generation](#why-no-code-generation) at the
end).

---

## 1. The core idea

Riverpod is a dependency-injection + state-management system built around
**providers**: top-level, global objects that declare *how to create a
value* and cache it. Widgets don't fetch data or hold business logic
themselves - they watch a provider and rebuild when its value changes.

```
ProviderScope (root)
  -> holds a ProviderContainer (the actual registry of provider instances)
      -> Provider A (e.g. the repository)
      -> Provider B depends on Provider A via ref.watch(providerA)
          -> Widget watches Provider B, rebuilds when B changes
```

Three things make this work:
1. **`ProviderScope`** - a widget you put above `MaterialApp` that owns the
   container every provider lives in.
2. **Providers** - global `final` variables describing a piece of state and
   how to build it.
3. **`Ref`** (inside providers/notifiers) and **`WidgetRef`** (inside
   widgets) - the handle used to read/watch/invalidate providers.

Nothing is a singleton in the classic sense - everything is scoped to the
`ProviderContainer`, which is why tests can spin up an isolated container
per test (see [Testing](#8-testing-with-riverpod)).

---

## 2. Setup widgets

| Widget | Purpose | Used here? |
|---|---|---|
| `ProviderScope` | Root widget that creates the `ProviderContainer`. Required once, above `MaterialApp`. | [lib/main.dart](lib/main.dart) |
| `UncontrolledProviderScope` | Like `ProviderScope`, but wraps a `ProviderContainer` you created yourself. Used when integrating Riverpod into an app that already manages its own container (rare). | not used |
| `ProviderScope(overrides: [...])` | Same widget, but lets you swap a provider's implementation - the standard way to inject mocks/fakes for tests or different environments (dev/staging). | not used yet, available for tests |

---

## 3. Provider types

A "provider" is just a top-level `final` value. Which constructor you use
determines what shape of state it holds and whether it's sync, async, or
mutable.

| Provider | Holds | Read as | When to use |
|---|---|---|---|
| `Provider<T>` | A plain, read-only value (often computed from other providers). | `T` | Dependency injection: repositories, data sources, config, derived/computed values. |
| `StateProvider<T>` | A single mutable primitive/small value. | `T`, settable via `.state = x` | Simple UI state with no business logic: a filter, a toggle, a selected tab index. |
| `StateNotifierProvider<N, T>` | A `StateNotifier<T>` subclass. | `T` | **Legacy** - the pre-2.0 way to write a class with methods that mutate immutable state. Superseded by `Notifier`. Not used in this repo. |
| `NotifierProvider<N extends Notifier<T>, T>` | A `Notifier<T>` subclass. | `T` | Synchronous state with methods (replacement for `StateNotifierProvider`). |
| `FutureProvider<T>` | The result of a one-shot `Future<T>`. | `AsyncValue<T>` | A single async fetch with no further mutation methods needed (e.g. "load this config once"). |
| `StreamProvider<T>` | The latest value of a `Stream<T>`. | `AsyncValue<T>` | Subscribing to a live stream (websocket, Firestore snapshot, etc). |
| `AsyncNotifierProvider<N extends AsyncNotifier<T>, T>` | An `AsyncNotifier<T>` subclass whose `build()` is async. | `AsyncValue<T>` | Async initial load **plus** mutation methods afterwards - the controller needs to both fetch and later act (save/submit/upload). **This is what `FormController` uses.** |

### Modifiers

Every provider above can be combined with:

- **`.autoDispose`** - the provider is destroyed (state discarded) once its
  last listener unsubscribes, instead of living for the app's lifetime.
  Use it for anything screen-scoped (form state, a detail page's data) so
  memory/mock-backend state doesn't leak once the user navigates away.
- **`.family`** - parameterizes the provider with an argument, so
  `provider(arg)` gives you a distinct, independently-cached instance per
  `arg`. Use it whenever the data depends on an id (`userId`, `postId`, ...).

Both modifiers can be stacked: `AsyncNotifierProvider.autoDispose.family<...>`.
Each combination has its own base class name for the notifier you extend,
because Dart doesn't support optional generic mixins cleanly:

| Provider declaration | Notifier base class to extend |
|---|---|
| `NotifierProvider<N, T>` | `Notifier<T>` |
| `NotifierProvider.autoDispose<N, T>` | `AutoDisposeNotifier<T>` |
| `NotifierProvider.family<N, T, Arg>` | `FamilyNotifier<T, Arg>` |
| `NotifierProvider.autoDispose.family<N, T, Arg>` | `AutoDisposeFamilyNotifier<T, Arg>` |
| `AsyncNotifierProvider<N, T>` | `AsyncNotifier<T>` |
| `AsyncNotifierProvider.autoDispose<N, T>` | `AutoDisposeAsyncNotifier<T>` |
| `AsyncNotifierProvider.family<N, T, Arg>` | `FamilyAsyncNotifier<T, Arg>` |
| `AsyncNotifierProvider.autoDispose.family<N, T, Arg>` | **`AutoDisposeFamilyAsyncNotifier<T, Arg>`** <- used here |

---

## 4. Widgets that *read* providers

| Widget | Analogous to | Gives you | Used here? |
|---|---|---|---|
| `ConsumerWidget` | `StatelessWidget` | `build(BuildContext context, WidgetRef ref)` | not used (we need `State` for `TextEditingController`s) |
| `ConsumerStatefulWidget` + `ConsumerState<T>` | `StatefulWidget` + `State<T>` | `ref` available anywhere in the `State`, including `initState`/`dispose` | **`FormScreen`** - [form_screen.dart](lib/features/profile_form/presentation/views/form_screen.dart) |
| `Consumer` | - | A builder widget: `Consumer(builder: (context, ref, child) => ...)`. Lets you scope a rebuild to a small subtree inside an otherwise plain `StatelessWidget`/`StatefulWidget`, instead of converting the whole widget. | not used (the whole screen already rebuilds off one provider) |
| `ConsumerWidget`/`ConsumerStatefulWidget` + `HookConsumerWidget` (from the separate `hooks_riverpod` package) | - | Combines Riverpod with `flutter_hooks`. | not a dependency of this project |

---

## 5. `Ref` / `WidgetRef` - the API you call

`WidgetRef` (in widgets) and `Ref` (inside providers/notifiers) expose the
same core methods:

| Method | What it does | Where you call it |
|---|---|---|
| `ref.watch(provider)` | Subscribes: rebuilds the widget / recomputes the provider whenever the watched provider changes. | Inside `build()` only. |
| `ref.read(provider)` | One-off read, no subscription. | Inside callbacks (`onPressed`, etc). **Never in `build()`** - you'd miss future updates. |
| `ref.read(provider.notifier)` | Grabs the notifier instance itself (not its state) so you can call its methods. | Callbacks, e.g. `notifier.saveDraft()`. |
| `ref.listen(provider, (prev, next) {...})` | Runs a callback on every change *without* causing a rebuild - for side effects like showing a `SnackBar` or navigating. | Inside `build()` of a `Consumer*` widget, or `ref.listenManual(...)` outside of one. |
| `ref.invalidate(provider)` | Throws away the cached value and forces a rebuild next time it's read/watched. | Anywhere with a `Ref`. |
| `ref.refresh(provider)` | `invalidate` + immediately `read` the fresh value. | Anywhere with a `Ref`. |
| `ref.onDispose(() {...})` | Registers cleanup logic (close streams, cancel timers) for when the provider is destroyed. | Inside a provider/notifier's `build`. |
| `ref.keepAlive()` | Called inside an `autoDispose` provider to opt it out of disposal once (returns a `KeepAliveLink`; call `.close()` on it to re-enable auto-disposal later). Typically used to cache the result of a one-off future even after listeners drop. | Inside an `autoDispose` provider. |
| `ref.mounted` | `true` until the provider/notifier is disposed. Check this after an `await` inside a notifier method before touching `state`, in case the provider was torn down while you were waiting. | Inside a notifier, after an `await`. |
| `provider.select((value) => value.field)` | Narrows a `watch`/`listen` subscription to one field, so the widget only rebuilds when *that field* changes, not on every state change. | `ref.watch(provider.select(...))`. |

### `ref.watch` vs `ref.read` - the one rule that matters

- `build()` methods: always `ref.watch`.
- Event handlers / anything outside `build()`: always `ref.read`.

Using `ref.read` inside `build()` is the single most common Riverpod bug -
the widget silently stops reacting to changes.

---

## 6. `AsyncValue<T>` - async state, unpacked

Every `FutureProvider`, `StreamProvider`, and `AsyncNotifierProvider` exposes
its state as `AsyncValue<T>`, a union of three cases:

- `AsyncLoading<T>` - in flight, no data yet (or a refresh is happening).
- `AsyncData<T>` - has a value (`.value`).
- `AsyncError<T>` - threw (`.error`, `.stackTrace`).

How to consume it:

| API | Behavior |
|---|---|
| `asyncValue.when(loading: ..., error: ..., data: ...)` | Exhaustive pattern match - must handle all three. **Used in `FormScreen.build()`** to render a spinner / error text / the form. |
| `asyncValue.whenOrNull(data: ...)` | Like `when`, but every branch is optional and unhandled cases return `null`. |
| `asyncValue.maybeWhen(orElse: ..., data: ...)` | Like `whenOrNull` but with a required fallback instead of `null`. |
| `asyncValue.valueOrNull` | The data if present, else `null` - regardless of loading/error. **Used throughout `FormController`** (e.g. `state.valueOrNull`) to peek at the current state without a full `when`. |
| `asyncValue.requireValue` | The data, or throws if there isn't any yet. Handy in tests once you know loading has finished. |
| `asyncValue.hasValue` / `.isLoading` / `.hasError` | Quick boolean checks. |
| `asyncValue.isRefreshing` | `true` when a *new* load is happening while old data is still showing (e.g. after `ref.refresh`) - lets you show a subtle spinner over existing content instead of blanking the screen. |

---

## 7. How this repo actually uses it

File: [form_controller.dart](lib/features/profile_form/presentation/controllers/form_controller.dart)

```dart
final formLocalDataSourceProvider = Provider<FormLocalDataSource>((ref) {
  return FormLocalDataSource();
});
```
A plain `Provider` with no modifier -> lives for the app's entire lifetime
(no `.autoDispose`). It's the mock "backend"; if it got disposed and
recreated every time the form screen closed, saved drafts would vanish.

```dart
final formRepositoryProvider = Provider<FormRepository>((ref) {
  return FormRepositoryImpl(ref.watch(formLocalDataSourceProvider));
});
```
Another plain `Provider`. `ref.watch` here wires the dependency graph: if
`formLocalDataSourceProvider` were ever overridden (e.g. in a test), this
provider automatically rebuilds with the new instance.

```dart
final formControllerProvider = AsyncNotifierProvider.autoDispose
    .family<FormController, ProfileFormState, String>(FormController.new);

class FormController extends AutoDisposeFamilyAsyncNotifier<ProfileFormState, String> {
  @override
  FutureOr<ProfileFormState> build(String userId) async { ... }
  ...
}
```
- `.family<..., String>` - keyed by `userId`, so `formControllerProvider('alice')`
  and `formControllerProvider('bob')` are two completely independent,
  separately-cached controllers.
- `.autoDispose` - the moment `FormScreen` for a given `userId` is popped
  and nothing else is watching that provider, its state (and the pending
  draft) is thrown away, matching "leaving the screen resets the session."
- `build(String userId)` is `async` and calls the repository's
  `getDetails`/`getUploadedImage` - this is the initial `AsyncLoading` ->
  `AsyncData`/`AsyncError` transition `FormScreen` renders with `.when(...)`.
- Every mutating method (`saveDraft`, `submit`, `pickImage`, field updates)
  reads `state.valueOrNull`, derives a new `ProfileFormState`, and assigns
  `state = AsyncData(newState)` - that reassignment is what notifies every
  widget watching the provider to rebuild.

File: [form_screen.dart](lib/features/profile_form/presentation/views/form_screen.dart)

```dart
class FormScreen extends ConsumerStatefulWidget { ... }
class _FormScreenState extends ConsumerState<FormScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = formControllerProvider(widget.userId); // resolve the family member
    final asyncState = ref.watch(provider);                 // subscribe -> rebuild on change
    final notifier = ref.read(provider.notifier);            // get the controller, don't subscribe to it directly

    ref.listen(provider, (previous, next) {                  // side effects: SnackBars
      ...
    });

    return Scaffold(
      body: asyncState.when(                                  // unpack AsyncValue
        loading: () => const CircularProgressIndicator(),
        error: (e, st) => Text('Failed to load form: $e'),
        data: (state) => _FormBody(state: state, notifier: notifier, ...),
      ),
    );
  }
}
```
`ConsumerStatefulWidget` was chosen over `ConsumerWidget` specifically
because the screen owns `TextEditingController`s that must survive rebuilds
and be disposed in `State.dispose()` - a plain `ConsumerWidget` has no
`dispose()` hook.

---

## 8. Testing with Riverpod

`ProviderContainer` is a `ProviderScope` without the widget tree - create
one directly in a plain `test(...)` (not `testWidgets`) to exercise a
notifier in isolation:

```dart
final container = ProviderContainer();
addTearDown(container.dispose);
```

**Gotcha this repo actually hit:** `.autoDispose` providers tear themselves
down the instant they have *zero* listeners - and `container.read(...)` does
not count as a standing listener. Calling `read` twice with an `await` in
between can silently dispose and re-create the notifier (state resets to
`AsyncLoading`). Fix: hold a no-op listener for the test's duration:

```dart
container.listen(formControllerProvider('user'), (prev, next) {});
```
See [test/widget_test.dart](test/widget_test.dart) for the working version.

For widget tests, override providers with fakes via
`ProviderScope(overrides: [formRepositoryProvider.overrideWithValue(FakeRepo())], child: ...)`
- not needed in this repo since the "mock backend" already behaves like a
  real one, but it's the standard way to swap in test doubles.

A `ProviderObserver` can be passed to `ProviderScope`/`ProviderContainer` to
log every provider add/update/dispose - useful for debugging but not wired
up here.

---

## 9. Why no code generation

Riverpod also ships a `@riverpod` annotation (`riverpod_annotation` +
`riverpod_generator` + `build_runner`) that generates the provider
boilerplate above for you - e.g. `@riverpod class FormController extends
_$FormController` would generate `formControllerProvider` and the right
`AutoDispose...` base class automatically, inferring `.family`/`.autoDispose`
from the method signature instead of you choosing the provider constructor
by hand.

This project intentionally uses the **manual** API instead:

1. It was explicitly requested (no `build_runner` step).
2. `riverpod_generator`'s bundled `analyzer` version doesn't yet understand
   Dart 3.13's new dot-shorthand syntax (`ColorScheme.fromSeed` written as
   `.fromSeed(...)`), which crashed the generator on this SDK version during
   initial setup.

Functionally the two approaches produce the same runtime objects - codegen
is sugar over exactly the classes documented in [section 3](#3-provider-types).
