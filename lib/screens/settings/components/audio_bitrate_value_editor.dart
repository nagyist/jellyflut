part of 'sections.dart';

class AudioBitrateValueEditor extends StatefulWidget {
  final Database database;
  AudioBitrateValueEditor({super.key, required this.database});

  @override
  State<AudioBitrateValueEditor> createState() =>
      _AudioBitrateValueEditorState();
}

class _AudioBitrateValueEditorState extends State<AudioBitrateValueEditor> {
  late int _maxBitrateValue;
  late String maxBitrate;
  late Setting setting;
  late final Future<Setting> settingFuture;
  late final TextEditingController controller;
  late final BehaviorSubject<String> textControllerStreamValue =
      BehaviorSubject<String>();

  Future<Setting> get getCurrentSettings =>
      widget.database.settingsDao.getSettingsById(userApp!.settingsId);

  @override
  void initState() {
    settingFuture =
        widget.database.settingsDao.getSettingsById(userApp!.settingsId);
    settingFuture.then((value) {
      setting = value;
      _maxBitrateValue = value.maxAudioBitrate;
      maxBitrate = _maxBitrateValue.toString();
    });
    controller = TextEditingController();
    controller.addListener(() {
      textControllerStreamValue.add(controller.value.text);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Setting>(
        future: settingFuture,
        builder: (c, s) {
          if (s.hasData) {
            return Text('${_maxBitrateValue / 1000000} Mbps');
          }
          return const SizedBox();
        });
  }

  void editBitrateValue(BuildContext context) async {
    controller.value = TextEditingValue(text: _maxBitrateValue.toString());
    await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (c) {
          return AlertDialog(
              title: Text(
                'Edit max audio bitrate',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              actions: [
                TextButton(
                    onPressed: () => customRouter.pop(),
                    child: Text('cancel'.tr())),
                TextButton(
                    onPressed: () => audioBitrateNewValue(controller.text),
                    child: Text('save'.tr()))
              ],
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                        keyboardType: TextInputType.number,
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'max_bitrate'.tr(),
                          labelStyle: TextStyle(),
                        )),
                    const SizedBox(height: 12),
                    StreamBuilder<String>(
                        stream: textControllerStreamValue,
                        initialData: maxBitrate,
                        builder: (c, s) {
                          return Text(
                            controller.value.text.isNotEmpty
                                ? '${int.parse(s.data!) / 1000000} Mbps'
                                : '0 Mbps',
                            style: Theme.of(context).textTheme.caption,
                          );
                        })
                  ]));
        });
  }

  Future<void> audioBitrateNewValue(String maxBitrate) async {
    _maxBitrateValue = int.parse(maxBitrate);
    final setting = await getCurrentSettings;
    final s = setting
        .toCompanion(true)
        .copyWith(maxAudioBitrate: Value(_maxBitrateValue));
    await widget.database.settingsDao.updateSettings(s);
    setState(() {});
    await customRouter.pop();
  }
}
