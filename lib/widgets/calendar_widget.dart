import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';


class CalendarInputWidget extends StatefulWidget {
  final String labelText; // 라벨 텍스트
  final void Function(DateTime date)? onDateSelected; // 날짜를 전달할 콜백 추가
  const CalendarInputWidget({
    super.key,
    required this.labelText,
    this.onDateSelected, // 선택된 날짜를 외부로 전달할 콜백 함수
  });

  @override
  State<CalendarInputWidget> createState() => _CalendarInputWidgetState();
}

class _CalendarInputWidgetState extends State<CalendarInputWidget> {
  DateTime? selectedDate;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  Future<void> _selectDate(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CalendarWidget(
          onDateSelected: (DateTime date) {
            setState(() {
              selectedDate = date;
            });
            if (widget.onDateSelected != null) {
              widget.onDateSelected!(date); // 부모에게 선택된 날짜를 전달
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        readOnly: true,
        style: TextStyle(fontSize: 20),
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
          labelText: widget.labelText,
          hintText: '${widget.labelText}를 선택하세요',
          hintStyle: TextStyle(fontSize: 20),
          suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
          contentPadding: EdgeInsets.all(10)
        ),
        controller: TextEditingController(
          text: selectedDate != null ? dateFormat.format(selectedDate!) : '',
        ),
        onTap: () => _selectDate(context),
      ),
    );
  }
}

class CalendarWidget extends StatefulWidget {
  final void Function(DateTime date) onDateSelected;

  const CalendarWidget({super.key, required this.onDateSelected});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      content: Container(
        width: 400,
        height: 420,
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Column(
          children: [
            Text('날짜 선택', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Expanded(
              child: SfDateRangePicker(
                selectionMode: DateRangePickerSelectionMode.single,
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  setState(() {
                    selectedDate = args.value;
                  });
                },
                headerStyle: const DateRangePickerHeaderStyle(
                    backgroundColor: Colors.blue, textStyle: TextStyle(color: Colors.white)),
                headerHeight: 50,
                backgroundColor: Colors.white,
                selectionTextStyle: const TextStyle(color: Colors.white),
                selectionColor: Colors.blueAccent,
                selectionShape: DateRangePickerSelectionShape.circle,
                todayHighlightColor: Colors.white,
                yearCellStyle: const DateRangePickerYearCellStyle(textStyle: TextStyle(color: Colors.black), todayTextStyle: TextStyle(color: Colors.blue)),
                monthCellStyle: const DateRangePickerMonthCellStyle(textStyle: TextStyle(color: Colors.black)),
                monthViewSettings: DateRangePickerMonthViewSettings(
                    firstDayOfWeek: 1,
                    viewHeaderStyle: DateRangePickerViewHeaderStyle(
                        textStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                        backgroundColor: Colors.blue[100])),
              ),
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          height: 45,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog without action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text('취소', style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onDateSelected(selectedDate);
                      Navigator.of(context).pop(); // Close the dialog after selection
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child:  Text('선택', style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }
}
