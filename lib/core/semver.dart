/// Parses and compares `X.Y.Z` versions. A leading `v` and `+build` / prerelease
/// suffixes are ignored.
class Semver implements Comparable<Semver> {
  const Semver(this.major, this.minor, this.patch);

  final int major;
  final int minor;
  final int patch;

  static Semver? tryParse(String raw) {
    var text = raw.trim();
    if (text.isEmpty) return null;
    if (text.startsWith('v') || text.startsWith('V')) {
      text = text.substring(1);
    }
    text = text.split('+').first.split('-').first;
    final parts = text.split('.');
    if (parts.length != 3) return null;
    final major = int.tryParse(parts[0]);
    final minor = int.tryParse(parts[1]);
    final patch = int.tryParse(parts[2]);
    if (major == null || minor == null || patch == null) return null;
    if (major < 0 || minor < 0 || patch < 0) return null;
    return Semver(major, minor, patch);
  }

  bool isNewerThan(Semver other) => compareTo(other) > 0;

  @override
  int compareTo(Semver other) {
    final byMajor = major.compareTo(other.major);
    if (byMajor != 0) return byMajor;
    final byMinor = minor.compareTo(other.minor);
    if (byMinor != 0) return byMinor;
    return patch.compareTo(other.patch);
  }

  @override
  String toString() => '$major.$minor.$patch';

  @override
  bool operator ==(Object other) =>
      other is Semver &&
      major == other.major &&
      minor == other.minor &&
      patch == other.patch;

  @override
  int get hashCode => Object.hash(major, minor, patch);
}
