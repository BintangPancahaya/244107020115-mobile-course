double hitungLuasPersegiPanjang(double panjang, double lebar) => panjang * lebar;

class Profil {
  Profil({this.nama, this.nim, this.email});
  String? nama;
  String? nim;
  String? email;
}

void main() {
  double luas = hitungLuasPersegiPanjang(12.0, 5.0);
  print('Luas Persegi Panjang: $luas');

  Profil mhs = Profil(
    nama: 'Bintang',
    nim: '244107020115',
    email: null,
  );

  print('Nama: ${mhs.nama}');
  print('NIM: ${mhs.nim}');
  print('Email: ${mhs.email ?? "Email tidak tersedia"}');
}