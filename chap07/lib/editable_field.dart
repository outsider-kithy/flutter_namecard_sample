import 'package:flutter/material.dart';

class EditableField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;

  const EditableField({
    Key? key,
    required this.label,
    required this.controller,
    this.validator,
    this.onSaved,
  }) : super(key: key);

  @override
  State<EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<EditableField> {
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300, // 線の色
            width: 1.0,                  // 線の太さ
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 6.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2), // label 列の幅
          1: FlexColumnWidth(6), // text 列の幅
          2: FlexColumnWidth(1), // 編集アイコン
        },
        children: [
          TableRow(
            children: [

              //ラベル
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Text(
                    widget.label,
                    style: const TextStyle(fontSize: 8, color: Colors.grey),
                  ),
                ),
              ),

              //データ
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: TextFormField(
                  controller: widget.controller,
                  validator: widget.validator,
                  onSaved: widget.onSaved,
                  readOnly: !_isEditing, // 編集モードでのみ入力可
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),

              //編集アイコン
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child:
                IconButton(
                        icon: Icon(_isEditing ? Icons.check : Icons.edit),
                        onPressed: _toggleEdit,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}