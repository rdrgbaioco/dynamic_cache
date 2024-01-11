import 'package:example/src/view_photo.dart';
import 'package:dynamic_cache/dynamic_cache.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.cache,
    super.key,
  });

  final DynamicCache cache;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  void cache() {
    widget.cache.add(
        key: 'Names',
        value: ['John', 'Jane', 'Jack', 'Jill', 'Jack', 'Annie', 'Bill'],
        expiration: const Duration(seconds: 5),
        onExpire: () async {
          await showAdaptiveDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Alert!'),
                content: const Text('Cache expired!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      cache();
                      Navigator.pop(context);
                    },
                    child: const Text('Restart'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
    );
  }

  @override
  void initState() {
    super.initState();
    cache();
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

          ],
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //
      //   },
      //   tooltip: 'Pick Photo',
      //   child: const Icon(Icons.photo_library_rounded),
      // ),
    );
  }
}

final class PhotoPicker {
  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pickImage() =>
      _picker.pickImage(source: ImageSource.gallery);
}
