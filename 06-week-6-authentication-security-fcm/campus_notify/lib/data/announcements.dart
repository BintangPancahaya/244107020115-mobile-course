class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
  });

  final String id;
  final String title;
  final String body;
  final String date;
}

/// Data pengumuman lokal (pengganti GET /pengumuman selama backend belum ada).
const announcements = [
  Announcement(
    id: '1',
    title: 'Pendaftaran UKM dibuka',
    body: 'Pendaftaran Unit Kegiatan Mahasiswa dibuka sampai 31 Oktober 2026 '
        'melalui portal SIAKAD.',
    date: '20 Okt 2026',
  ),
  Announcement(
    id: '2',
    title: 'Batas pengisian KRS',
    body: 'Pengisian KRS semester genap paling lambat 5 November 2026.',
    date: '21 Okt 2026',
  ),
  Announcement(
    id: '3',
    title: 'Jadwal kuliah berubah',
    body: 'Kelas Mobile pindah ke Ruang A2 jam 13.00',
    date: '22 Okt 2026',
  ),
];

Announcement? findAnnouncement(String id) {
  for (final a in announcements) {
    if (a.id == id) return a;
  }
  return null;
}
