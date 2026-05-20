# openclaw-docker


```
docker run -it --rm -v ./openclaw:/home/node/.openclaw ghcr.io/ider-zh/openclaw-docker:main bash
```

download basic image
```
export https_proxy=http://192.168.1.230:10808

images=(
  "node:24-slim"
	"python:3.13-slim-bookworm"
)

for img in "${images[@]}"; do
  skopeo copy docker://$img docker-daemon:$img
done
```