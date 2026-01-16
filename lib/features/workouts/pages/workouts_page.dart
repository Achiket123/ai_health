import 'package:ai_health/features/workouts/bloc/workout_bloc.dart';
import 'package:ai_health/features/workouts/models/workout_data.dart';
import 'package:ai_health/features/workouts/repo/workout_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connector/health_connector.dart';
import 'package:intl/intl.dart';
import 'package:ai_health/main.dart';

class WorkoutsPage extends StatelessWidget {
  const WorkoutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => WorkoutRepository(healthConnector: healthConnector),
      child: BlocProvider(
        create: (context) =>
            WorkoutBloc(repository: context.read<WorkoutRepository>())
              ..add(LoadWorkoutHistory()),
        child: const _WorkoutsView(),
      ),
    );
  }
}

class _WorkoutsView extends StatefulWidget {
  const _WorkoutsView();

  @override
  State<_WorkoutsView> createState() => _WorkoutsViewState();
}

class _WorkoutsViewState extends State<_WorkoutsView> {
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _type;

  late final List<String> _types;

  @override
  void initState() {
    super.initState();
    _types = _getExerciseTypes();
    _type = _types.contains('Running') ? 'Running' : _types.first;
  }

  List<String> _getExerciseTypes() {
    final types = ExerciseType.values
        .map((e) => _formatExerciseType(e))
        .toList();
    types.sort();
    return types;
  }

  String _formatExerciseType(ExerciseType type) {
    // Convert enum name to Title Case with spaces
    // e.g. highIntensityIntervalTraining -> High Intensity Interval Training
    final name = type.toString().split('.').last;
    final buffer = StringBuffer();
    for (int i = 0; i < name.length; i++) {
      final char = name[i];
      if (i > 0 && char.toUpperCase() == char && char.toLowerCase() != char) {
        buffer.write(' ');
      }
      if (i == 0) {
        buffer.write(char.toUpperCase());
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workouts')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Log Workout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _type,
                      decoration: const InputDecoration(
                        labelText: 'Activity Type',
                        border: OutlineInputBorder(),
                      ),
                      items: _types
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _type = val!),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Duration',
                              suffixText: 'min',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _caloriesController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Calories',
                              suffixText: 'kcal',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_durationController.text.isEmpty ||
                            _caloriesController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please fill duration and calories',
                              ),
                            ),
                          );
                          return;
                        }

                        final data = WorkoutData(
                          date: DateTime.now(),
                          type: _type ?? 'Other',
                          durationMinutes:
                              int.tryParse(_durationController.text) ?? 0,
                          caloriesBurned:
                              int.tryParse(_caloriesController.text) ?? 0,
                          notes: _notesController.text,
                        );
                        context.read<WorkoutBloc>().add(AddWorkoutEntry(data));

                        _durationController.clear();
                        _caloriesController.clear();
                        _notesController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Workout logged')),
                        );
                      },
                      child: const Text('Save Workout'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Workouts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BlocBuilder<WorkoutBloc, WorkoutState>(
              builder: (context, state) {
                if (state.status == WorkoutStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.history.isEmpty) {
                  return const Text('No workouts logged yet.');
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.history.length,
                  itemBuilder: (context, index) {
                    final item = state.history[index];
                    return Card(
                      child: ListTile(
                        leading: _getIcon(item.type),
                        title: Text(
                          '${item.type} - ${item.durationMinutes} min',
                        ),
                        subtitle: Text(
                          DateFormat.yMMMd().add_jm().format(item.date),
                        ),
                        trailing: Text(
                          '${item.caloriesBurned} kcal',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _getIcon(String type) {
    // Basic mapping for common types, default for others
    IconData icon;
    final t = type.toLowerCase();
    if (t.contains('run')) {
      icon = Icons.directions_run;
    } else if (t.contains('walk')) {
      icon = Icons.directions_walk;
    } else if (t.contains('cycle') || t.contains('bike')) {
      icon = Icons.directions_bike;
    } else if (t.contains('swim') || t.contains('pool')) {
      icon = Icons.pool;
    } else if (t.contains('gym') || t.contains('strength')) {
      icon = Icons.fitness_center;
    } else if (t.contains('yoga')) {
      icon = Icons.self_improvement;
    } else if (t.contains('hiit') || t.contains('interval')) {
      icon = Icons.timer;
    } else {
      icon = Icons.sports_gymnastics;
    }
    return Icon(icon, color: Colors.blue);
  }
}
