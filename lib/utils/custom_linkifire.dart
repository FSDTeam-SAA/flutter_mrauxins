import 'package:flutter_linkify/flutter_linkify.dart';

class CustomLinkifier extends Linkifier {
  const CustomLinkifier();

  @override
  List<LinkifyElement> parse(
    List<LinkifyElement> elements,
    LinkifyOptions options,
  ) {
    final list = <LinkifyElement>[];

    for (final element in elements) {
      if (element is TextElement) {
        final urlRegex = RegExp(
          r'(?:(?:https?|ftp):\/\/)?' // optional scheme
          r'(?:www\.)?' // optional www
          r'(?:' // start domain group
          r'[a-z0-9-]+' // first domain part
          r'(?:\.[a-z0-9-]+)*' // optional subdomains
          r'\.' // dot before TLD
          r'(?:' // TLD options:
          r'[a-z]{2,}' // standard TLDs (2+ chars)
          r'|com|org|net|edu|gov|mil|int|biz|info|name|pro|aero|coop|museum|travel|jobs|mobi|cat|tel|xxx|asia' // common gTLDs
          r'|ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cu|cv|cx|cy|cz|de|dj|dk|dm|do|dz|ec|ee|eg|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mm|mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|sk|sl|sm|sn|so|sr|st|su|sv|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|za|zm|zw' // country codes
          r'|co\.uk|com\.au|org\.uk|net\.au|co\.nz|co\.za|com\.br|com\.mx|com\.sg|com\.tw|co\.in|co\.jp|co\.kr|ne\.jp|or\.kr|ac\.kr|go\.kr|pe\.kr|re\.kr|or\.at|ac\.at|co\.at|gv\.at' // second-level domains
          r')' // end TLD options
          r')' // end domain group
          r'(?::\d+)?' // optional port
          r'(?:\/[^\s?#]*)?' // optional path
          r'(?:\?[^\s#]*)?' // optional query
          r'(?:#[^\s]*)?', // optional fragment
          caseSensitive: false,
        );
        final text = element.text;
        final matches = urlRegex.allMatches(text);
        if (matches.isEmpty) {
          list.add(element);
          continue;
        }

        int lastEnd = 0;
        for (final match in matches) {
          // Add text before URL
          if (match.start > lastEnd) {
            list.add(TextElement(text.substring(lastEnd, match.start)));
          }

          final urlMatch = match.group(0)!;
          final displayText = urlMatch;
          // Add https:// if no protocol specified
          final url =
              urlMatch.contains(RegExp(r'^[a-z]+:\/\/', caseSensitive: false))
                  ? urlMatch
                  : 'https://$urlMatch';

          list.add(UrlElement(url, displayText, displayText));
          lastEnd = match.end;
        }

        // Add remaining text after last URL
        if (lastEnd < text.length) {
          list.add(TextElement(text.substring(lastEnd)));
        }
      } else {
        list.add(element);
      }
    }

    return list;
  }
}

final _domainRegex = RegExp(
  r'\b((?:[a-zA-Z0-9-]+\.)+(?:[a-z]{2,}))\b',
  caseSensitive: false,
);

class DomainLinkifier extends Linkifier {
  const DomainLinkifier();
  @override
  List<LinkifyElement> parse(elements, options) {
    final list = <LinkifyElement>[];
    for (final element in elements) {
      if (element is! TextElement) {
        list.add(element);
        continue;
      }
      final text = element.text;
      int lastMatchEnd = 0;
      for (final match in _domainRegex.allMatches(text)) {
        // Add text before match
        if (match.start > lastMatchEnd) {
          list.add(TextElement(text.substring(lastMatchEnd, match.start)));
        }
        final domain = match.group(0)!;
        final tld = domain.split('.').last.toLowerCase();
        if (validTlds.contains(tld)) {
          final url =
              (options.defaultToHttps ? 'https://' : 'http://') + domain;
          list.add(UrlElement(url, domain));
        } else {
          list.add(TextElement(domain)); // Not a valid domain
        }
        lastMatchEnd = match.end;
      }
      // Add remaining text
      if (lastMatchEnd < text.length) {
        list.add(TextElement(text.substring(lastMatchEnd)));
      }
    }
    return list;
  }
}

const List<String> validTlds = [
  // Common TLDs
  'com', 'org', 'net', 'edu', 'gov', 'mil', 'int',
  'info', 'biz', 'name', 'pro', 'io', 'ai', 'app', 'dev', 'xyz', 'me',
  // Country codes
  'us', 'uk', 'in', 'ca', 'de', 'fr', 'ru', 'br', 'cn', 'au', 'za', 'ng',
  // New TLDs (short list)
  'tech', 'site', 'online', 'store', 'cloud', 'digital', 'media', 'live',
  'design', 'studio', 'space', 'today', 'company', 'solutions'
  // ... you can add more
];
