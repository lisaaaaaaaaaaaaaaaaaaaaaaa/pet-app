import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';

class PhotoPicker extends StatelessWidget {
  final String? currentImageUrl;
  final Function(String) onImageSelected;
  final double size;
  final bool isCircular;
  final String placeholder;

  const PhotoPicker({
    Key? key,
    this.currentImageUrl,
    required this.onImageSelected,
    this.size = 120,
    this.isCircular = true,
    this.placeholder = 'Add Photo',
  }) : super(key: key);

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image != null) {
        onImageSelected(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pick image'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircular ? null : BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.2),
            width: 2,
          ),
          image: currentImageUrl != null
              ? DecorationImage(
                  image: NetworkImage(currentImageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: currentImageUrl == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    color: AppTheme.primaryColor,
                    size: size * 0.3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    placeholder,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: size * 0.12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
