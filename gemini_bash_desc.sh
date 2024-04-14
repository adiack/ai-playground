export GOOGLE_API_KEY="YOUR_API_KEY"

desc() {
  # Check if the filename is provided and the file exists
  if [ -z "$1" ]; then
    echo "Usage: desc <filename>"
    return 1
  elif [ ! -f "$1" ]; then
    echo "File does not exist: $1"
    return 1
  fi

  # Determine the MIME type based on file extension
  local mime_type
  case "$1" in
    *.png) mime_type="image/png" ;;
    *.jpg|*.jpeg) mime_type="image/jpeg" ;;
    *.webp) mime_type="image/webp" ;;
    *.heic) mime_type="image/heic" ;;
    *.heif) mime_type="image/heif" ;;
    *)
      echo "Unsupported image format: $1"
      return 1
      ;;
  esac

  # Encode the image file to base64
  local IMG_BASE64=$(base64 -i "$1")

  # Generate the JSON payload with the correct MIME type
  local JSON_PAYLOAD="{\"contents\":[{\"parts\":[{\"text\":\"What is this picture?\"},{\"inline_data\":{\"mime_type\":\"${mime_type}\",\"data\":\"${IMG_BASE64}\"}}]}]}"

  # Send the request to the Gemini API and extract the description
  local gemini_response=$(echo "${JSON_PAYLOAD}" | curl -s https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent?key=${GOOGLE_API_KEY} \
    -H 'Content-Type: application/json' -d @- | grep '"text"' | sed 's/.*: "\(.*\)".*/\1/' )

  tput bold; echo "Image Description:"
  tput sgr0; fmt -w 70 <<< "$gemini_response"
}
