import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  double _rating = 3.0;
  bool _recommend = true;
  bool _hasSpoilers = false;
  String _platform = 'PC';

  void _submitReview() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Success', style: TextStyle(color: Colors.white)),
        content: const Text('Review saved successfully!', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feed updated!'), backgroundColor: Colors.purple),
              );
            },
            child: const Text('OK', style: TextStyle(color: Colors.purpleAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Write Review'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Select Platform', style: TextStyle(color: Colors.white)),
          Row(
            children: ['PC', 'Console', 'Mobile'].map((p) => Expanded(
              child: RadioListTile<String>(
                title: Text(p, style: const TextStyle(color: Colors.white, fontSize: 12)),
                value: p,
                groupValue: _platform,
                activeColor: Colors.purpleAccent,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setState(() => _platform = val!),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Rating', style: TextStyle(color: Colors.white)),
          Slider(
            value: _rating,
            min: 1,
            max: 5,
            divisions: 4,
            activeColor: Colors.purpleAccent,
            label: _rating.toString(),
            onChanged: (val) => setState(() => _rating = val),
          ),
          const SizedBox(height: 16),
          TextFormField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your experience...',
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Recommend this game?', style: TextStyle(color: Colors.white)),
            value: _recommend,
            activeThumbColor: Colors.purpleAccent,
            onChanged: (val) => setState(() => _recommend = val),
          ),
          CheckboxListTile(
            title: const Text('Contains spoilers', style: TextStyle(color: Colors.white)),
            value: _hasSpoilers,
            activeColor: Colors.purpleAccent,
            onChanged: (val) => setState(() => _hasSpoilers = val!),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Publish', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}