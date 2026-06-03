#!/bin/bash
head -n 1 "data/inputs/clients-data.txt" > "data/inputs/single-client.txt"
if grep -E -q '[=\[\]\{\}\(\)]' "data/inputs/single-client.txt"; then
echo "TRANSACTION REJECTED: Input contains prohibited syntax characters (=, [, ], {, }, (,
or ))."
echo "Please submit a plain-text comparison request without nested arrays, formulas or list."
exit 1
fi
comma_count=$(tr -dc ',' < "data/inputs/single-client.txt" | wc -c)
if [ "$comma_count" -ne 1 ]; then
echo "Format your submission exactly as: [Your Context/Terminology], [Your Projected
State/Metric]"
exit 1
fi
awk -F',' '{
w1_count = split($1, w1, " "); if (w1_count == 0 || w1_count > 35) { failed=1; exit 1; }
w2_count = split($2, w2, " "); if (w2_count == 0 || w2_count > 7) { failed=1; exit 1; }
} END { if (failed) exit 1 }' "data/inputs/single-client.txt"
if [ $? -ne 0 ]; then
echo "TRANSACTION REJECTED: Input text length bounds exceeded."
echo "Ensure the left side (Context X) is under 35 words, and the right side (Outcome Y) is
under 7 words."
echo "Neither side be left completely blank."
exit 1
fi
echo "Input Accepted: Processing your transaction against the 30-step Oracle Math protocol.
Your final verification results will be delivered as a strictly YES or No determination."
timeout 60s bash "data/inputs/validate.sh" --oracle-math "data/inputs/protocol.txt"
"data/inputs/single-client.txt" --output-format yesno
