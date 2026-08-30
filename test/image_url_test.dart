import 'package:flutter_test/flutter_test.dart';
import 'package:sukonlanat_portfolio/utils/image_url.dart';

void main() {
  test('filters invalid and duplicate image URLs', () {
    expect(
      normalizeRemoteImageUrls([
        'https://example.com/a.jpg',
        'https://example.com/a.jpg',
        'javascript:alert(1)',
        '',
      ]),
      ['https://example.com/a.jpg'],
    );
  });

  test('creates a resized Supabase Storage URL', () {
    final url = responsiveImageUrl(
      'https://demo.supabase.co/storage/v1/object/public/images/photo one.jpg',
      width: 640,
      height: 360,
      crop: true,
    );

    expect(
      url,
      contains('/storage/v1/render/image/public/images/photo%20one.jpg'),
    );
    expect(url, contains('width=640'));
    expect(url, contains('height=360'));
    expect(url, contains('resize=cover'));
  });

  test('leaves non-Supabase image URLs unchanged', () {
    const url = 'https://cdn.example.com/photo.jpg';
    expect(responsiveImageUrl(url, width: 640), url);
  });
}
