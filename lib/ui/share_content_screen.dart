// ui/share_content_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pencil_flutter/utils/constants.dart';

class ShareContentScreen extends StatelessWidget {
  final String? sharedUrl;
  final String? sharedImageUri;

  const ShareContentScreen({
    super.key,
    this.sharedUrl,
    this.sharedImageUri,
  }) : assert(sharedUrl != null || sharedImageUri != null,
            'Either sharedUrl or sharedImageUri must be provided');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorGreen,
        title: const Text('Shared Content'),
      ),
      body: SafeArea(
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (sharedImageUri != null) {
      return _buildImageContent(context);
    } else if (sharedUrl != null) {
      return _buildUrlContent(context);
    } else {
      return const Center(
        child: Text('No content to display'),
      );
    }
  }

  Widget _buildImageContent(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Shared Image',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildImageWidget(context),
            const SizedBox(height: 16),
            Text(
              'Image URI: $sharedImageUri',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(BuildContext context) {
    if (sharedImageUri == null) {
      return const Text('No image URI provided');
    }

    // Handle different URI schemes
    if (sharedImageUri!.startsWith('content://')) {
      // Content URI - use Image.network or a plugin that supports content URIs
      // For now, we'll try to display it
      return Container(
        constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            sharedImageUri!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    const Text(
                      'Unable to load image',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'URI: $sharedImageUri',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      );
    } else if (sharedImageUri!.startsWith('file://')) {
      // File URI
      final filePath = sharedImageUri!.replaceFirst('file://', '');
      final file = File(filePath);
      if (file.existsSync()) {
        return Container(
          constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              file,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(Icons.error_outline, size: 48, color: Colors.red),
                );
              },
            ),
          ),
        );
      } else {
        return const Text('Image file not found');
      }
    } else {
      // Try as network image or file path
      return Container(
        constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            sharedImageUri!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Try as file path
              final file = File(sharedImageUri!);
              if (file.existsSync()) {
                return Image.file(file, fit: BoxFit.contain);
              }
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Icon(Icons.error_outline, size: 48, color: Colors.red),
              );
            },
          ),
        ),
      );
    }
  }

  Widget _buildUrlContent(BuildContext context) {
    final uri = Uri.tryParse(sharedUrl!);
    final domain = uri?.host ?? 'Unknown';
    final scheme = uri?.scheme ?? 'Unknown';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shared URL',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Full URL:', sharedUrl!),
            const SizedBox(height: 16),
            _buildDetailRow('Domain:', domain),
            const SizedBox(height: 16),
            _buildDetailRow('Scheme:', scheme),
            if (uri?.path.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _buildDetailRow('Path:', uri!.path),
            ],
            if (uri?.queryParameters.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              const Text(
                'Query Parameters:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...uri!.queryParameters.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                    child: Text('${entry.key}: ${entry.value}'),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: SelectableText(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

