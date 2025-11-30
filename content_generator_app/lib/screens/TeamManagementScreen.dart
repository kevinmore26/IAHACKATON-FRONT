// Archivo: TeamManagementScreen.dart (VERSION FINAL CON ASIGNACIÓN DE EQUIPO)

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; 

// ----------------- MODELOS DE DATOS -----------------

// 1. Clase Miembro del Equipo
class TeamMember {
  final String name;
  final Color color;
  final String initials;
  TeamMember(this.name, this.color)
      : initials = name.split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').join();
}

// 2. Clase Tarea
class Task {
  final String id;
  final String title;
  final TeamMember? assignedTo; 
  Task(this.id, this.title, {this.assignedTo});

  // Copia la tarea, pero cambia el asignado (utilizado al hacer Drag & Drop)
  Task copyWith({TeamMember? assignedTo}) {
    return Task(id, title, assignedTo: assignedTo ?? this.assignedTo);
  }
}

// ----------------- PANTALLA -----------------

class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  // CONSTANTE DE COLOR PRINCIPAL DE TU APP
  static const Color _primaryColor = Color(0xFF4461F2);

  // VARIABLES DE ESTADO DEL CALENDARIO
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  // DATOS MOCK DE MIEMBROS DEL EQUIPO
  final List<TeamMember> _teamMembers = [
    TeamMember('Ana Sánchez', Colors.purple),
    TeamMember('Javier Ríos', Colors.orange),
    TeamMember('Sara Vidal', Colors.green),
  ];

  // DATOS MOCK: Tareas por día (Ahora usa List<Task>)
  final Map<DateTime, List<Task>> _tasks = {
    // Es CRUCIAL normalizar la clave del día (sin la parte de la hora)
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day): [
      Task('t1', 'Grabar Hook de Venta', assignedTo: TeamMember('Ana Sánchez', Colors.purple)),
    ],
    DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day + 1): [
      Task('t2', 'Escribir Script IA 2', assignedTo: TeamMember('Javier Ríos', Colors.orange)),
    ],
  };

  // Lista de Tareas NO ASIGNADAS (para arrastrar)
  List<Task> _unassignedTasks = [
    Task('u1', 'Diseñar Portada Video'),
    Task('u2', 'Buscar Música Libre'),
    Task('u3', 'Investigar Tendencias'),
  ];

  @override
  void initState() {
    super.initState();
    // Normalizar _selectedDay para evitar problemas de comparación con la hora
    _selectedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    _focusedDay = _selectedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Gestión de Equipo 📅",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_outlined, color: _primaryColor),
            onPressed: () {
              // Lógica para crear una nueva tarea (ej. abrir un modal)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Abrir modal para crear nueva tarea')),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------- 1. CALENDARIO --------------------
            _buildCalendar(),
            const Divider(height: 1, color: Colors.grey),

            // -------------------- 2. TAREAS NO ASIGNADAS --------------------
            _buildSectionHeader("Tareas Pendientes (Arrastra para asignar)", 20),
            _buildUnassignedTasksList(),
            
            // -------------------- 3. ZONA DE SOLTADO (DragTarget) --------------------
            _buildDropZone(),

            // -------------------- 4. TAREAS ASIGNADAS DEL DÍA --------------------
            _buildSectionHeader(
                "Misiones para el ${_selectedDay.day}/${_selectedDay.month}",
                20),
            _buildAssignedTasksList(),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // WIDGETS AUXILIARES

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
          _focusedDay = focusedDay; 
        });
      },
      // Estilos
      headerStyle: const HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        decoration: BoxDecoration(color: Colors.white),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: _primaryColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: _primaryColor,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        defaultTextStyle: const TextStyle(color: Colors.black87),
        weekendTextStyle: TextStyle(color: Colors.grey.shade600),
      ),
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
    );
  }

  // LISTA DE TAREAS NO ASIGNADAS (Horizontal)
  Widget _buildUnassignedTasksList() {
    if (_unassignedTasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text("¡Todas las tareas están asignadas! 🎉", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
      );
    }
    
    return Container(
      height: 100, // Altura limitada
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _unassignedTasks.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 15),
            child: _buildDraggableTaskCard(_unassignedTasks[index]),
          );
        },
      ),
    );
  }

  // WIDGET ARRASTRABLE (Draggable)
  Widget _buildDraggableTaskCard(Task task) {
    return Draggable<String>(
      // data es el ID de la tarea, lo que pasamos al soltar
      data: task.id,
      // child es el widget visible en su lugar original
      child: _buildTaskCardContent(task),
      // feedback es el widget que se ve mientras se arrastra
      feedback: Material(
        elevation: 6.0,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 200, 
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(task.title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
      // childWhenDragging es lo que queda en el lugar original (placeholder)
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildTaskCardContent(task),
      ),
    );
  }

  // CONTENIDO DE LA TARJETA DE TAREA
  Widget _buildTaskCardContent(Task task) {
    final bool isAssigned = task.assignedTo != null;
    final TeamMember? assignee = task.assignedTo;
    
    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAssigned ? assignee!.color.withOpacity(0.5) : Colors.grey.shade300, 
          width: 1
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono/Avatar del responsable
          CircleAvatar(
            radius: 15,
            backgroundColor: isAssigned ? assignee!.color : Colors.grey.shade200,
            child: Text(
              isAssigned ? assignee!.initials : '?',
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold, 
                color: isAssigned ? Colors.white : Colors.grey.shade600
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  isAssigned ? 'Asignado a: ${assignee!.name}' : 'Sin asignar',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ZONA DE SOLTADO (DragTarget)
  Widget _buildDropZone() {
    return DragTarget<String>(
      onWillAccept: (taskId) => taskId != null,
      onAccept: (taskId) async {
        final taskToAssign = _unassignedTasks.firstWhere((task) => task.id == taskId);

        // 1. Mostrar diálogo para seleccionar al responsable
        final TeamMember? selectedMember = await _showAssigneeDialog(context, taskToAssign.title);

        if (selectedMember != null) {
          // 2. Lógica de Asignación
          setState(() {
            final assignedTask = taskToAssign.copyWith(assignedTo: selectedMember);

            // Quitar de no asignadas
            _unassignedTasks.removeWhere((task) => task.id == taskId);

            // Añadir a las tareas del día seleccionado (normalizado)
            final normalizedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
            _tasks[normalizedDay] = [...?_tasks[normalizedDay], assignedTask];

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tarea "${assignedTask.title}" asignada a ${selectedMember.name}')),
            );
          });
        }
      },
      builder: (context, candidateData, rejectedData) {
        final bool isOver = candidateData.isNotEmpty;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isOver ? _primaryColor.withOpacity(0.05) : Colors.grey.shade50,
            border: Border.all(
              color: isOver ? _primaryColor : Colors.grey.shade200,
              width: isOver ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isOver ? Icons.thumb_up_alt_outlined : Icons.add_to_photos_outlined,
                  color: isOver ? _primaryColor : Colors.grey.shade500,
                  size: 24,
                ),
                const SizedBox(height: 5),
                Text(
                  isOver ? "¡SUELTA AQUÍ para Asignar al Día Seleccionado!" : "Arrastra una Tarea sin asignar a esta zona",
                  style: TextStyle(
                      color: isOver ? _primaryColor : Colors.grey.shade600,
                      fontWeight: isOver ? FontWeight.bold : FontWeight.normal),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // DIÁLOGO PARA SELECCIONAR RESPONSABLE
  Future<TeamMember?> _showAssigneeDialog(BuildContext context, String taskTitle) {
    return showDialog<TeamMember>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Asignar Responsable: $taskTitle"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _teamMembers.map((member) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: member.color,
                    child: Text(member.initials, style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(member.name),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context, member); // Devolver el miembro seleccionado
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null), // Cancelar
              child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // LISTA DE TAREAS ASIGNADAS PARA EL DÍA SELECCIONADO (Vertical)
  Widget _buildAssignedTasksList() {
    final DateTime normalizedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final todayTasks = _tasks[normalizedDay] ?? [];

    if (todayTasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text("Libre. Arrastra una tarea para asignar al ${_selectedDay.day}/${_selectedDay.month}.",
            style: TextStyle(color: Colors.grey.shade500)),
      );
    }

    // Agrupar tareas por responsable para una vista más organizada
    final Map<String, List<Task>> tasksByAssignee = {};
    for (var task in todayTasks) {
      final name = task.assignedTo?.name ?? 'Sin Asignar (Error)';
      tasksByAssignee.putIfAbsent(name, () => []).add(task);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tasksByAssignee.entries.map((entry) {
          final assigneeName = entry.key;
          final assigneeTasks = entry.value;
          
          // Buscar el color del miembro para el divisor
          final member = _teamMembers.firstWhere((m) => m.name == assigneeName, orElse: () => TeamMember('?', Colors.black));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 8),
                child: Row(
                  children: [
                    Container(width: 4, height: 20, color: member.color, margin: const EdgeInsets.only(right: 8)),
                    Text(
                      assigneeName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ),
              ...assigneeTasks.map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildTaskCardContent(task),
              )).toList(),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, double topPadding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 10),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }
}