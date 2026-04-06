enum VeilType {
  dread('Dread', 'The Monster'),
  respect('Respect', 'The Honorable'),
  sway('Sway', 'The Puppeteer'),
  empire('Empire', 'The Mogul'),
  guile('Guile', 'The Chessmaster'),
  legend('Legend', 'The Icon'),
  kinship('Kinship', 'The Patriarch');

  const VeilType(this.displayName, this.fantasy);
  final String displayName;
  final String fantasy;
}
