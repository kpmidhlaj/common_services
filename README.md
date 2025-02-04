# common_services

A Flutter plugin for common services such as API handling, local storage, Firebase Cloud Messaging (FCM), and more. This plugin provides reusable components for handling API calls, storing data locally, and managing notifications, allowing for easy integration across multiple Flutter projects.

## Features

- **API Service**: Provides methods for making network requests using Dio.
- **Local Storage**: Simple wrapper around `SharedPreferences` for storing and retrieving key-value pairs.
- **Firebase Cloud Messaging (FCM)**: Handles Firebase Cloud Messaging (FCM) notifications, including background and foreground notifications.

## Installation

### 1. Add Dependency to `pubspec.yaml`

To add `common_services` to your Flutter project, add the following dependency in your project's `pubspec.yaml`:

```yaml
dependencies:
  common_services:
    git:
      url: https://github.com/kpmidhlaj/common_services.git
