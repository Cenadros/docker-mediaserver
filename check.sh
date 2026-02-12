grep 'image:' docker-compose.yml | grep -vE '^\s*#' | sed 's/.*image: *//' | while read image; do
    echo "Checking: $image"
    docker pull "$image" || echo "❌ Failed: $image"
done