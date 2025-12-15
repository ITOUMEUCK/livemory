import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../models/media.dart';
import '../services/media_service.dart';

class MediaTab extends StatefulWidget {
  final String eventId;

  const MediaTab({super.key, required this.eventId});

  @override
  State<MediaTab> createState() => _MediaTabState();
}

class _MediaTabState extends State<MediaTab> {
  final MediaService _service = MediaService();
  final ImagePicker _picker = ImagePicker();
  List<Media> _mediaItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    setState(() => _isLoading = true);
    try {
      final media = await _service.getEventMedia(widget.eventId);
      setState(() {
        _mediaItems = media;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickMedia(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Prendre une photo'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickMedia(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galerie'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _mediaItems.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text('Aucun média'),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _mediaItems.length,
                  itemBuilder: (context, index) {
                    final media = _mediaItems[index];
                    return _MediaThumbnail(
                      media: media,
                      onTap: () => _showMediaViewer(index),
                      onLike: () => _likeMedia(
                        media.id,
                        media.likedByIds.contains('current_user_id'),
                      ),
                      onDelete: () => _deleteMedia(media.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _pickMedia(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        // TODO: Upload media
        // await _service.uploadMedia(widget.eventId, image.path);
        _loadMedia();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  void _showMediaViewer(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            _MediaViewer(mediaItems: _mediaItems, initialIndex: initialIndex),
      ),
    );
  }

  Future<void> _likeMedia(String mediaId, bool isLiked) async {
    try {
      if (isLiked) {
        await _service.unlikeMedia(widget.eventId, mediaId);
      } else {
        await _service.likeMedia(widget.eventId, mediaId);
      }
      _loadMedia();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _deleteMedia(String mediaId) async {
    try {
      await _service.deleteMedia(widget.eventId, mediaId);
      _loadMedia();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }
}

class _MediaThumbnail extends StatelessWidget {
  final Media media;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onDelete;

  const _MediaThumbnail({
    required this.media,
    required this.onTap,
    required this.onLike,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: media.type == MediaType.photo
                ? Image.network(
                    media.thumbnailUrl ?? media.url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image),
                      );
                    },
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        media.thumbnailUrl ?? media.url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.video_library),
                          );
                        },
                      ),
                      const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Supprimer', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'delete') {
                  onDelete();
                }
              },
            ),
          ),
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, size: 12, color: Colors.white),
                  const SizedBox(width: 2),
                  Text(
                    '${media.likes}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaViewer extends StatelessWidget {
  final List<Media> mediaItems;
  final int initialIndex;

  const _MediaViewer({required this.mediaItems, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share media
            },
          ),
        ],
      ),
      body: PhotoViewGallery.builder(
        itemCount: mediaItems.length,
        builder: (context, index) {
          final media = mediaItems[index];
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(media.url),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        pageController: PageController(initialPage: initialIndex),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }
}
