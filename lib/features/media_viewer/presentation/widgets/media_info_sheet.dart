import 'package:flutter/material.dart';
import '../../../media_library/domain/entities/media_item.dart';
import '../../../media_library/domain/entities/media_type.dart';
import '../../domain/media_file_details.dart';
import '../models/media_formatters.dart';
import 'info_row.dart';

class MediaInfoSheet extends StatelessWidget {
  const MediaInfoSheet({
    required this.item,
    required this.details,
    required this.onOpen,
    required this.onShare,
    super.key,
  });
  final MediaItem item;
  final MediaFileDetails details;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          InfoRow(label: 'Tipo', value: item.type.name),
          if (item.title?.isNotEmpty == true)
            InfoRow(label: 'Nombre', value: item.title!),
          InfoRow(label: 'Resolución', value: '${item.width} x ${item.height}'),
          if (item.type == MediaType.video)
            InfoRow(
              label: 'Duración',
              value: formatMediaDuration(item.duration),
            ),
          InfoRow(label: 'Creado', value: item.createdAt.toLocal().toString()),
          InfoRow(
            label: 'Actualizado',
            value: item.updatedAt.toLocal().toString(),
          ),
          if (details.size != null)
            InfoRow(label: 'Tamaño', value: formatMediaBytes(details.size!)),
          if (details.location != null)
            InfoRow(label: 'Ubicación', value: details.location!),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: details.location == null ? null : onOpen,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Abrir'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: details.location == null ? null : onShare,
                  icon: const Icon(Icons.ios_share),
                  label: const Text('Compartir'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
