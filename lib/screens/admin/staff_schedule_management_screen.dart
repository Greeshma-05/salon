import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/stylist.dart';
import '../../models/working_slot.dart';
import '../../models/leave.dart';
import '../../services/stylist_service.dart';
import '../../services/schedule_management_service.dart';

class StaffScheduleManagementScreen extends StatefulWidget {
  const StaffScheduleManagementScreen({super.key});

  @override
  State<StaffScheduleManagementScreen> createState() =>
      _StaffScheduleManagementScreenState();
}

class _StaffScheduleManagementScreenState
    extends State<StaffScheduleManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final StylistService _stylistService = StylistService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Schedule Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.schedule), text: 'Working Hours'),
            Tab(icon: Icon(Icons.event_busy), text: 'Leave Management'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildWorkingHoursTab(), _buildLeaveManagementTab()],
      ),
    );
  }

  Widget _buildWorkingHoursTab() {
    final stylists = _stylistService.getAllStylists();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stylists.length,
      itemBuilder: (context, index) {
        final stylist = stylists[index];
        return _buildStylistScheduleCard(stylist);
      },
    );
  }

  Widget _buildStylistScheduleCard(Stylist stylist) {
    final scheduleService = Provider.of<ScheduleManagementService>(context);
    final workingHours = scheduleService.getWorkingHours(stylist.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            stylist.name[0],
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          stylist.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          workingHours.isEmpty
              ? 'No schedule set'
              : '${workingHours.length} working days',
          style: TextStyle(
            color: workingHours.isEmpty ? Colors.orange : Colors.green,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (workingHours.isEmpty)
                  Center(
                    child: Text(
                      'No working hours set for this stylist',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  ...workingHours.map(
                    (slot) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              slot.day,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              '${slot.startTime} - ${slot.endTime}',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (workingHours.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => _clearSchedule(stylist.id),
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                      ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () => _showSetScheduleDialog(stylist),
                      icon: Icon(workingHours.isEmpty ? Icons.add : Icons.edit),
                      label: Text(
                        workingHours.isEmpty ? 'Set Schedule' : 'Edit Schedule',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSetScheduleDialog(Stylist stylist) {
    final scheduleService = Provider.of<ScheduleManagementService>(
      context,
      listen: false,
    );
    final existingSchedule = scheduleService.getWorkingHours(stylist.id);

    // Initialize with existing or default schedule
    final List<WorkingSlot> schedule = existingSchedule.isEmpty
        ? scheduleService.getDefaultWorkingHours()
        : List.from(existingSchedule);

    showDialog(
      context: context,
      builder: (context) =>
          _ScheduleDialog(stylist: stylist, initialSchedule: schedule),
    );
  }

  void _clearSchedule(String stylistId) {
    final scheduleService = Provider.of<ScheduleManagementService>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Schedule'),
        content: const Text(
          'Are you sure you want to clear the working schedule for this stylist?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              scheduleService.setWorkingHours(stylistId, []);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Schedule cleared')));
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveManagementTab() {
    return Consumer<ScheduleManagementService>(
      builder: (context, scheduleService, _) {
        final leaves = scheduleService.getAllLeaves();
        final upcomingLeaves = scheduleService.getUpcomingLeaves();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Leaves: ${leaves.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  FilledButton.icon(
                    onPressed: _showAddLeaveDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Mark Leave'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: upcomingLeaves.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No upcoming leaves',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: upcomingLeaves.length,
                      itemBuilder: (context, index) {
                        final leave = upcomingLeaves[index];
                        return _buildLeaveCard(leave);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLeaveCard(Leave leave) {
    final stylist = _stylistService.getStylistById(leave.stylistId);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          child: Icon(
            Icons.event_busy,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
        title: Text(
          stylist?.name ?? 'Unknown Stylist',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${dateFormat.format(leave.startDate)} - ${dateFormat.format(leave.endDate)}',
            ),
            if (leave.reason.isNotEmpty)
              Text(
                leave.reason,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _deleteLeave(leave),
        ),
      ),
    );
  }

  void _showAddLeaveDialog() {
    final stylists = _stylistService.getAllStylists();
    Stylist? selectedStylist;
    DateTime? startDate;
    DateTime? endDate;
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Mark Leave'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<Stylist>(
                  decoration: const InputDecoration(
                    labelText: 'Select Stylist',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedStylist,
                  items: stylists.map((stylist) {
                    return DropdownMenuItem(
                      value: stylist,
                      child: Text(stylist.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedStylist = value);
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Start Date'),
                  subtitle: Text(
                    startDate != null
                        ? DateFormat('MMM dd, yyyy').format(startDate!)
                        : 'Select date',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => startDate = picked);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('End Date'),
                  subtitle: Text(
                    endDate != null
                        ? DateFormat('MMM dd, yyyy').format(endDate!)
                        : 'Select date',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: startDate ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => endDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (selectedStylist == null ||
                    startDate == null ||
                    endDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields'),
                    ),
                  );
                  return;
                }

                if (endDate!.isBefore(startDate!)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('End date must be after start date'),
                    ),
                  );
                  return;
                }

                final leave = Leave(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  stylistId: selectedStylist!.id,
                  startDate: startDate!,
                  endDate: endDate!,
                  reason: reasonController.text.trim(),
                  isApproved: true,
                );

                Provider.of<ScheduleManagementService>(
                  context,
                  listen: false,
                ).addLeave(leave);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Leave marked successfully')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteLeave(Leave leave) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Leave'),
        content: const Text('Are you sure you want to delete this leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Provider.of<ScheduleManagementService>(
                context,
                listen: false,
              ).removeLeave(leave.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Leave deleted')));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ScheduleDialog extends StatefulWidget {
  final Stylist stylist;
  final List<WorkingSlot> initialSchedule;

  const _ScheduleDialog({required this.stylist, required this.initialSchedule});

  @override
  State<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<_ScheduleDialog> {
  late List<WorkingSlot> schedule;
  final List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    schedule = List.from(widget.initialSchedule);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set Schedule for ${widget.stylist.name}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: weekDays.map((day) {
                  final existingSlot = schedule
                      .where((slot) => slot.day == day)
                      .firstOrNull;
                  final isWorking = existingSlot != null;

                  return CheckboxListTile(
                    title: Text(day),
                    subtitle: isWorking
                        ? Text(
                            '${existingSlot.startTime} - ${existingSlot.endTime}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : const Text('Day off'),
                    value: isWorking,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          schedule.add(
                            WorkingSlot(
                              day: day,
                              startTime: '09:00',
                              endTime: '18:00',
                            ),
                          );
                        } else {
                          schedule.removeWhere((slot) => slot.day == day);
                        }
                      });
                    },
                    secondary: isWorking
                        ? IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editTimeSlot(day, existingSlot),
                          )
                        : null,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Provider.of<ScheduleManagementService>(
              context,
              listen: false,
            ).setWorkingHours(widget.stylist.id, schedule);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Schedule updated successfully')),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _editTimeSlot(String day, WorkingSlot existingSlot) {
    TimeOfDay? startTime = TimeOfDay(
      hour: int.parse(existingSlot.startTime.split(':')[0]),
      minute: int.parse(existingSlot.startTime.split(':')[1]),
    );
    TimeOfDay? endTime = TimeOfDay(
      hour: int.parse(existingSlot.endTime.split(':')[0]),
      minute: int.parse(existingSlot.endTime.split(':')[1]),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit $day Hours'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Start Time'),
                subtitle: Text(startTime!.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: startTime!,
                  );
                  if (picked != null) {
                    setDialogState(() => startTime = picked);
                  }
                },
              ),
              ListTile(
                title: const Text('End Time'),
                subtitle: Text(endTime!.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: endTime!,
                  );
                  if (picked != null) {
                    setDialogState(() => endTime = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final start =
                    '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}';
                final end =
                    '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';

                setState(() {
                  final index = schedule.indexWhere((slot) => slot.day == day);
                  if (index != -1) {
                    schedule[index] = WorkingSlot(
                      day: day,
                      startTime: start,
                      endTime: end,
                    );
                  }
                });

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
