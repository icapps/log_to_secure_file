# log_to_secure_file
A secure way to store and retrieve logs per date.

## How to setup

Create an instance of secure log storage:

```Dart
final storage = SecureLogStorage();
```

Optionally you can also pass some arguments:

```Dart
  final storage = SecureLogStorage(
    providedStorage: storage,
    logsExpireCheckInterval: const Duration(days: 7),
    logsExpireTime: const Duration(days: 7),
  );
```

providedStorage: You can pass your own instance of FlutterSecureStorage.

logsExpireCheckInterval: This is in which interval will be checked if the logs need to be deleted. in the example code every 7 days the package is going to check if logs are expired and will need to be deleted.

logsExpireTime: This decides how old logs can be before they are automatically deleted.

Once you have your instance of SecureLogStorage you'll have to initialize it by calling init before you can use it:

```Dart
storage.init();
```

The init function will also check if there are any out of date logs and will delete them.

## How to use

### Saving logs
When logging something call the method 'storeLogLine' to save this line like this:

```Dart
storage.storeLogLine('This is a test');
```

### Retrieving logs
You can retrieve all the dates that have logs on them by using 'availableDates'.

```Dart
storage.availableDates();
```

You can then use this date to retrieve the actual stored logs by using 'getLogFromDate'.

```Dart
final dates = storage.availableDates();
storage.getLogFromDate(dates.first);
```

### Deleting logs
If you want to delete all stored logs you can call 'deleteLogs'.

```Dart
storage.deleteLogs();
```

### Disposing
To dispose of the object and also stop the automatic checking of out of date logs call 'dispose'.

```Dart
storage.dispose();
```