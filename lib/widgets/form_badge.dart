import 'package:flutter/material.dart';
import 'package:team_up_fe_new/utils/live_form_state.dart';
import '../../models/live_form.dart';

class FormBadge extends StatelessWidget {
  final LiveForm liveForm;

  const FormBadge({super.key, required this.liveForm});

  @override
  Widget build(BuildContext context) {
    final state = getLiveFormState(liveForm.delta);

    switch (state) {
      case LiveFormState.onFire:
        return _badge('In form', Colors.orange);
      case LiveFormState.good:
        return _badge('Good', Colors.green);
      case LiveFormState.off:
        return _badge('Off', Colors.blueGrey);
      case LiveFormState.bad:
        return _badge('Out', Colors.blue);
      case LiveFormState.normal:
        return _badge('Normal', Colors.grey);
    }
  }


  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$text',
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
