import 'package:flutter/material.dart';
import '../utils/constants.dart';

class GameListCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String? imagePath;
  final String title;
  final String description;
  final String info;
  final VoidCallback onTap;

  const GameListCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.info,
    required this.onTap,
    this.iconColor = AppColors.purple,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8EAFF)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: imagePath != null && AppStrings.showCardArtwork
                  ? Image.asset(imagePath!, fit: BoxFit.contain)
                  : Container(
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(child: Icon(icon, color: iconColor, size: 36)),
                    ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imagePath == null || !AppStrings.showCardArtwork) ...[
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    info,
                    style: const TextStyle(
                      color: AppColors.purple,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Play Now',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
