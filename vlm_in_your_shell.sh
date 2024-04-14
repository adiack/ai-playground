#Instructions: https://adiack.github.io/2024/04/14/Gemini-VLM-In-Your-Shell.html

export GOOGLE_API_KEY="YOUR_API_KEY"
export OPENAI_API_KEY="YOUR_API_KEY"

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

  tput bold; echo "Gemini Image Description:"
  tput sgr0; fmt -w 70 <<< "$gemini_response"
}

openai_desc() {
  # Check if filename is provided and the file exists
  if [ -z "$1" ]; then
    echo "Usage: openai_desc <filename>"
    return 1
  elif [ ! -f "$1" ]; then
    echo "File does not exist: $1"
    return 1
  fi

  # Encode the image file to base64
  local img_base64=$(base64 -i "$1")

  # Construct the JSON payload for OpenAI API
  local json_payload='{"model": "gpt-4-turbo", "messages": [{"role": "user", "content": [{"type": "text", "text": "What’s in this image?"}, {"type": "image", "image": {"base64": "'"$img_base64"'"}}]}]}'

  # Send the request to OpenAI API and extract the description
  local openai_response=$(curl -s https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "$json_payload" )

  tput bold; echo "OpenAI Image Description:"
  tput sgr0; fmt -w 70 <<< "$openai_response"
}
