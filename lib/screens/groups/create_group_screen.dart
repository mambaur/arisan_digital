import 'package:arisan_digital/blocs/groups/create_group_cubit/create_group_cubit.dart';
import 'package:arisan_digital/blocs/home/group_bloc/group_bloc.dart';
import 'package:arisan_digital/models/group_model.dart';
import 'package:arisan_digital/utils/currency_format.dart';
import 'package:arisan_digital/utils/custom_snackbar.dart';
import 'package:arisan_digital/utils/date_config.dart';
import 'package:arisan_digital/utils/loading_overlay.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:intl/intl.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _duesController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String dropdownValue = 'Mingguan';

  final _formKey = GlobalKey<FormState>();

  // Date Picker
  DateTime selectedDate = DateTime.now();
  DateTime now = DateTime.now();

  Future _createGroup() async {
    if (!_formKey.currentState!.validate()) return null;
    context.read<CreateGroupCubit>().createGroup(GroupModel(
        name: _groupNameController.text,
        dues: int.parse(CurrencyFormat.toNumber(
            _duesController.text != '' ? _duesController.text : '0')),
        periodsDate: _dateController.text,
        periodsType: dropdownValue));
  }

  @override
  void initState() {
    _dateController.text = DateConfig.dateToString(now);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group'),
        iconTheme: IconThemeData(color: Colors.grey.shade300),
        titleTextStyle: TextStyle(
            color: Colors.lightBlue.shade800, fontWeight: FontWeight.w500),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: BlocListener<CreateGroupCubit, CreateGroupState>(
        listener: (context, state) {
          if (state.status == CreateGroupStatus.loading) {
            LoadingOverlay.show(context);
          } else if (state.status == CreateGroupStatus.success) {
            LoadingOverlay.hide(context);
            CustomSnackbar.awesome(context,
                message: state.message ?? '', type: ContentType.success);
            context.read<GroupBloc>().add(const GroupFetched(isRefresh: true));
            Navigator.pop(context);
          } else {
            LoadingOverlay.hide(context);
            CustomSnackbar.awesome(context,
                message: state.message ?? '', type: ContentType.failure);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.82,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tambah Group Arisan!",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.lightBlue.shade900),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Tentukan nama group arisan yang kamu kelola sekarang.",
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: Center(
                      child: Image.asset("assets/images/world-group.png"),
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.only(left: 5, right: 5),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama group tidak boleh kosong.';
                          }
                          return null;
                        },
                        controller: _groupNameController,
                        decoration: const InputDecoration(
                            // label: Text('Nama Group'),
                            helperText: "* Contoh: kantor, komplek, dll.",
                            labelText: "Nama Group"),
                      )),
                  Container(
                      margin:
                          const EdgeInsets.only(left: 5, right: 5, bottom: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nominal iuran tidak boleh kosong.';
                                }
                                return null;
                              },
                              controller: _duesController,
                              inputFormatters: [
                                ThousandsFormatter(
                                    allowFraction: false,
                                    formatter:
                                        NumberFormat.decimalPattern('en'))
                              ],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: "Nominal Iuran"),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectDate(context),
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Tanggal arisan tidak boleh kosong.';
                                  }
                                  return null;
                                },
                                enabled: false,
                                controller: _dateController,
                                decoration: const InputDecoration(
                                    labelText: "Tanggal Mulai"),
                              ),
                            ),
                          ),
                        ],
                      )),
                  Container(
                    margin: const EdgeInsets.only(left: 5, right: 5),
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      icon: const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Icon(Icons.arrow_drop_down),
                      ),
                      elevation: 16,
                      isExpanded: true,
                      style:
                          TextStyle(color: Colors.grey.shade800, fontSize: 16),
                      underline: Container(
                        height: 1,
                        color: Colors.grey.shade500,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                      },
                      items: <String>['Mingguan', 'Bulanan', 'Tahunan']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text(value),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        onPressed: () => _createGroup(),
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text('Tambah Group'),
                        )),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.blue.shade700,
              ),
            ),
            child: child!,
          );
        },
        initialDate: selectedDate,
        firstDate: DateTime((now.year - 100), 8),
        lastDate: DateTime(now.year + 1));
    if (picked != null && picked != selectedDate) selectedDate = picked;
    _dateController.text = selectedDate.toLocal().toString().split(' ')[0];
    setState(() {});
  }
}
