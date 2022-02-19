kiali:
	docker-compose run --rm istioctl dashboard kiali

demo:
	./scripts/demo

down:
	docker-compose down

clobber:
	docker-compose down -v
