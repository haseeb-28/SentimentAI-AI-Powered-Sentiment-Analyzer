import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../models/analysis_history.dart';
import '../services/storage_service.dart';
import '../state/sentiment_provider.dart';
import '../widgets/history_item_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final StorageService _storageService = StorageService();
  List<AnalysisHistory> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await _storageService.getHistory();
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  Future<void> _deleteItem(String id) async {
    await _storageService.deleteAnalysis(id);
    await _loadHistory();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analysis deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to delete all analysis history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(AppConstants.errorColor),
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.clearHistory();
      await _loadHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All history cleared'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _analyzeAgain(String text) {
    final provider = context.read<SentimentProvider>();
    provider.analyzeText(text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis History'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Clear All',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? _buildEmptyState(isMobile)
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      return HistoryItemCard(
                        history: _history[index],
                        onDelete: () => _deleteItem(_history[index].id),
                        onAnalyzeAgain: () => _analyzeAgain(_history[index].text),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 32 : 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: isMobile ? 64 : 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No History Yet',
              style: TextStyle(
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your analysis history will appear here',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}



