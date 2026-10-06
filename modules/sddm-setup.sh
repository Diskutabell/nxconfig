hd=""; fast=""; slow=""; bestrate=0

for o in $(xrandr -q 2>/dev/null | grep " connected" | cut -d" " -f1); do
  rate=$(xrandr -q 2>/dev/null | awk -v o="$o" '
      $1==o        { f=1; next }
      /^[^[:space:]]/ { f=0 }
      f && $1=="2560x1440" {
        for (i=2;i<=NF;i++) {
          gsub(/[*+]/,"",$i);
          if ($i+0>m) m=$i+0
        }
      }
      END { if (m) print int(m) }
  ')

  if [ -z "$rate" ]; then
    hd="$o"
  elif [ "$rate" -gt "$bestrate" ]; then
    [ -n "$fast" ] && slow="$fast"
    fast="$o"
    bestrate="$rate"
  else
    slow="$o"
  fi
done

[ -n "$hd" ]   && xrandr --output "$hd"   --mode 1920x1080 --pos 0x0 || true
[ -n "$fast" ] && xrandr --output "$fast" --mode 2560x1440 --pos 1920x0 --primary || true
[ -n "$slow" ] && xrandr --output "$slow" --mode 2560x1440 --pos 4480x0 || true

home=/home/diskutabel
out=/var/lib/sddm-lock
mkdir -p "$out"

wall=$home/.cache/quickshell/wallpaper_picker/current_wallpaper.png
if [ ! -f "$wall" ]; then
  wall="$(find "$home/Pictures/walls" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
    2>/dev/null | shuf -n1)"
fi

if [ -n "$wall" ] &&
  magick "$wall" -resize 2560x1440^ -gravity center -extent 2560x1440 \
    -blur 0x24 "$out/background.png.new"; then
  mv -f "$out/background.png.new" "$out/background.png"
fi

[ -f /tmp/qs_colors.json ] && cp -f /tmp/qs_colors.json "$out/colors.json"

for face in "$home/.face.icon" "$home/.face"; do
  if [ -f "$face" ]; then
    magick "$face" "$out/face.png"
    break
  fi
done

chmod 0644 "$out"/* 2>/dev/null || true
