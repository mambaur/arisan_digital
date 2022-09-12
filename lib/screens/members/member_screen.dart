import 'package:arisan_digital/blocs/member_cubit/member_cubit.dart';
import 'package:arisan_digital/models/group_model.dart';
import 'package:arisan_digital/models/member_model.dart';
import 'package:arisan_digital/utils/custom_snackbar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MemberScreen extends StatefulWidget {
  final GroupModel? group;
  const MemberScreen({Key? key, this.group}) : super(key: key);

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noTelpController = TextEditingController();

  final _formKeyCreate = GlobalKey<FormState>();
  final _formKeyUpdate = GlobalKey<FormState>();

  @override
  void initState() {
    context.read<MemberCubit>().getMembers(widget.group!.id!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MemberCubit, MemberState>(
      listener: (context, state) {
        if (state is MemberSuccessState) {
          _nameController.text = '';
          _emailController.text = '';
          _noTelpController.text = '';
          CustomSnackbar.awesome(context,
              message: state.message, type: ContentType.success);
          context.read<MemberCubit>().getMembers(widget.group!.id!);
        }

        if (state is MemberDataState) {
          if (state.memberStatus == MemberStatus.failure) {
            CustomSnackbar.awesome(context,
                message: state.message ?? '', type: ContentType.failure);
            context.read<MemberCubit>().getMembers(widget.group!.id!);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body:
            CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
          SliverAppBar(
              floating: true,
              iconTheme: IconThemeData(color: Colors.grey.shade300),
              titleTextStyle: TextStyle(
                  color: Colors.lightBlue.shade800,
                  fontWeight: FontWeight.w500),
              backgroundColor: Colors.white,
              centerTitle: true,
              elevation: 0,
              actions: [
                IconButton(
                    onPressed: () {
                      _createMemberModal(context);
                    },
                    icon: Icon(Icons.add)),
              ],
              title: Text('Anggota')),
          SliverList(
              delegate: SliverChildListDelegate([
            BlocBuilder<MemberCubit, MemberState>(
              builder: (context, state) {
                if (state is MemberDataState) {
                  if (state.memberStatus == MemberStatus.success) {
                    return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(15),
                        itemCount: state.listMembers!.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () =>
                                _detailMemberDialog(state.listMembers![index]),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      SizedBox(
                                          width: 40,
                                          child: Image.asset(
                                              "assets/images/icons/man.png")),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        alignment: Alignment.bottomLeft,
                                        child: Icon(
                                          Icons.circle,
                                          color: state.listMembers![index]
                                                      .statusActive ==
                                                  'active'
                                              ? Colors.green.shade500
                                              : Colors.red.shade500,
                                          size: 15,
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(state.listMembers![index].name ??
                                            ''),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          state.listMembers![index].noTelp ??
                                              (state.listMembers![index]
                                                      .email ??
                                                  ''),
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  state.listMembers![index].statusPaid == 'paid'
                                      ? Container(
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                              ),
                                              onPressed: () {},
                                              child: Text('Sudah Bayar')),
                                        )
                                      : Container()
                                ],
                              ),
                            ),
                          );
                        });
                  }
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator()),
                    ),
                  );
                }
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator()),
                  ),
                );
              },
            )
          ])),
          SliverList(delegate: SliverChildListDelegate([])),
        ]),
      ),
    );
  }

  Future<void> _detailMemberDialog(MemberModel member) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: const EdgeInsets.all(15),
          titlePadding: EdgeInsets.zero,
          buttonPadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: SizedBox(
                    width: 40,
                    child: Image.asset("assets/images/icons/man.png")),
                title: Text(member.name ?? ''),
                subtitle: Text(member.email ?? (member.noTelp ?? '')),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ListTile(
                  onTap: () => _statusActiveMemberDialog(member),
                  contentPadding: EdgeInsets.zero,
                  trailing: Icon(Icons.chevron_right),
                  title: Text('Status anggota'),
                  subtitle: Text(member.statusActive ?? ''),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ListTile(
                  onTap: () => _statusPaidMemberDialog(member),
                  contentPadding: EdgeInsets.zero,
                  trailing: Icon(Icons.chevron_right),
                  title: Text('Status pembayaran'),
                  subtitle: Text(member.statusPaid == 'paid'
                      ? 'Sudah Bayar'
                      : member.statusPaid == 'unpaid'
                          ? 'Belum Bayar'
                          : member.statusPaid == 'skip'
                              ? 'Lewati'
                              : 'Batal'),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: member.canDelete!
                              ? Colors.red.shade400
                              : Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text('Hapus'),
                        onPressed: () {
                          if (member.canDelete!) {
                            Navigator.pop(context);
                            _deleteConfirmationDialog(
                                member.id!, member.name ?? '');
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: const Text('Edit'),
                          onPressed: () {
                            Navigator.pop(context);
                            _updateMemberModal(context, member);
                          }),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _statusActiveMemberDialog(MemberModel member) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: const EdgeInsets.all(15),
          titlePadding: EdgeInsets.zero,
          buttonPadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text('Ubah Status Anggota'),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text('Nonactive'),
                        onPressed: () {
                          if (member.statusActive == 'nonactive') {
                            Navigator.pop(context);
                          } else {}
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text('Active'),
                        onPressed: () {
                          if (member.statusActive == 'active') {
                            Navigator.pop(context);
                          } else {}
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _statusPaidMemberDialog(MemberModel member) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: const EdgeInsets.all(15),
          titlePadding: EdgeInsets.zero,
          buttonPadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text('Ubah Status Pembayaran'),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text('Lewati'),
                        onPressed: () {
                          if (member.statusActive == 'active') {
                            Navigator.pop(context);
                          } else {}
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text('Batalkan'),
                        onPressed: () {
                          if (member.statusPaid == 'paid') {
                            Navigator.pop(context);
                          } else {}
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text('Belum Bayar'),
                        onPressed: () {
                          if (member.statusActive == 'active') {
                            Navigator.pop(context);
                          } else {}
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text('Sudah Bayar'),
                        onPressed: () {
                          if (member.statusPaid == 'paid') {
                            Navigator.pop(context);
                          } else {}
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteConfirmationDialog(int id, String name) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Apakah kamu yakin ingin menghapus $name'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ya, hapus'),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<MemberCubit>().deleteMember(id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _createMemberModal(BuildContext context) {
    return showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Form(
            key: _formKeyCreate,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Tambah Anggota',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Masukkan data anggota arisan.',
                    style: TextStyle(fontSize: 14),
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      child: TextFormField(
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama anggota tidak boleh kosong.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            labelStyle: TextStyle(fontSize: 14),
                            labelText: "Nama Anggota"),
                      )),
                  Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      child: TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            helperText:
                                "* Notifikasi akan dikirimkan melalui email.",
                            labelStyle: TextStyle(fontSize: 14),
                            labelText: "Email (Opsional)"),
                      )),
                  Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      child: TextFormField(
                        controller: _noTelpController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'No telp tidak boleh kosong.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            labelStyle: TextStyle(fontSize: 14),
                            labelText: "No Telp (Whatsapp)"),
                      )),
                  SizedBox(
                    height: 25,
                  ),
                  Container(
                    // margin: EdgeInsets.all(15),
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: const Text('Simpan'),
                      onPressed: () {
                        if (_formKeyCreate.currentState!.validate()) {
                          Navigator.pop(context);
                          context.read<MemberCubit>().createMember(MemberModel(
                              group: widget.group,
                              name: _nameController.text,
                              email: _emailController.text,
                              noTelp: _noTelpController.text));
                        }
                        // Navigator.push(context,
                        //     MaterialPageRoute(builder: (builder) {
                        //   return ContactScreen();
                        // }));
                      },
                    ),
                  ),
                  // Container(
                  //     margin: EdgeInsets.symmetric(vertical: 15),
                  //     child: Center(child: const Text('Atau'))),
                  // Container(
                  //   width: MediaQuery.of(context).size.width,
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       primary: Colors.white,
                  //       onPrimary: Colors.lightBlue[700],
                  //       shadowColor: Colors.transparent,
                  //       shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(20.0),
                  //           side: BorderSide(color: Colors.lightBlue.shade800)),
                  //     ),
                  //     child: const Text('Tambahkan dari Contact'),
                  //     onPressed: () {
                  //       Navigator.push(context,
                  //           MaterialPageRoute(builder: (builder) {
                  //         return ContactScreen();
                  //       }));
                  //     },
                  //   ),
                  // )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateMemberModal(BuildContext context, MemberModel member) {
    final TextEditingController nameEditController = TextEditingController();
    final TextEditingController emailEditController = TextEditingController();
    final TextEditingController noTelpEditController = TextEditingController();

    nameEditController.text = member.name ?? '';
    emailEditController.text = member.email ?? '';
    noTelpEditController.text = member.noTelp ?? '';
    return showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Form(
            key: _formKeyUpdate,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Update Anggota',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Masukkan data anggota arisan.',
                    style: TextStyle(fontSize: 14),
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      child: TextFormField(
                        controller: nameEditController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama anggota tidak boleh kosong.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            labelStyle: TextStyle(fontSize: 14),
                            labelText: "Nama Anggota"),
                      )),
                  Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      child: TextFormField(
                        controller: emailEditController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            helperText:
                                "* Notifikasi akan dikirimkan melalui email.",
                            labelStyle: TextStyle(fontSize: 14),
                            labelText: "Email (Opsional)"),
                      )),
                  Container(
                      margin: EdgeInsets.only(left: 5, right: 5),
                      child: TextFormField(
                        controller: noTelpEditController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'No telp tidak boleh kosong.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            labelStyle: TextStyle(fontSize: 14),
                            labelText: "No Telp (Whatsapp)"),
                      )),
                  SizedBox(
                    height: 25,
                  ),
                  Container(
                    // margin: EdgeInsets.all(15),
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: const Text('Simpan'),
                      onPressed: () {
                        if (_formKeyUpdate.currentState!.validate()) {
                          Navigator.pop(context);
                          context.read<MemberCubit>().updateMember(MemberModel(
                              id: member.id!,
                              group: widget.group,
                              name: nameEditController.text,
                              email: emailEditController.text,
                              noTelp: noTelpEditController.text));
                        }
                      },
                    ),
                  ),
                  // Container(
                  //     margin: EdgeInsets.symmetric(vertical: 15),
                  //     child: Center(child: const Text('Atau'))),
                  // Container(
                  //   width: MediaQuery.of(context).size.width,
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       primary: Colors.white,
                  //       onPrimary: Colors.lightBlue[700],
                  //       shadowColor: Colors.transparent,
                  //       shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(20.0),
                  //           side: BorderSide(color: Colors.lightBlue.shade800)),
                  //     ),
                  //     child: const Text('Tambahkan dari Contact'),
                  //     onPressed: () {
                  //       Navigator.push(context,
                  //           MaterialPageRoute(builder: (builder) {
                  //         return ContactScreen();
                  //       }));
                  //     },
                  //   ),
                  // )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
