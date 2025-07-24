import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/entry.dart';
import '../models/target_data.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TargetData? _targetData;
  bool _isLoading = true;
  String _currency = 'PKR';
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('target_data');
    final currency = prefs.getString('currency') ?? 'PKR';
    final theme = prefs.getString('theme_mode');
    _currency = currency;
    if (theme == 'light') _themeMode = ThemeMode.light;
    if (theme == 'dark') _themeMode = ThemeMode.dark;
    if (data != null) {
      final jsonData = json.decode(data);
      TargetData loaded = TargetData.fromJson(jsonData);
      final nowMonth = DateTime.now().month.toString();
      if (loaded.month != nowMonth) {
        loaded = TargetData(targetAmount: loaded.targetAmount, entries: [], month: nowMonth);
        await prefs.setString('target_data', json.encode(loaded.toJson()));
      }
      setState(() {
        _targetData = loaded;
        _isLoading = false;
      });
    } else {
      setState(() {
        _targetData = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_targetData != null) {
      await prefs.setString('target_data', json.encode(_targetData!.toJson()));
    }
  }

  Future<void> _setTargetDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Set Monthly Target', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Target Amount ($_currency)'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final value = double.tryParse(controller.text);
                      if (value != null && value > 0) {
                        Navigator.pop(context, value);
                      }
                    },
                    child: const Text('Set'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (result != null) {
      final nowMonth = DateTime.now().month.toString();
      setState(() {
        _targetData = TargetData(targetAmount: result, entries: [], month: nowMonth);
      });
      await _saveData();
    }
  }

  Future<void> _addEntryDialog({Entry? entry, int? index}) async {
    final controller = TextEditingController(text: entry?.amount.toString() ?? '');
    final result = await showDialog<double>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(entry == null ? 'Add Income Entry' : 'Edit Entry', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Amount ($_currency)'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final value = double.tryParse(controller.text);
                      if (value != null && value > 0) {
                        Navigator.pop(context, value);
                      }
                    },
                    child: Text(entry == null ? 'Add' : 'Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (result != null && _targetData != null) {
      setState(() {
        List<Entry> updated = List.from(_targetData!.entries);
        if (entry != null && index != null) {
          updated[index] = Entry(amount: result, dateTime: entry.dateTime);
        } else {
          updated.insert(0, Entry(amount: result, dateTime: DateTime.now()));
        }
        _targetData = TargetData(
          targetAmount: _targetData!.targetAmount,
          entries: updated,
          month: _targetData!.month,
        );
      });
      await _saveData();
    }
  }

  Future<void> _deleteEntry(int index) async {
    if (_targetData == null) return;
    setState(() {
      List<Entry> updated = List.from(_targetData!.entries);
      updated.removeAt(index);
      _targetData = TargetData(
        targetAmount: _targetData!.targetAmount,
        entries: updated,
        month: _targetData!.month,
      );
    });
    await _saveData();
  }

  Future<void> _setCurrencyDialog() async {
    final controller = TextEditingController(text: _currency);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Set Currency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Currency (e.g., PKR, USD)'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        Navigator.pop(context, controller.text);
                      }
                    },
                    child: const Text('Set'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currency', result);
      setState(() {
        _currency = result;
      });
    }
  }

  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
        prefs.setString('theme_mode', 'dark');
      } else {
        _themeMode = ThemeMode.light;
        prefs.setString('theme_mode', 'light');
      }
    });
  }

  Widget _buildSummaryCard() {
    if (_targetData == null) return const SizedBox();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.85),
            Colors.teal.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryMetric(Icons.flag, 'Target', _targetData!.targetAmount),
          _buildSummaryMetric(Icons.check_circle, 'Collected', _targetData!.collectedAmount, color: Colors.lightGreenAccent.shade700),
          _buildSummaryMetric(Icons.trending_down, 'Remaining', _targetData!.remainingAmount, color: Colors.redAccent.shade100),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric(IconData icon, String label, double value, {Color? color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: color ?? Colors.white,
          child: Icon(icon, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          value.toStringAsFixed(2),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }

  // ✅ UPDATED METHOD
  Widget _buildHistoryList() {
    if (_targetData == null || _targetData!.entries.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text(
                'No entries yet.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              const Text('Tap "+" to add your first entry!', style: TextStyle(color: Colors.black38)),
            ],
          ),
        ),
      );
    }
    return Expanded(
      child: ListView.separated(
        itemCount: _targetData!.entries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final entry = _targetData!.entries[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: Icon(Icons.attach_money, color: Colors.green.shade800),
              ),
              title: Text(
                'Collected: ${entry.amount.toStringAsFixed(2)} ',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
              ),
              subtitle: Text(
                '${entry.dateTime.toLocal().toString().substring(0, 16)}',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    tooltip: 'Edit',
                    onPressed: () => _addEntryDialog(entry: entry, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    tooltip: 'Delete',
                    onPressed: () => _deleteEntry(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return MaterialApp(
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark),
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFe0ffe7), Color(0xFFb2f7ef), Color(0xFFf7f7f7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.white.withOpacity(0.85),
              elevation: 0,
              title: Row(
                children: [
                  Icon(Icons.track_changes, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  const Text('Money Tracker', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.currency_exchange, color: Colors.black87),
                  tooltip: 'Set Currency',
                  onPressed: _setCurrencyDialog,
                ),
                IconButton(
                  icon: Icon(_themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode, color: Colors.black87),
                  tooltip: 'Toggle Theme',
                  onPressed: _toggleTheme,
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black87),
                  tooltip: 'Set Target',
                  onPressed: _setTargetDialog,
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _targetData == null
                    ? Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _setTargetDialog,
                          child: const Text('Set Monthly Target', style: TextStyle(fontSize: 18)),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSummaryCard(),
                          const SizedBox(height: 28),
                          const Text('History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 12),
                          _buildHistoryList(),
                        ],
                      ),
              ),
            ),
            floatingActionButton: _targetData != null
                ? FloatingActionButton.extended(
                    onPressed: _addEntryDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Entry'),
                    backgroundColor: Colors.green.shade700,
                  )
                : null,
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          ),
        ],
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
