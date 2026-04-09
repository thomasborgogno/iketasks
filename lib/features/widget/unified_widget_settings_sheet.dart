part of '../tasks/presentation/matrix_page.dart';

// ---------------------------------------------------------------------------
// Unified Widget Settings Sheet - Supports both Matrix (5x5) and Minimal (4x1)
// ---------------------------------------------------------------------------

class _UnifiedWidgetSettingsSheet extends StatefulWidget {
  const _UnifiedWidgetSettingsSheet({
    required this.matrixService,
    required this.minimalService,
  });

  final WidgetAppearanceService matrixService;
  final MinimalWidgetSyncService minimalService;

  @override
  State<_UnifiedWidgetSettingsSheet> createState() =>
      _UnifiedWidgetSettingsSheetState();
}

class _UnifiedWidgetSettingsSheetState
    extends State<_UnifiedWidgetSettingsSheet> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Center(
                child: Text(
                  l10n.widgetAppearance,
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TabBar(
              tabs: [
                Tab(icon: const Icon(Icons.grid_on), text: l10n.matrixWidget),
                Tab(
                  icon: const Icon(Icons.view_stream_outlined),
                  text: l10n.minimalWidget,
                ),
              ],
            ),
            Flexible(
              child: TabBarView(
                children: [
                  _MatrixWidgetSettings(service: widget.matrixService),
                  _MinimalWidgetSettings(service: widget.minimalService),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Matrix Widget Settings (5x5) - Original appearance settings
// ---------------------------------------------------------------------------

class _MatrixWidgetSettings extends StatefulWidget {
  const _MatrixWidgetSettings({required this.service});

  final WidgetAppearanceService service;

  @override
  State<_MatrixWidgetSettings> createState() => _MatrixWidgetSettingsState();
}

class _MatrixWidgetSettingsState extends State<_MatrixWidgetSettings> {
  late WidgetAppearanceSettings _settings;
  bool _themeDefaultApplied = false;

  static const _bgPresetsDark = <int>[
    0xFF1A2A3A, // Blu Navy
    0xFF1B3329, // Verde Bosco
    0xFF2E1A47, // Viola Navy
    0xFF4A1F2D, // Borgogna
    0xFF2D3018, // Verde Oliva
    0xFF3C3C3C, // Grigio Antracite
  ];

  static const _bgPresetsLight = <int>[
    0xFFD1E3F5, // Blu Cielo
    0xFFD5EDDB, // Verde Menta
    0xFFE1D5F5, // Lavanda
    0xFFF5D5DC, // Rosa Antico
    0xFFE9EDD5, // Lime Pallido
    0xFFE5E5E5, // Grigio Perla
  ];

  static const _quadrantOrder = ['q1', 'q2', 'q3', 'q4'];

  @override
  void initState() {
    super.initState();
    _settings = widget.service.current;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_themeDefaultApplied) {
      _themeDefaultApplied = true;
      if (_settings.bgColorValue ==
              WidgetAppearanceSettings.defaults().bgColorValue &&
          _settings.themeMode == WidgetThemeMode.system) {
        _settings = _settings.copyWith(
          bgColorValue: _scaffoldBgForMode(WidgetThemeMode.system),
        );
      }
    }
  }

  int _scaffoldBgForMode(WidgetThemeMode mode) {
    switch (mode) {
      case WidgetThemeMode.dark:
        return 0xFF1C1B1F;
      case WidgetThemeMode.light:
        return 0xFFF6F9FB;
      case WidgetThemeMode.system:
        return Theme.of(context).scaffoldBackgroundColor.toARGB32();
    }
  }

  bool _isDarkMode(WidgetThemeMode mode) {
    if (mode == WidgetThemeMode.dark) return true;
    if (mode == WidgetThemeMode.light) return false;
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }

  List<int> _presetsForMode(WidgetThemeMode mode) =>
      _isDarkMode(mode) ? _bgPresetsDark : _bgPresetsLight;

  WidgetTextColor _defaultTextColorForMode(WidgetThemeMode mode) =>
      _isDarkMode(mode) ? WidgetTextColor.white : WidgetTextColor.black;

  void _onThemeModeChanged(WidgetThemeMode newMode) {
    final newBgColor = newMode == WidgetThemeMode.system
        ? _scaffoldBgForMode(newMode)
        : _settings.bgColorValue;
    setState(() {
      _settings = _settings.copyWith(
        themeMode: newMode,
        bgColorValue: newBgColor,
        textColor: _defaultTextColorForMode(newMode),
      );
    });
  }

  Future<void> _save() async {
    await widget.service.save(_settings);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.widgetUpdated)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final alphaPercent = ((_settings.bgAlpha / 255) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Theme ────────────────────────────────────────────────────
                Text(l10n.theme, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Center(
                  child: SegmentedButton<WidgetThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: WidgetThemeMode.system,
                        label: Text(l10n.systemTheme),
                        icon: const Icon(Icons.brightness_auto_outlined),
                      ),
                      ButtonSegment(
                        value: WidgetThemeMode.light,
                        label: Text(l10n.lightTheme),
                        icon: const Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment(
                        value: WidgetThemeMode.dark,
                        label: Text(l10n.darkTheme),
                        icon: const Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                    selected: {_settings.themeMode},
                    onSelectionChanged: (s) => _onThemeModeChanged(s.first),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Background ──────────────────────────────────────────────────
                Text(
                  l10n.background,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Opacity(
                  opacity: _settings.themeMode == WidgetThemeMode.system
                      ? 0.35
                      : 1.0,
                  child: IgnorePointer(
                    ignoring: _settings.themeMode == WidgetThemeMode.system,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children:
                          [
                            _scaffoldBgForMode(_settings.themeMode),
                            ..._presetsForMode(_settings.themeMode),
                          ].map((colorValue) {
                            final isSelected =
                                _settings.bgColorValue == colorValue;
                            return GestureDetector(
                              onTap: () => setState(
                                () => _settings = _settings.copyWith(
                                  bgColorValue: colorValue,
                                ),
                              ),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Color(0xFF000000 | colorValue),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withAlpha(120),
                                            blurRadius: 8,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(l10n.transparency(alphaPercent)),
                    Expanded(
                      child: Slider(
                        min: 128,
                        max: 255,
                        divisions: 127,
                        value: _settings.bgAlpha.toDouble(),
                        onChanged: (v) => setState(
                          () => _settings = _settings.copyWith(
                            bgAlpha: v.round(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Text Size ────────────────────────────────────────────────────
                Text(
                  l10n.textSize,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Center(
                  child: SegmentedButton<WidgetTextSize>(
                    segments: [
                      ButtonSegment(
                        value: WidgetTextSize.small,
                        label: Text(l10n.small),
                      ),
                      ButtonSegment(
                        value: WidgetTextSize.medium,
                        label: Text(l10n.medium),
                      ),
                      ButtonSegment(
                        value: WidgetTextSize.large,
                        label: Text(l10n.large),
                      ),
                    ],
                    selected: {_settings.textSize},
                    onSelectionChanged: (s) => setState(
                      () => _settings = _settings.copyWith(textSize: s.first),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Text Color ────────────────────────────────────────────────────
                Text(
                  l10n.textColor,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Center(
                  child: SegmentedButton<WidgetTextColor>(
                    segments: [
                      ButtonSegment(
                        value: WidgetTextColor.white,
                        label: Text(l10n.white),
                      ),
                      ButtonSegment(
                        value: WidgetTextColor.black,
                        label: Text(l10n.black),
                      ),
                    ],
                    selected: {_settings.textColor},
                    onSelectionChanged: (s) => setState(
                      () => _settings = _settings.copyWith(textColor: s.first),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Quadrants ────────────────────────────────────────────────────
                Text(
                  l10n.quadrants,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ..._quadrantOrder.map((q) {
                  final quadrant = EisenhowerQuadrantX.fromValue(q);
                  final isVisible = _settings.visibleQuadrants.contains(q);
                  return CheckboxListTile(
                    value: isVisible,
                    title: Text(
                      '${quadrant.name(context)} (${quadrant.description(context)})',
                    ),
                    onChanged: (val) {
                      final updated = Set<String>.from(
                        _settings.visibleQuadrants,
                      );
                      if (val == true) {
                        updated.add(q);
                      } else {
                        updated.remove(q);
                      }
                      setState(
                        () => _settings = _settings.copyWith(
                          visibleQuadrants: updated,
                        ),
                      );
                    },
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _save, child: Text(l10n.save)),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Minimal Widget Settings (4x1)
// ---------------------------------------------------------------------------

class _MinimalWidgetSettings extends StatefulWidget {
  const _MinimalWidgetSettings({required this.service});

  final MinimalWidgetSyncService service;

  @override
  State<_MinimalWidgetSettings> createState() => _MinimalWidgetSettingsState();
}

class _MinimalWidgetSettingsState extends State<_MinimalWidgetSettings> {
  late MinimalWidgetSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.service.currentSettings;
  }

  Future<void> _save() async {
    await widget.service.saveSettings(_settings);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.widgetUpdated)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Number of Tasks ────────────────────────────────────────────
                Text(
                  l10n.numberOfTasks,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Slider(
                  min: 1,
                  max: 5,
                  divisions: 4,
                  value: _settings.taskCount.toDouble(),
                  label: _settings.taskCount.toString(),
                  onChanged: (v) => setState(
                    () => _settings = _settings.copyWith(taskCount: v.round()),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${_settings.taskCount} ${_settings.taskCount == 1 ? l10n.task : l10n.tasks}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Text Color ────────────────────────────────────────────────
                Text(
                  l10n.textColor,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Center(
                  child: SegmentedButton<MinimalWidgetTextColor>(
                    segments: [
                      ButtonSegment(
                        value: MinimalWidgetTextColor.white,
                        label: Text(l10n.white),
                      ),
                      ButtonSegment(
                        value: MinimalWidgetTextColor.black,
                        label: Text(l10n.black),
                      ),
                    ],
                    selected: {_settings.textColor},
                    onSelectionChanged: (s) => setState(
                      () => _settings = _settings.copyWith(textColor: s.first),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Text Size ────────────────────────────────────────────────
                Text(
                  l10n.textSize,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Center(
                  child: SegmentedButton<MinimalWidgetTextSize>(
                    segments: [
                      ButtonSegment(
                        value: MinimalWidgetTextSize.small,
                        label: Text(l10n.small),
                      ),
                      ButtonSegment(
                        value: MinimalWidgetTextSize.medium,
                        label: Text(l10n.medium),
                      ),
                      ButtonSegment(
                        value: MinimalWidgetTextSize.large,
                        label: Text(l10n.large),
                      ),
                    ],
                    selected: {_settings.textSize},
                    onSelectionChanged: (s) => setState(
                      () => _settings = _settings.copyWith(textSize: s.first),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Text Alignment ────────────────────────────────────────────
                Text(
                  l10n.textAlignment,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Center(
                  child: SegmentedButton<MinimalWidgetTextAlignment>(
                    segments: [
                      ButtonSegment(
                        value: MinimalWidgetTextAlignment.left,
                        label: Text(l10n.alignLeft),
                        icon: const Icon(Icons.format_align_left),
                      ),
                      ButtonSegment(
                        value: MinimalWidgetTextAlignment.center,
                        label: Text(l10n.alignCenter),
                        icon: const Icon(Icons.format_align_center),
                      ),
                      ButtonSegment(
                        value: MinimalWidgetTextAlignment.right,
                        label: Text(l10n.alignRight),
                        icon: const Icon(Icons.format_align_right),
                      ),
                    ],
                    selected: {_settings.textAlignment},
                    onSelectionChanged: (s) => setState(
                      () => _settings = _settings.copyWith(
                        textAlignment: s.first,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Fallback to Next Quadrants ────────────────────────────────
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _settings.fallbackToNextQuadrants,
                  onChanged: (val) => setState(
                    () => _settings = _settings.copyWith(
                      fallbackToNextQuadrants: val,
                    ),
                  ),
                  title: Text(l10n.fallbackToNextQuadrants),
                  subtitle: Text(l10n.fallbackDescription),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _save, child: Text(l10n.save)),
          ),
        ),
      ],
    );
  }
}
