import 'package:flutter/material.dart';
import 'package:flutter_controller/bloc/SsTabBloc.dart';
import 'package:flutter_controller/di/Provider.dart';
import 'package:flutter_controller/model/Parameter.dart';
import 'package:flutter_controller/model/SystemSettings.dart';
import 'package:flutter_controller/widget/TitledCard.dart';

class SsTab extends StatefulWidget {
  @override
  SsTabState createState() => SsTabState();
}

class SsTabState extends State<SsTab> {
  SsTabBloc _bloc;
  final _identificationCurrentEditingController = TextEditingController();
  final _writeHallsManuallyEditingController = TextEditingController();
  final _currentValueKey = GlobalKey<FormState>();
  final _hallValuesKey = GlobalKey<FormState>();

  FormFieldValidator<String> _currentValidator = (value) {
    var result;
    final number = int.tryParse(value);
    if (number == null || number < 1) {
      result = "";
    }
    return result;
  };

  FormFieldValidator<String> _hallValidator = (value) {
    var result;
    final values = value.split(";");
    if (values.length != 6) {
      result = "";
    }
    values.forEach((element) {
      final number = int.tryParse(element);
      if (number == null || number > 6 || number < 1) {
        result = "";
      }
    });

    return result;
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = Provider.of(context).ssTabBloc;
    _bloc.commandSink.add(SsCommand.READ);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder<SystemSettings>(
          stream: _bloc.viewModelStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            print("identificationMode = ${snapshot.data.identificationMode}");
            return Stack(children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIdentificationCurrentSection(snapshot.data.identificationCurrent),
                    _buildMotorSection(
                      snapshot.data.motorResistance,
                      snapshot.data.motorInduction,
                      snapshot.data.motorMagnetStream,
                    ),
                    _buildHallSection([
                      snapshot.data.hall1,
                      snapshot.data.hall2,
                      snapshot.data.hall3,
                      snapshot.data.hall4,
                      snapshot.data.hall5,
                      snapshot.data.hall6
                    ]),
                  ],
                ),
              ),
              if (snapshot.data.identificationMode > 0) _buildWaiting(context)
            ]);
          }),
    );
  }

  Widget _buildWaiting(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 150,
        ),
        AlertDialog(
          title: Center(child: Text("Please wait.")),
          content: Column(
            children: [
              Text("Measuring in process..."),
              Container(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator())
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIdentificationCurrentSection(int identificationCurrent) {
    return TitledCard(
      title: "Identification",
      child: Container(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Text("Identification current, A: "),
            Flexible(child: Container()),
            Form(
              key: _currentValueKey,
              child: Container(
                width: 96,
                child: _buildTextInput(
                    validator: _currentValidator,
                    initialValue: identificationCurrent.toString(),
                    controller: _identificationCurrentEditingController
                      ..addListener(() {
                        final text = _identificationCurrentEditingController.value.text;
                        _bloc.dataSink.add(Parameter("identificationCurrent", text));
                      })),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotorSection(
    double rS,
    double lS,
    double flux,
  ) {
    return TitledCard(
      title: "Motor",
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            _buildMeasureSingleLine("Measure Rs", rS, () {
              if (_currentValueKey.currentState.validate() ?? false) {
                _bloc.commandSink.add(SsCommand.MEASURE_RS);
              }
            }),
            Container(
              height: 8,
            ),
            _buildMeasureSingleLine("Measure Ls", lS, () {
              if (_currentValueKey.currentState.validate() ?? false) {
                _bloc.commandSink.add(SsCommand.MEASURE_LS);
              }
            }),
            Container(
              height: 8,
            ),
            _buildMeasureSingleLine("Measure Flux", flux, () {
              if (_currentValueKey.currentState.validate() ?? false) {
              _bloc.commandSink.add(SsCommand.MEASURE_FLUX);
              }
            }),
            Container(
              height: 32,
            ),
            RaisedButton(
              child: Text("Start identification"),
              onPressed: () {
                if (_currentValueKey.currentState.validate() ?? false) {
                  _bloc.commandSink.add(SsCommand.MEASURE_HALLS);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHallSection(List<int> hallValues) {
    final child = Container(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(child: _buildWriteHalls(hallValues)),
            Container(
              width: 16,
            ),
            _buildHallValues(hallValues)
          ],
        ));
    return TitledCard(title: "Halls", child: child);
  }

  Widget _buildMeasureSingleLine(String title, double value, void Function() onPress) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 24,
          width: 128,
          child: RaisedButton(
            child: Text(title),
            onPressed: () {
              onPress();
            },
          ),
        ),
        Flexible(child: Container()),
        Container(width: 96, height: 36, child: _buildValueContainer(value.toStringAsFixed(3))),
      ],
    );
  }

  Widget _buildWriteHalls(List<int> hallValues) {
    return Column(
      children: [
        Text("Write halls manually : "),
        Form(
            key: _hallValuesKey,
            child: _buildTextInput(
                validator: _hallValidator,
                controller: _writeHallsManuallyEditingController..addListener(() {
                  final text = _writeHallsManuallyEditingController.value.text;
                  final halls = text.split(";");
                  _bloc.dataSink.add(Parameter("hall1", halls[0]));
                  _bloc.dataSink.add(Parameter("hall2", halls[1]));
                  _bloc.dataSink.add(Parameter("hall3", halls[2]));
                  _bloc.dataSink.add(Parameter("hall4", halls[3]));
                  _bloc.dataSink.add(Parameter("hall5", halls[4]));
                  _bloc.dataSink.add(Parameter("hall6", halls[5]));

                }),
                initialValue: hallValues.join(";"))),
        Container(
          height: 16,
        ),
        RaisedButton(
          child: Text("Write halls"),
          onPressed: () {
            if (_hallValuesKey.currentState.validate() ?? false) {
              _bloc.commandSink.add(SsCommand.WRITE_HALLS_TABLE);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTextInput(
      {TextEditingController controller, String initialValue = "", FormFieldValidator<String> validator}) {
    return Container(
      height: 32,
      child: TextFormField(
          validator: validator,
          controller: controller..text = initialValue,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(errorStyle: TextStyle(height: 0), border: OutlineInputBorder())),
    );
  }

  Widget _buildHallValues(List<int> hallValues) {
    return Container(
      child: Column(
          children: hallValues
              .asMap()
              .entries
              .map((value) => _buildSingleHallLine("Hall ${value.key}", value.value))
              .toList()),
    );
  }

  Widget _buildSingleHallLine(String hallName, int hallValue) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text("$hallName : "), _buildValueContainer(hallValue)],
      ),
    );
  }

  Widget _buildValueContainer(dynamic value) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            border: Border.all(
              width: 1,
              color: Colors.grey,
            )),
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: Align(
          alignment: Alignment(1, 0),
          child: Text(
            value.toString(),
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 20),
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _writeHallsManuallyEditingController.dispose();
    _identificationCurrentEditingController.dispose();
    _bloc.dispose();
  }
}
