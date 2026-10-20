// Regla del taller: solo se guarda si la prioridad es mayor o igual a 2.
const int minPriority = 2;
const int maxPriority = 5;

// Devuelve null si la prioridad es válida, o el mensaje que se muestra si no.
String? validatePriority(int? priority) {
  if (priority == null) {
    return 'Selecciona una prioridad antes de guardar';
  }
  if (priority < minPriority) {
    return 'La prioridad debe ser mayor o igual a $minPriority para guardar';
  }
  return null;
}
