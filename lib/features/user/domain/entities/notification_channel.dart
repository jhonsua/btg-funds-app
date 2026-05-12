enum NotificationChannel {
  email('Correo'),
  sms('SMS');

  const NotificationChannel(this.label);

  final String label;
}
