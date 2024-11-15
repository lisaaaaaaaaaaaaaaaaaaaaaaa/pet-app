import 'package:url_launcher/url_launcher.dart';

class UrlLauncher {
  // Launch URL in browser
  static Future<bool> launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
      return false;
    }
  }

  // Launch email
  static Future<bool> launchEmail(
    String email, {
    String subject = '',
    String body = '',
  }) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {
          'subject': subject,
          'body': body,
        },
      );

      if (await canLaunchUrl(emailUri)) {
        return await launchUrl(emailUri);
      } else {
        throw 'Could not launch email';
      }
    } catch (e) {
      print('Error launching email: $e');
      return false;
    }
  }

  // Launch phone call
  static Future<bool> launchPhone(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );

      if (await canLaunchUrl(phoneUri)) {
        return await launchUrl(phoneUri);
      } else {
        throw 'Could not launch phone';
      }
    } catch (e) {
      print('Error launching phone: $e');
      return false;
    }
  }

  // Launch SMS
  static Future<bool> launchSMS(
    String phoneNumber, {
    String message = '',
  }) async {
    try {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {
          'body': message,
        },
      );

      if (await canLaunchUrl(smsUri)) {
        return await launchUrl(smsUri);
      } else {
        throw 'Could not launch SMS';
      }
    } catch (e) {
      print('Error launching SMS: $e');
      return false;
    }
  }

  // Launch WhatsApp
  static Future<bool> launchWhatsApp(
    String phoneNumber, {
    String message = '',
  }) async {
    try {
      // Remove any non-numeric characters from phone number
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final whatsappUrl = Uri.parse(
        'whatsapp://send?phone=$cleanPhone&text=${Uri.encodeComponent(message)}',
      );

      if (await canLaunchUrl(whatsappUrl)) {
        return await launchUrl(whatsappUrl);
      } else {
        // Try web URL as fallback
        final webUrl = Uri.parse(
          'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}',
        );
        return await launchUrl(webUrl);
      }
    } catch (e) {
      print('Error launching WhatsApp: $e');
      return false;
    }
  }

  // Launch Maps
  static Future<bool> launchMaps(
    double latitude,
    double longitude, {
    String? label,
  }) async {
    try {
      final Uri mapsUri = Uri.parse(
        'geo:$latitude,$longitude?q=$latitude,$longitude${label != null ? '($label)' : ''}',
      );

      if (await canLaunchUrl(mapsUri)) {
        return await launchUrl(mapsUri);
      } else {
        // Fallback to Google Maps web URL
        final webUrl = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
        );
        return await launchUrl(webUrl);
      }
    } catch (e) {
      print('Error launching maps: $e');
      return false;
    }
  }

  // Launch App Store / Play Store
  static Future<bool> launchStore(String appId, {bool isIOS = false}) async {
    try {
      final Uri storeUri = Uri.parse(
        isIOS
            ? 'https://apps.apple.com/app/id$appId'
            : 'https://play.google.com/store/apps/details?id=$appId',
      );

      if (await canLaunchUrl(storeUri)) {
        return await launchUrl(storeUri);
      } else {
        throw 'Could not launch store';
      }
    } catch (e) {
      print('Error launching store: $e');
      return false;
    }
  }

  // Launch social media profiles
  static Future<bool> launchSocialMedia(
    String username,
    SocialPlatform platform,
  ) async {
    try {
      final String url = _getSocialMediaUrl(username, platform);
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      } else {
        throw 'Could not launch $platform';
      }
    } catch (e) {
      print('Error launching social media: $e');
      return false;
    }
  }

  // Helper method to get social media URLs
  static String _getSocialMediaUrl(String username, SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.facebook:
        return 'https://facebook.com/$username';
      case SocialPlatform.twitter:
        return 'https://twitter.com/$username';
      case SocialPlatform.instagram:
        return 'https://instagram.com/$username';
      case SocialPlatform.linkedin:
        return 'https://linkedin.com/in/$username';
      case SocialPlatform.github:
        return 'https://github.com/$username';
    }
  }

  // Do not instantiate this class
  UrlLauncher._();
}

enum SocialPlatform {
  facebook,
  twitter,
  instagram,
  linkedin,
  github,
}