import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double amonia = 0.0;
  double humidade = 0.0;
  double temperatura = 0.0;

  double tempMin = 0.0;
  double amoniaMax = 5.0;
  double tempMax = 0.0;
  bool flagAlarme = false;

  String alarmTempMax = '30.0';
  String alarmTempMin = '2.0';
  String alarmAmonia = '50.0';

  late Timer _timer;
  late Timer _timer2;

  TextEditingController controllerTempMax = TextEditingController();
  TextEditingController controllerTempMin = TextEditingController();
  TextEditingController controllerAmoniaMax = TextEditingController();

  AudioPlayer audioPlayer = AudioPlayer();
  AudioPlayerState audioPlayerState = AudioPlayerState.PAUSED;
  late AudioCache audioCache;
  String path = 'Alarm.mp3';

  @override
  void initState() {
    super.initState();

    audioCache = AudioCache(fixedPlayer: audioPlayer);
    audioPlayer.onPlayerStateChanged.listen((AudioPlayerState s) {
      setState(() {
        audioPlayerState = s;
      });
    });

    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        _recuperaSensores();
      });
    });
    _timer2 = Timer.periodic(Duration(seconds: 4), (timer) {
      _verificaAlarm();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    audioPlayer.release();
    audioPlayer.dispose();
    audioCache.clearCache();
  }

  playMusic() async {
    await audioCache.play(path);
  }

  pauseMusic() async {
    await audioPlayer.pause();
  }

  _recuperaSensores() async {
    String url = "http://15.228.187.254:5000/valores";
    http.Response response;

    response = await http.get(url);

    Map<String, dynamic> retorno = json.decode(response.body);
    setState(() {
      amonia = retorno['amonia'];
      humidade = retorno['humidade'];
      temperatura = retorno['temperatura'];
    });
    print("temperatura: $temperatura amonia: $amonia humidade $humidade");

    //print("resposta" + response.body);
  }

  Widget _tempGauge(double temperatura) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: 270,
            height: 270,
            child: SfRadialGauge(
              enableLoadingAnimation: true,
              animationDuration: 4500,
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 35,
                  interval: 2,
                  pointers: <GaugePointer>[
                    NeedlePointer(
                        value: temperatura.toDouble(), enableAnimation: true),
                  ],
                  ranges: <GaugeRange>[
                    GaugeRange(
                        startValue: 0, endValue: 20, color: Colors.green),
                    GaugeRange(
                        startValue: 20, endValue: 28, color: Colors.yellow),
                    GaugeRange(startValue: 28, endValue: 40, color: Colors.red)
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Text(
                        'Temperatura',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      positionFactor: 0.5,
                      angle: 90,
                    )
                  ],
                ),
              ],
            )),
      ],
    );
  }

  Widget _amoniaGauge(double amonia) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: 270,
            height: 270,
            child: SfRadialGauge(
              enableLoadingAnimation: true,
              animationDuration: 4500,
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 60,
                  interval: 10,
                  pointers: <GaugePointer>[
                    NeedlePointer(
                        value: amonia.toDouble(), enableAnimation: true),
                  ],
                  ranges: <GaugeRange>[
                    GaugeRange(
                        startValue: 0,
                        endValue: 5,
                        color: Colors.blue.shade100),
                    GaugeRange(
                        startValue: 5, endValue: 10, color: Colors.red.shade50),
                    GaugeRange(
                        startValue: 10,
                        endValue: 20,
                        color: Colors.red.shade100),
                    GaugeRange(
                        startValue: 20,
                        endValue: 30,
                        color: Colors.red.shade200),
                    GaugeRange(
                        startValue: 30,
                        endValue: 60,
                        color: Colors.red.shade300)
                  ],
                  // ignore: prefer_const_literals_to_create_immutables
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Text('Amônia',
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold)),
                      positionFactor: 0.5,
                      angle: 90,
                    )
                  ],
                ),
              ],
            )),
      ],
    );
  }

  Widget _humidadeGauge(double humidade) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: 270,
            height: 270,
            child: SfRadialGauge(
              enableLoadingAnimation: true,
              animationDuration: 4500,
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  interval: 10,
                  pointers: <GaugePointer>[
                    NeedlePointer(
                        value: humidade.toDouble(), enableAnimation: true),
                  ],
                  ranges: <GaugeRange>[
                    GaugeRange(
                        startValue: 0, endValue: 40, color: Colors.red.shade50),
                    GaugeRange(
                        startValue: 40,
                        endValue: 60,
                        color: Colors.blue.shade100),
                    GaugeRange(
                        startValue: 60, endValue: 100, color: Colors.blue),
                  ],
                  // ignore: prefer_const_literals_to_create_immutables
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Text('Humidade',
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold)),
                      positionFactor: 0.5,
                      angle: 90,
                    )
                  ],
                ),
              ],
            )),
      ],
    );
  }

  salvarInfo() {
    if (controllerTempMax.text != '') {
      alarmTempMax = controllerTempMax.text;
    }
    if (controllerTempMin.text != '') {
      alarmTempMin = controllerTempMin.text;
    }
    if (controllerAmoniaMax.text != '') {
      alarmAmonia = controllerAmoniaMax.text;
    }
  }

  _verificaAlarm() {
    tempMax = double.parse(alarmTempMax);
    tempMin = double.parse(alarmTempMin);
    amoniaMax = double.parse(alarmAmonia);
    print('kjfkjsdkljfkjsdkljfkjsdkfjsld');

    if (temperatura > tempMax) {
      playMusic();
    } else if (temperatura < tempMin) {
      playMusic();
    } else if (amonia > amoniaMax) {
      playMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sensores aviário 723"),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SingleChildScrollView(
                          child: AlertDialog(
                        title: Text('Alarmes'),
                        content: Column(
                          children: [
                            TextField(
                              controller: controllerTempMax,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  labelText: "Temperatura máxima alarme"),
                            ),
                            TextField(
                              controller: controllerTempMin,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  labelText: "Temperatura minima alarme"),
                            ),
                            TextField(
                              controller: controllerAmoniaMax,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  labelText: "Amônia máxima alarme"),
                            )
                          ],
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              salvarInfo();
                              Navigator.pop(context);
                            },
                            child: Text("Salvar"),
                          ),
                        ],
                      ));
                    });
              },
              icon: Icon(Icons.access_alarm),
            )
          ],
        ),
      ),
      body: Container(
          padding: EdgeInsets.all(40),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _tempGauge(temperatura),
                Padding(padding: EdgeInsets.only(bottom: 10)),
                _amoniaGauge(amonia),
                _humidadeGauge(humidade),
                Text(
                  "Alarme temperatura Max: $alarmTempMax",
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  "Alarme temperatura Min: $alarmTempMin",
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  "Alarme Amônia Max: $alarmAmonia",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          )),
    );
  }
}
