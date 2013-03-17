#!/bin/bash

URL="https://www.google.com/voice/b/0/setup/searchnew/"

# Add your Google cookies here
COOKIES="xxx"

rm -f areacodes || true
touch areacodes
rm -f numbers || true
touch numbers

# Get area codes
curl -ks --cookie "$COOKIES" "${URL}?ac=[201-999]&start=0&country=US" | grep -ho "+1[0-9]\{3\}" | cut -b3-5 | sort -u >> areacodes

# Get numbers (BFS on digits)
for AREACODE in `cat areacodes`; do
	printf "${AREACODE}0000000\n" > numbers
	printf "Area code: $AREACODE\n";

	echo -n "Progress: 1%... ";

	cut -b1-3 numbers | sort -u | (while read LINE; do CURL_URL="${URL}?ac=${LINE:0:3}&q=$LINE[0-9]&start=0"; curl -ks --cookie "$COOKIES" "$CURL_URL"; done) | pcregrep --buffer-size=32M -ho '\d{10}\b' | sort -u >> numbers

	echo -n "10%... ";

	cut -b1-4 numbers | sort -u | (while read LINE; do CURL_URL="${URL}?ac=${LINE:0:3}&q=$LINE[0-9]&start=0"; curl -ks --cookie "$COOKIES" "$CURL_URL"; done) | pcregrep --buffer-size=32M -ho '\d{10}\b' | sort -u >> numbers

	echo -n "20%... ";

	cut -b1-5 numbers | sort -u | (while read LINE; do CURL_URL="${URL}?ac=${LINE:0:3}&q=$LINE[0-9]&start=0"; curl -ks --cookie "$COOKIES" "$CURL_URL"; done) | pcregrep --buffer-size=32M -ho '\d{10}\b' | sort -u >> numbers

	echo -n "42%... ";

	cut -b1-6 numbers | sort -u | (while read LINE; do CURL_URL="${URL}?ac=${LINE:0:3}&q=$LINE[0-9]&start=0"; curl -ks --cookie "$COOKIES" "$CURL_URL"; done) | pcregrep --buffer-size=32M -ho '\d{10}\b' | sort -u >> numbers

	echo -n "60%... ";

	cut -b1-7 numbers | sort -u | (while read LINE; do CURL_URL="${URL}?ac=${LINE:0:3}&q=$LINE[0-9]&start=0"; curl -ks --cookie "$COOKIES" "$CURL_URL"; done) | pcregrep --buffer-size=32M -ho '\d{10}\b' | sort -u >> numbers

	echo -n "80%... ";

	cut -b1-8 numbers | sort -u | (while read LINE; do CURL_URL="${URL}?ac=${LINE:0:3}&q=$LINE[0-9]&start=0"; curl -ks --cookie "$COOKIES" "$CURL_URL"; done) | pcregrep --buffer-size=32M -ho '\d{10}\b' | sort -u >> numbers

	echo -n "94%... ";

	cut -b1-8 numbers | sort -u | (while read LINE; do CURL_URL="${URL}?ac=${LINE:0:3}&q=$LINE[0-9]&start=5"; curl -ks --cookie "$COOKIES" "$CURL_URL"; done) | pcregrep --buffer-size=32M -ho '\d{10}\b' | sort -u >> numbers

	echo "Done.";

	sort -u numbers > $AREACODE;
done

# Find interesting numbers
mkdir results || true
rm -f all || true

for AREACODE in `cat areacodes`; do
	cat $AREACODE | grep -v "${AREACODE}0000000" >> all;
done

grep "\([0-9]\)\1.*\([0-9]\)\2.*\([0-9]\)\3" all > results/pairs
grep '\([0-9]\)\1\{3\}' all > results/repetitions
grep "\([0-9]\)\([0-9]\)\([0-9]\)\([0-9]\).?\4\3\2\1" all > results/palindromes
grep "\([0-9]\)\([0-9]\)\1\2\1\2" all > results/toggle
grep "\([0-9]\)\([0-9]\)\1\2.*\([0-9]\)\([0-9]\)\3\4\3" all >> results/toggle
pcregrep "(\d)(\d)(\1|\2){4}" all > results/twodigits
grep "\([0-9]\)\([0-9]\)\1\2\1.*\([0-9]\)\([0-9]\)\3\4\3" all > results/ABABACDCDC
pcregrep "(\d)\1.*(\d)\2.*(\d)\3" all > results/tripledouble
grep '[0-9][0-9][0-9]\([01]\)\([01]\)\([01]\)\([01]\)\([01]\)\([01]\)\([01]\)' all > results/binary

rm -f all
