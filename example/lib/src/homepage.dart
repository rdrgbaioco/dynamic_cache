import 'package:example/src/view_photo.dart';
import 'package:dynamic_cache/dynamic_cache.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  void putToCache(XFile image) {
    final photoList = context.cache.get<List<XFile?>>('photoList');
    if (photoList == null) {
      final photos =  <XFile?>[];
      photos.add(image);
      context.cache.add(
        'photoList',
        photos,
        autoRemove: true,
        expiration: const Duration(seconds: 30),
      );
    } else {
      /// Add the image to the existing list
      context.cache.update<List<XFile?>>(
        'photoList', (current) => [...current, image],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic Cache Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<Map<String, dynamic>>(
              stream: context.cache.stream,
              initialData: const {},
              builder: (context, snapshot) {
                if (snapshot.requireData.isEmpty) {
                  return const Text('No photos added yet, add some!');
                }

                return GridView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.requireData.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisExtent: 60,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    return ViewPhoto(
                      image: snapshot.fromCache('photoList')[index] as XFile,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final image = await PhotoPicker.pickImage();

          if (image == null) {
            return;
          }

          putToCache(image);
        },
        tooltip: 'Pick Photo',
        child: const Icon(Icons.photo_library_rounded),
      ),
    );
  }
}

final class PhotoPicker {
  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pickImage() =>
      _picker.pickImage(source: ImageSource.gallery);
}