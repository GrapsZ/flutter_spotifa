class Music {

  String title;
  String artist;
  String imagePath;
  String urlSong;

  Music(String title, String artist, String imagePath, String urlSong) {
    this.title = title;
    this.artist = artist;
    this.imagePath = imagePath;
    this.urlSong = urlSong;
  }

  String getImagePath() {
    return this.imagePath;
  }

  String getUrlSong() {
    return this.urlSong;
  }

  String getArtist() {
    return this.artist;
  }

  String getTitle() {
    return this.title;
  }

}