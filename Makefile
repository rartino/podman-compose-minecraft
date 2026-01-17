build:
	podman-compose pull
	podman-compose --podman-args='--build-arg UPDATE_STAMP="$(date +%s)" --build-arg BUILD_STAMP="$(date +%s)"' build
	podman image prune -f
	echo "Consider running: 'podman system prune' for a full container and image cleanup"

update: build

up:
	@trap "podman-compose down" INT TERM; \
	podman-compose up

down:
	podman-compose down

