import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff000000),
      surfaceTint: Color(0xff5f5e5e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff1c1b1b),
      onPrimaryContainer: Color(0xff858383),
      secondary: Color(0xff5f5e5e),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffe5e2e1),
      onSecondaryContainer: Color(0xff656464),
      tertiary: Color(0xff000000),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff1c1b1b),
      onTertiaryContainer: Color(0xff868383),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffdf8f8),
      onSurface: Color(0xff1c1b1b),
      onSurfaceVariant: Color(0xff444748),
      outline: Color(0xff747878),
      outlineVariant: Color(0xffc4c7c7),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffc8c6c5),
      primaryFixed: Color(0xffe5e2e1),
      onPrimaryFixed: Color(0xff1c1b1b),
      primaryFixedDim: Color(0xffc8c6c5),
      onPrimaryFixedVariant: Color(0xff474646),
      secondaryFixed: Color(0xffe5e2e1),
      onSecondaryFixed: Color(0xff1c1b1b),
      secondaryFixedDim: Color(0xffc9c6c5),
      onSecondaryFixedVariant: Color(0xff484646),
      tertiaryFixed: Color(0xffe6e1e1),
      onTertiaryFixed: Color(0xff1c1b1b),
      tertiaryFixedDim: Color(0xffcac5c5),
      onTertiaryFixedVariant: Color(0xff484646),
      surfaceDim: Color(0xffddd9d8),
      surfaceBright: Color(0xfffdf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f3f2),
      surfaceContainer: Color(0xfff1edec),
      surfaceContainerHigh: Color(0xffebe7e6),
      surfaceContainerHighest: Color(0xffe5e2e1),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff000000),
      surfaceTint: Color(0xff5f5e5e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff1c1b1b),
      onPrimaryContainer: Color(0xffa8a6a6),
      secondary: Color(0xff373636),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff6e6d6c),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff000000),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff1c1b1b),
      onTertiaryContainer: Color(0xffa9a6a5),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffdf8f8),
      onSurface: Color(0xff111111),
      onSurfaceVariant: Color(0xff333737),
      outline: Color(0xff505354),
      outlineVariant: Color(0xff6a6e6e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffc8c6c5),
      primaryFixed: Color(0xff6e6d6c),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff555454),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff6e6d6c),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff565454),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff6f6c6c),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff565454),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc9c6c5),
      surfaceBright: Color(0xfffdf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f3f2),
      surfaceContainer: Color(0xffebe7e6),
      surfaceContainerHigh: Color(0xffe0dcdb),
      surfaceContainerHighest: Color(0xffd4d1d0),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff000000),
      surfaceTint: Color(0xff5f5e5e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff1c1b1b),
      onPrimaryContainer: Color(0xffd2d0cf),
      secondary: Color(0xff2d2c2c),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff4a4949),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff000000),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff1c1b1b),
      onTertiaryContainer: Color(0xffd4cfcf),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffdf8f8),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff292d2d),
      outlineVariant: Color(0xff464a4a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xffc8c6c5),
      primaryFixed: Color(0xff4a4949),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff333232),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff4a4949),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff333232),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff4b4948),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff343232),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbbb8b7),
      surfaceBright: Color(0xfffdf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f0ef),
      surfaceContainer: Color(0xffe5e2e1),
      surfaceContainerHigh: Color(0xffd7d4d3),
      surfaceContainerHighest: Color(0xffc9c6c5),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffc8c6c5),
      surfaceTint: Color(0xffc8c6c5),
      onPrimary: Color(0xff313030),
      primaryContainer: Color(0xff121212),
      onPrimaryContainer: Color(0xff7e7d7d),
      secondary: Color(0xffc9c6c5),
      onSecondary: Color(0xff313030),
      secondaryContainer: Color(0xff484646),
      onSecondaryContainer: Color(0xffb7b4b4),
      tertiary: Color(0xffcac5c5),
      onTertiary: Color(0xff323030),
      tertiaryContainer: Color(0xff131212),
      onTertiaryContainer: Color(0xff807d7c),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff141313),
      onSurface: Color(0xffe5e2e1),
      onSurfaceVariant: Color(0xffc4c7c7),
      outline: Color(0xff8e9192),
      outlineVariant: Color(0xff444748),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff5f5e5e),
      primaryFixed: Color(0xffe5e2e1),
      onPrimaryFixed: Color(0xff1c1b1b),
      primaryFixedDim: Color(0xffc8c6c5),
      onPrimaryFixedVariant: Color(0xff474646),
      secondaryFixed: Color(0xffe5e2e1),
      onSecondaryFixed: Color(0xff1c1b1b),
      secondaryFixedDim: Color(0xffc9c6c5),
      onSecondaryFixedVariant: Color(0xff484646),
      tertiaryFixed: Color(0xffe6e1e1),
      onTertiaryFixed: Color(0xff1c1b1b),
      tertiaryFixedDim: Color(0xffcac5c5),
      onTertiaryFixedVariant: Color(0xff484646),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff3a3939),
      surfaceContainerLowest: Color(0xff0e0e0e),
      surfaceContainerLow: Color(0xff1c1b1b),
      surfaceContainer: Color(0xff201f1f),
      surfaceContainerHigh: Color(0xff2b2a2a),
      surfaceContainerHighest: Color(0xff353434),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffdfdcdb),
      surfaceTint: Color(0xffc8c6c5),
      onPrimary: Color(0xff262525),
      primaryContainer: Color(0xff929090),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffdfdbdb),
      onSecondary: Color(0xff262525),
      secondaryContainer: Color(0xff929090),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffe0dbdb),
      onTertiary: Color(0xff272525),
      tertiaryContainer: Color(0xff939090),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdadddd),
      outline: Color(0xffafb2b3),
      outlineVariant: Color(0xff8e9191),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff484848),
      primaryFixed: Color(0xffe5e2e1),
      onPrimaryFixed: Color(0xff111111),
      primaryFixedDim: Color(0xffc8c6c5),
      onPrimaryFixedVariant: Color(0xff363636),
      secondaryFixed: Color(0xffe5e2e1),
      onSecondaryFixed: Color(0xff111111),
      secondaryFixedDim: Color(0xffc9c6c5),
      onSecondaryFixedVariant: Color(0xff373636),
      tertiaryFixed: Color(0xffe6e1e1),
      onTertiaryFixed: Color(0xff121111),
      tertiaryFixedDim: Color(0xffcac5c5),
      onTertiaryFixedVariant: Color(0xff373636),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff454444),
      surfaceContainerLowest: Color(0xff080707),
      surfaceContainerLow: Color(0xff1e1d1d),
      surfaceContainer: Color(0xff282827),
      surfaceContainerHigh: Color(0xff333232),
      surfaceContainerHighest: Color(0xff3e3d3d),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff2efef),
      surfaceTint: Color(0xffc8c6c5),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffc5c2c1),
      onPrimaryContainer: Color(0xff0b0b0b),
      secondary: Color(0xfff3efee),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffc5c2c1),
      onSecondaryContainer: Color(0xff0b0b0b),
      tertiary: Color(0xfff4efee),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffc6c2c1),
      onTertiaryContainer: Color(0xff0c0b0b),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffeef0f1),
      outlineVariant: Color(0xffc0c3c3),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff484848),
      primaryFixed: Color(0xffe5e2e1),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffc8c6c5),
      onPrimaryFixedVariant: Color(0xff111111),
      secondaryFixed: Color(0xffe5e2e1),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffc9c6c5),
      onSecondaryFixedVariant: Color(0xff111111),
      tertiaryFixed: Color(0xffe6e1e1),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffcac5c5),
      onTertiaryFixedVariant: Color(0xff121111),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff51504f),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff201f1f),
      surfaceContainer: Color(0xff313030),
      surfaceContainerHigh: Color(0xff3c3b3b),
      surfaceContainerHighest: Color(0xff484646),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.surface,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
