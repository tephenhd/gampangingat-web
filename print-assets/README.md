# Print assets

## QR codes → https://gampang-ingat.com

Generated offline with `qrencode` at error-correction level **H** (~30% damage
tolerance) — chosen because these get creased, dirtied and printed small.

| File | Use |
|---|---|
| `gampang-ingat-qr.svg` | Vector. Send this to a printer/designer. Scales to any size. |
| `gampang-ingat-qr-300dpi.png` | 1230×1230px (~10cm @ 300 DPI). Drop into Canva/Word/WhatsApp. |

Where to place them: printed colour card, nota/invoice, storefront window, and
delivery boxes going to regions where an agent is being recruited.

Regenerate (only if the domain changes):

    qrencode -o gampang-ingat-qr.svg -t SVG -l H -m 4 "https://gampang-ingat.com"
    qrencode -o gampang-ingat-qr-300dpi.png -t PNG -l H -m 4 -s 30 -d 300 "https://gampang-ingat.com"

Not yet verified by an actual phone scan — no QR decoder is installed on the
server. Do a 10-second camera test before printing in quantity.
