Future<String> fixPseudoJson(String input) async {
  final now = DateTime.now().toIso8601String();

  input = input.replaceAllMapped(
    RegExp(r'DateTime\\.now\\(\\)\\.toIso8601String\\(\\)'),
    (_) => '"\$now"',
  );

  input = input.replaceAllMapped(
    RegExp(r'(\w+)\s*:\s*([^,{}]+)'),
    (match) {
      final key = match.group(1)?.trim();
      var value = match.group(2)?.trim();

      final isQuoted = value!.startsWith('"') ||
          value.startsWith("'") ||
          num.tryParse(value) != null;
      if (!isQuoted && value != 'true' && value != 'false' && value != 'null') {
        value = '"' + value + '"';
      }

      return '"\$key": \$value';
    },
  );

  return input.replaceAll(RegExp(r',\s*}'), '}');
}
